//////////////////////////////////////////////////////////////////////////////////
// low_level_scheduler.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Jaewook Kwak	<jwkwak@enc.hanyang.ac.kr>
//
// This file is part of Cosmos+ OpenSSD.
//
// Cosmos+ OpenSSD is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// Cosmos+ OpenSSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cosmos+ OpenSSD; see the file COPYING.
// If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: ENC Lab. <http://enc.hanyang.ac.kr>
// Engineer: Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
//
// Project Name: Cosmos+ OpenSSD
// Design Name: Cosmos+ Firmware
// Module Name: Low Level Scheduler
// File Name: low_level_scheduler.c
//
// Version: v1.7.0
//
// Description:
//   - manage channel/way interleaving
//   - manage the failed request
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.7.0
//	 - Completion table0 and completion table1 are integrated into a metadata region in DRAM for supporting Predefined_Project
//	 - Error information table0 and error information table1 are integrated into a metadata region in DRAM for supporting Predefined_Project
//
// * v1.6.0
//	 - Bad block table is updated to LSB pages of a metadata block of each flash die
//	 - LLSCommand_ReadLsbPage and LLSCommand_WriteLsbPage are added to access a page containing bad block table
//
// * v1.5.0
//	 - low level scheduler can use "LSB pages only" or "LSB & MSB pages" in according to the value of BIT_PER_FLASH_CELL
//
// * v1.4.0
//	 - Completion table and error information table are divided according to HP-port which is connected by each flash channel
//
// * v1.3.0
//	 - DMA partial done check process is operated as non-blocking mode
//   - NAND status check command is issued when NAND flash die is ready status
//   - NVMe DMA and NAND operation can be processed without blocking by operation sequence index
//   - header file for buffer is changed from "ia_lru_buffer.h" to "lru_buffer.h"
//   - Way scheduling is determined by priority of request and die status
//   - Bug of bad block update process is revised
//
// * v1.2.0
//   - DMA status information is saved for DMA partial done check process
//	 - DMA done check process is replaced by DMA partial done check process
//	 - req-queue hold check process is removed
//
// * v1.1.1
//   - status-check bug is revised (Re-check occurs after scanning the status report)
//
// * v1.1.0
//   - bad blocks in LUN1 can be detected
//   - DMA operation can be executed by low level scheduler
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#include "init_ftl.h"
#include "page_map.h"
#include "fmc_driver.h"
#include "low_level_scheduler.h"
#include "memory_map.h"
#include "nvme/host_lld.h"
#include <assert.h>

struct reqArray* reqQueue;
struct rqPointerArray* rqPointer;
struct subReqArray*  subReqQueue;
struct rqPointerArray* srqPointer;
struct completeArray* completeTable;
struct errorInfoArray* errorInfoTable;
struct dieStatusArray* dieStatusTable;
struct newBadBlockArray* newBadBlockTable;
struct retryLimitArray* retryLimitTable;
struct exeSequenceArray* exeSequenceTable;
struct wayPriorityArray* wayPriorityTable;

unsigned int reservedReq;
unsigned int badBlockUpdate;

void PushToReqQueue(P_LOW_LEVEL_REQ_INFO lowLevelCmd)
{
	int rear;
	unsigned int phyRowAddr;
	unsigned int chNo = lowLevelCmd->chNo;
	unsigned int wayNo = lowLevelCmd->wayNo;
	while(((rqPointer->rqPointerEntry[chNo][wayNo].rear + 1) % REQ_QUEUE_DEPTH) == rqPointer->rqPointerEntry[chNo][wayNo].front)
		ExeLowLevelReq(SUB_REQ_QUEUE);

	dieStatusTable->dieStatusEntry[chNo][wayNo].reqQueueEmpty = 0;
	rear = rqPointer->rqPointerEntry[chNo][wayNo].rear;
	if(lowLevelCmd->request >= LLSCommand_RxDMA)
	{
		reqQueue->reqEntry[rear][chNo][wayNo].devAddr = lowLevelCmd->devAddr;
		reqQueue->reqEntry[rear][chNo][wayNo].cmdSlotTag = lowLevelCmd->cmdSlotTag;
		reqQueue->reqEntry[rear][chNo][wayNo].startDmaIndex = lowLevelCmd->startDmaIndex;
		reqQueue->reqEntry[rear][chNo][wayNo].subReqSect = lowLevelCmd->subReqSect;
		reqQueue->reqEntry[rear][chNo][wayNo].bufferEntry = lowLevelCmd->bufferEntry;
		reqQueue->reqEntry[rear][chNo][wayNo].request = lowLevelCmd->request;
		rqPointer->rqPointerEntry[chNo][wayNo].rear = (rear + 1) % REQ_QUEUE_DEPTH;
	}
	else
	{
		if(BIT_PER_FLASH_CELL == SLC_MODE)
		{
			unsigned int lun = lowLevelCmd->rowAddr / PAGE_NUM_PER_LUN;
			unsigned int tempBlock = (lowLevelCmd->rowAddr % PAGE_NUM_PER_LUN) / PAGE_NUM_PER_BLOCK;
			unsigned int tempPage = lowLevelCmd->rowAddr % PAGE_NUM_PER_BLOCK;
			unsigned int phyPage;

			if(lun == 0)
				phyRowAddr = LUN_0_BASE_ADDR;
			else
				phyRowAddr = LUN_1_BASE_ADDR;

			if(tempPage == 0)
				phyPage = 0;
			else
				phyPage = tempPage*2 - 1;

			phyRowAddr +=  tempBlock * PAGE_NUM_PER_BLOCK * 2 + phyPage;
		}
		else if(BIT_PER_FLASH_CELL == MLC_MODE)
		{
			unsigned int lun = lowLevelCmd->rowAddr / PAGE_NUM_PER_LUN;
			unsigned int tempRowAddr = lowLevelCmd->rowAddr % PAGE_NUM_PER_LUN;

			if(lun == 0)
				phyRowAddr = LUN_0_BASE_ADDR + tempRowAddr;
			else
				phyRowAddr = LUN_1_BASE_ADDR + tempRowAddr;
		}
		else
			assert(!"[WARNING] Unsupported bit count [WARNING]");

		reqQueue->reqEntry[rear][chNo][wayNo].rowAddr = phyRowAddr;
		reqQueue->reqEntry[rear][chNo][wayNo].bufferEntry = lowLevelCmd->bufferEntry;
		reqQueue->reqEntry[rear][chNo][wayNo].pageDataBuf = BUFFER_ADDR + lowLevelCmd->bufferEntry * BUF_ENTRY_SIZE;
		reqQueue->reqEntry[rear][chNo][wayNo].spareDataBuf = lowLevelCmd->spareDataBuf;
		reqQueue->reqEntry[rear][chNo][wayNo].statusOption = STATUS_CHECK;
		reqQueue->reqEntry[rear][chNo][wayNo].request = lowLevelCmd->request;
		rqPointer->rqPointerEntry[chNo][wayNo].rear = (rear + 1) % REQ_QUEUE_DEPTH;
	}
}

int CheckDMA(int chNo, int wayNo)
{
	int front = rqPointer->rqPointerEntry[chNo][wayNo].front;
	unsigned int bufferEntry = reqQueue->reqEntry[front][chNo][wayNo].bufferEntry;

	if(bufMap->bufEntry[bufferEntry].txDmaExe)
	{
		if(check_auto_tx_dma_partial_done(bufMap->bufEntry[bufferEntry].txDmaTail, bufMap->bufEntry[bufferEntry].txDmaOverFlowCnt))
			bufMap->bufEntry[bufferEntry].txDmaExe = 0;
		else
			return 0;
	}

	if(bufMap->bufEntry[bufferEntry].rxDmaExe)
	{
		if(check_auto_rx_dma_partial_done(bufMap->bufEntry[bufferEntry].rxDmaTail, bufMap->bufEntry[bufferEntry].rxDmaOverFlowCnt))
			bufMap->bufEntry[bufferEntry].rxDmaExe = 0;
		else
			return 0;
	}

	return 1;
}

int PopFromReqQueue(int chNo, int wayNo)
{
	int front = rqPointer->rqPointerEntry[chNo][wayNo].front;
	unsigned int request = reqQueue->reqEntry[front][chNo][wayNo].request;

	if (request == LLSCommand_RxDMA)
	{
		unsigned int devAddr = reqQueue->reqEntry[front][chNo][wayNo].devAddr;
		unsigned int dmaIndex = reqQueue->reqEntry[front][chNo][wayNo].startDmaIndex;
		unsigned int sectorOffset = 0;
		unsigned int bufferEntry = reqQueue->reqEntry[front][chNo][wayNo].bufferEntry;

		while(sectorOffset < reqQueue->reqEntry[front][chNo][wayNo].subReqSect)
		{
			set_auto_rx_dma(reqQueue->reqEntry[front][chNo][wayNo].cmdSlotTag, dmaIndex, devAddr);
			sectorOffset++;
			dmaIndex++;
			devAddr += SECTOR_SIZE_FTL;
		}
		bufMap->bufEntry[bufferEntry].rxDmaExe = 1;
		bufMap->bufEntry[bufferEntry].rxDmaTail = g_hostDmaStatus.fifoTail.autoDmaRx;
		bufMap->bufEntry[bufferEntry].rxDmaOverFlowCnt = g_hostDmaAssistStatus.autoDmaRxOverFlowCnt;

		rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
		return 0;
	}
	else if (request == LLSCommand_TxDMA)
	{
		unsigned int devAddr = reqQueue->reqEntry[front][chNo][wayNo].devAddr;
		unsigned int dmaIndex = reqQueue->reqEntry[front][chNo][wayNo].startDmaIndex;
		unsigned int sectorOffset = 0;
		unsigned int bufferEntry = reqQueue->reqEntry[front][chNo][wayNo].bufferEntry;

		while(sectorOffset < reqQueue->reqEntry[front][chNo][wayNo].subReqSect)
		{
			set_auto_tx_dma(reqQueue->reqEntry[front][chNo][wayNo].cmdSlotTag, dmaIndex, devAddr);
			sectorOffset++;
			dmaIndex++;
			devAddr += SECTOR_SIZE_FTL;
		}
		bufMap->bufEntry[bufferEntry].txDmaExe = 1;
		bufMap->bufEntry[bufferEntry].txDmaTail = g_hostDmaStatus.fifoTail.autoDmaTx;
		bufMap->bufEntry[bufferEntry].txDmaOverFlowCnt = g_hostDmaAssistStatus.autoDmaTxOverFlowCnt;

		rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
		return 0;
	}
	else if (request == V2FCommand_ReadPageTrigger)
	{
		unsigned int rowAddr = reqQueue->reqEntry[front][chNo][wayNo].rowAddr;

		V2FReadPageTriggerAsync(chCtlReg[chNo], wayNo, rowAddr);
	}
	else if (request == V2FCommand_ReadPageTransfer)
	{
		unsigned int rowAddr = reqQueue->reqEntry[front][chNo][wayNo].rowAddr;
		void* pageDataBuf = (void*)reqQueue->reqEntry[front][chNo][wayNo].pageDataBuf;
		void* spareDataBuf = (void*)reqQueue->reqEntry[front][chNo][wayNo].spareDataBuf;

		unsigned int* errorInfo = (unsigned int*)(&errorInfoTable->errorInfoEntry[chNo][wayNo]);
		unsigned int* completion = (unsigned int*)(&completeTable->completeEntry[chNo][wayNo]);

		V2FReadPageTransferAsync(chCtlReg[chNo], wayNo, pageDataBuf, spareDataBuf, errorInfo, completion, rowAddr);
	}
	else if (request == V2FCommand_ProgramPage)
	{
		unsigned int rowAddr = reqQueue->reqEntry[front][chNo][wayNo].rowAddr;
		void* pageDataBuf = (void*)reqQueue->reqEntry[front][chNo][wayNo].pageDataBuf;
		void* spareDataBuf = (void*)reqQueue->reqEntry[front][chNo][wayNo].spareDataBuf;

		V2FProgramPageAsync(chCtlReg[chNo], wayNo, rowAddr, pageDataBuf, spareDataBuf);
	}
	else
		xil_printf("[error] Not defined request.\r\n");

	return 1;
}

int CheckReqStatusAsync(int chNo, int wayNo)
{
	unsigned int completion,statusReport;
	unsigned int* statusReportPtr;
	int front = rqPointer->rqPointerEntry[chNo][wayNo].front;
	unsigned int previousReq = reqQueue->reqEntry[front][chNo][wayNo].request;

	if (previousReq == V2FCommand_ReadPageTransfer)
	{
		completion = completeTable->completeEntry[chNo][wayNo];

		if (completion & 1)
		{
			unsigned int errorInfo = CheckReqErrorInfo(chNo, wayNo);

			if (errorInfo == EI_PASS)
				return RS_DONE;
			else if (errorInfo == EI_WARNING)
				return RS_WARNING;
			else
				return RS_FAIL;
		}
	}
	else if (reqQueue->reqEntry[front][chNo][wayNo].statusOption == STATUS_CHECK)
	{
		statusReportPtr = &completeTable->completeEntry[chNo][wayNo];

		V2FStatusCheckAsync(chCtlReg[chNo], wayNo, statusReportPtr);

		reqQueue->reqEntry[front][chNo][wayNo].statusOption = CHECK_STATUS_REPORT;
	}
	else if (reqQueue->reqEntry[front][chNo][wayNo].statusOption == CHECK_STATUS_REPORT)
	{
		statusReport = completeTable->completeEntry[chNo][wayNo];

		if (statusReport & 1)
		{
			unsigned int status = statusReport >> 1;
			if ((status & 0x60) == 0x60)
			{
				if (status & 3)
					return RS_FAIL;

				return RS_DONE;
			}
			else
				reqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
		}
	}

	return RS_RUNNING;
}


int CheckReqErrorInfo(int chNo, int wayNo)
{
	unsigned int errorInfo0, errorInfo1;

	errorInfo0 = errorInfoTable->errorInfoEntry[chNo][wayNo][0];
	errorInfo1 = errorInfoTable->errorInfoEntry[chNo][wayNo][1];

	if(V2FCrcValid(errorInfo0))
		if(V2FSpareChunkValid(errorInfo0))
			if(V2FPageChunkValid(errorInfo1))
			{
				if(V2FWorstChunkErrorCount(errorInfo0)> BIT_ERROR_THRESHOLD)
					return EI_WARNING;

				return EI_PASS;
			}

	return EI_FAIL;
}

void PushToSubReqQueue(int chNo, int wayNo, unsigned int request, unsigned int rowAddress, unsigned int pageDataBuf, unsigned int spareDataBuf)
{
	int rear;
	unsigned int phyRowAddr;

	while(((srqPointer->rqPointerEntry[chNo][wayNo].rear + 1) % SUB_REQ_QUEUE_DEPTH) == srqPointer->rqPointerEntry[chNo][wayNo].front)
		ExeLowLevelReq(REQ_QUEUE);

	dieStatusTable->dieStatusEntry[chNo][wayNo].subReqQueueEmpty = 0;
	rear = srqPointer->rqPointerEntry[chNo][wayNo].rear;

	if( (request == LLSCommand_ReadRawPage) ||(request == LLSCommand_ReadLsbPage) || (request == LLSCommand_WriteLsbPage))
	{
		unsigned int lun = rowAddress / MAX_PAGE_NUM_PER_SLC_LUN;
		unsigned int tempBlock = (rowAddress % MAX_PAGE_NUM_PER_SLC_LUN) / PAGE_NUM_PER_SLC_BLOCK;
		unsigned int tempPage = rowAddress % PAGE_NUM_PER_SLC_BLOCK;
		unsigned int phyPage;

		if(lun == 0)
			phyRowAddr = LUN_0_BASE_ADDR;
		else
			phyRowAddr = LUN_1_BASE_ADDR;

		if(tempPage == 0)
			phyPage = 0;
		else
		{
			phyPage = tempPage*2 - 1;

			if((tempPage == (PAGE_NUM_PER_BLOCK - 1)) && (request == LLSCommand_ReadRawPage))
				phyPage = 2*PAGE_NUM_PER_BLOCK - 1;
		}

		phyRowAddr +=  tempBlock * PAGE_NUM_PER_SLC_BLOCK * 2 + phyPage;

		if(request == LLSCommand_ReadLsbPage)
			request =V2FCommand_ReadPageTrigger;
		else if(request == LLSCommand_WriteLsbPage)
			request = V2FCommand_ProgramPage;
	}
	else if(BIT_PER_FLASH_CELL == SLC_MODE)
	{
		unsigned int lun = rowAddress / PAGE_NUM_PER_LUN;
		unsigned int tempBlock = (rowAddress % PAGE_NUM_PER_LUN) / PAGE_NUM_PER_BLOCK;
		unsigned int tempPage = rowAddress % PAGE_NUM_PER_BLOCK;
		unsigned int phyPage;

		if(lun == 0)
			phyRowAddr = LUN_0_BASE_ADDR;
		else
			phyRowAddr = LUN_1_BASE_ADDR;

		if(tempPage == 0)
			phyPage = 0;
		else
			phyPage = tempPage*2 - 1;

		phyRowAddr +=  tempBlock * PAGE_NUM_PER_BLOCK * 2 + phyPage;
	}
	else if(BIT_PER_FLASH_CELL == MLC_MODE)
	{
		unsigned int lun = rowAddress/ PAGE_NUM_PER_LUN;
		unsigned int tempRowAddr = rowAddress % PAGE_NUM_PER_LUN;

		if(lun == 0)
			phyRowAddr = LUN_0_BASE_ADDR + tempRowAddr;
		else
			phyRowAddr = LUN_1_BASE_ADDR + tempRowAddr;
	}
	else
		assert(!"[WARNING] Unsupported bit count [WARNING]");

	subReqQueue->reqEntry[rear][chNo][wayNo].rowAddr = phyRowAddr;
	subReqQueue->reqEntry[rear][chNo][wayNo].request = request;
	subReqQueue->reqEntry[rear][chNo][wayNo].pageDataBuf = pageDataBuf;
	subReqQueue->reqEntry[rear][chNo][wayNo].spareDataBuf = spareDataBuf;

	if ((request == V2FCommand_Reset) || (request == V2FCommand_SetFeatures))
		subReqQueue->reqEntry[rear][chNo][wayNo].statusOption = NONE;
	else
		subReqQueue->reqEntry[rear][chNo][wayNo].statusOption = STATUS_CHECK;

	srqPointer->rqPointerEntry[chNo][wayNo].rear = (rear + 1) % SUB_REQ_QUEUE_DEPTH;
}


int PopFromSubReqQueue(int chNo, int wayNo)
{
	unsigned int* errorInfo;
	unsigned int* completion;
	int front = srqPointer->rqPointerEntry[chNo][wayNo].front;
	unsigned int request = subReqQueue->reqEntry[front][chNo][wayNo].request;
	unsigned int rowAddr = subReqQueue->reqEntry[front][chNo][wayNo].rowAddr;
	void* pageDataBuf = (void*)subReqQueue->reqEntry[front][chNo][wayNo].pageDataBuf;
	void* spareDataBuf = (void*)subReqQueue->reqEntry[front][chNo][wayNo].spareDataBuf;

	if (request == V2FCommand_ReadPageTrigger)
		V2FReadPageTriggerAsync(chCtlReg[chNo], wayNo, rowAddr);
	else if (request == V2FCommand_ReadPageTransfer)
	{
		errorInfo = (unsigned int*)(&errorInfoTable->errorInfoEntry[chNo][wayNo]);
		completion = (unsigned int*)(&completeTable->completeEntry[chNo][wayNo]);

		V2FReadPageTransferAsync(chCtlReg[chNo], wayNo, pageDataBuf, spareDataBuf, errorInfo, completion, rowAddr);
	}
	else if (request == V2FCommand_ProgramPage)
		V2FProgramPageAsync(chCtlReg[chNo], wayNo, rowAddr, pageDataBuf, spareDataBuf);
	else if (request == V2FCommand_BlockErase)
		V2FEraseBlockAsync(chCtlReg[chNo], wayNo, rowAddr);
	else if (request == LLSCommand_ReadRawPage)
		V2FReadPageTriggerAsync(chCtlReg[chNo], wayNo, rowAddr);
	else if (request == V2FCommand_ReadPageTransferRaw)
	{
		completion = (unsigned int*)(&completeTable->completeEntry[chNo][wayNo]);

		V2FReadPageTransferRawAsync(chCtlReg[chNo], wayNo, pageDataBuf, completion);
	}
	else if (request == V2FCommand_Reset)
		V2FResetSync(chCtlReg[chNo], wayNo);
	else if (request == V2FCommand_SetFeatures)
		V2FEnterToggleMode(chCtlReg[chNo], wayNo);
	else
		xil_printf("[error2] Not defined request.\r\n");

	return 1;
}

int CheckSubReqStatusAsync(int chNo, int wayNo)
{
	unsigned int completion,statusReport;
	unsigned int* statusReportPtr;
	int front = srqPointer->rqPointerEntry[chNo][wayNo].front;
	unsigned int previousReq = subReqQueue->reqEntry[front][chNo][wayNo].request;

	if (previousReq == V2FCommand_ReadPageTransfer)
	{
		completion = completeTable->completeEntry[chNo][wayNo];

		if (completion & 1)
		{
			unsigned int errorInfo = CheckSubReqErrorInfo(chNo, wayNo);

			if (errorInfo == EI_PASS)
				return RS_DONE;
			else
				return RS_FAIL;
		}
	}
	else if (previousReq == V2FCommand_ReadPageTransferRaw)
	{
		completion = completeTable->completeEntry[chNo][wayNo];

		if (completion & 1)
			return RS_DONE;
	}
	else if (subReqQueue->reqEntry[front][chNo][wayNo].statusOption == STATUS_CHECK)
	{
		statusReportPtr = &completeTable->completeEntry[chNo][wayNo];

		V2FStatusCheckAsync(chCtlReg[chNo], wayNo, statusReportPtr);

		subReqQueue->reqEntry[front][chNo][wayNo].statusOption = CHECK_STATUS_REPORT;
	}
	else if (subReqQueue->reqEntry[front][chNo][wayNo].statusOption == CHECK_STATUS_REPORT)
	{
		statusReport = completeTable->completeEntry[chNo][wayNo];

		if (statusReport & 1)
		{
			unsigned int status = statusReport >> 1;
			if ((status & 0x60) == 0x60)
			{
				if (status & 3)
					return RS_FAIL;

				return RS_DONE;
			}
			else
				subReqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
		}
	}
	else
	{
		unsigned int readyBusy = V2FReadyBusyAsync(chCtlReg[chNo]);

		if ((readyBusy >> wayNo) & 1)
			return RS_DONE;
	}
	return RS_RUNNING;
}

int CheckSubReqErrorInfo(int chNo, int wayNo)
{
	unsigned int errorInfo0, errorInfo1;

	errorInfo0 = errorInfoTable->errorInfoEntry[chNo][wayNo][0];
	errorInfo1 = errorInfoTable->errorInfoEntry[chNo][wayNo][1];

	if(V2FCrcValid(errorInfo0))
		if(V2FSpareChunkValid(errorInfo0))
			if(V2FPageChunkValid(errorInfo1))
				return EI_PASS;

	return EI_FAIL;
}

int ExeLowLevelReqPerDie(int chNo, int wayNo, int reqStatus)
{
	int front, tempLun, tempRowAddr, blockNo, entry, completion;

	switch(dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus)
	{
		case DS_IDLE:
			if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
			{
				if(PopFromReqQueue(chNo, wayNo))
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo] = RETRY_LIMIT;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_EXE;
				}
			}
			else
			{
				PopFromSubReqQueue(chNo, wayNo);
				retryLimitTable->retryLimitEntry[chNo][wayNo] = RETRY_LIMIT;
				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_EXE;
			}
			break;
		case DS_EXE:
			if(reqStatus == RS_DONE)
			{
				front = rqPointer->rqPointerEntry[chNo][wayNo].front;

				if(reqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTrigger)
					reqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;
				else
					rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;

					front = rqPointer->rqPointerEntry[chNo][wayNo].front;
					reqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
					if(reqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTransfer)
					{
						reqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTrigger;
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_TR_FAIL;
					}
					else
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_FAIL;
				}
				else
				{
					front = rqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_EXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",reqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, reqQueue->reqEntry[front][chNo][wayNo].rowAddr, completion);

					rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_WARNING)
			{
				front = rqPointer->rqPointerEntry[chNo][wayNo].front;
				tempLun = reqQueue->reqEntry[front][chNo][wayNo].rowAddr / LUN_1_BASE_ADDR;
				tempRowAddr = reqQueue->reqEntry[front][chNo][wayNo].rowAddr % LUN_1_BASE_ADDR;
				blockNo = tempLun * MAX_BLOCK_NUM_PER_LUN + tempRowAddr / PAGE_NUM_PER_MLC_BLOCK;

				xil_printf("RS_WARNING - bad block manage [chNo %x wayNo %x phyBlock %x Rowaddr %x]\r\n",chNo, wayNo, blockNo, reqQueue->reqEntry[front][chNo][wayNo].rowAddr);

				for(entry=0; entry<REQ_QUEUE_DEPTH; ++entry)
				{
					if(newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] == 0xffffffff)
					{
						newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] = blockNo;
						break;
					}
					else if(newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] == blockNo)
						break;
				}

				rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;

				badBlockUpdate = 1;
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
		case DS_TR_FAIL:
			PopFromReqQueue(chNo, wayNo);
			dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_TR_REEXE;
			break;
		case DS_TR_REEXE:
			if(reqStatus == RS_DONE)
			{
				front = rqPointer->rqPointerEntry[chNo][wayNo].front;
				reqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_FAIL;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;
					front = rqPointer->rqPointerEntry[chNo][wayNo].front;
					reqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;

					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_TR_FAIL;
				}
				else
				{
					front = rqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_TR_REEXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",reqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, reqQueue->reqEntry[front][chNo][wayNo].rowAddr, completion);

					rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
		case DS_FAIL:
			PopFromReqQueue(chNo, wayNo);
			dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_REEXE;

			break;
		case DS_REEXE:
			if(reqStatus == RS_DONE)
			{
				front = rqPointer->rqPointerEntry[chNo][wayNo].front;

				if(reqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTrigger)
					reqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;
				else
					rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;
					front = rqPointer->rqPointerEntry[chNo][wayNo].front;

					reqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
					if(reqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTransfer)
					{
						reqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTrigger;
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_TR_FAIL;
					}
					else
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_FAIL;
				}
				else
				{
					front = rqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_REEXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",reqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, reqQueue->reqEntry[front][chNo][wayNo].rowAddr, completion);

					rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_WARNING)
			{
				front = rqPointer->rqPointerEntry[chNo][wayNo].front;
				tempLun = reqQueue->reqEntry[front][chNo][wayNo].rowAddr / LUN_1_BASE_ADDR;
				tempRowAddr = reqQueue->reqEntry[front][chNo][wayNo].rowAddr % LUN_1_BASE_ADDR;
				blockNo = tempLun * MAX_BLOCK_NUM_PER_LUN + tempRowAddr / PAGE_NUM_PER_MLC_BLOCK;

				xil_printf("RS_WARNING - bad block manage [chNo %x wayNo %x phyBlock %x Rowaddr %x]\r\n",chNo, wayNo, blockNo, reqQueue->reqEntry[front][chNo][wayNo].rowAddr);

				for(entry=0; entry<REQ_QUEUE_DEPTH; ++entry)
				{
					if(newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] == 0xffffffff)
					{
						newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] = blockNo;
						break;
					}
					else if(newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] == blockNo)
						break;
				}

				rqPointer->rqPointerEntry[chNo][wayNo].front = (rqPointer->rqPointerEntry[chNo][wayNo].front + 1) % REQ_QUEUE_DEPTH;
				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;

				badBlockUpdate = 1;
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
		case DS_SUB_EXE:
			if(reqStatus == RS_DONE)
			{
				front = srqPointer->rqPointerEntry[chNo][wayNo].front;
				if(subReqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTrigger)
					subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;
				else if(subReqQueue->reqEntry[front][chNo][wayNo].request == LLSCommand_ReadRawPage)
					subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransferRaw;
				else
					srqPointer->rqPointerEntry[chNo][wayNo].front = (srqPointer->rqPointerEntry[chNo][wayNo].front + 1) % SUB_REQ_QUEUE_DEPTH;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;

					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					subReqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
					if(subReqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTransfer)
					{
						subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTrigger;
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_TR_FAIL;
					}
					else
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_FAIL;
				}
				else
				{
					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_SUB_EXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",subReqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, subReqQueue->reqEntry[front][chNo][wayNo].rowAddr, completion);

					if(subReqQueue->reqEntry[front][chNo][wayNo].request == LLSCommand_ReadRawPage)
					{
						unsigned char* badCheck = (unsigned char*)(subReqQueue->reqEntry[front][chNo][wayNo].pageDataBuf);
						*badCheck = 0;
					}

					srqPointer->rqPointerEntry[chNo][wayNo].front = (srqPointer->rqPointerEntry[chNo][wayNo].front + 1) % SUB_REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
		case DS_SUB_TR_FAIL:
			PopFromSubReqQueue(chNo, wayNo);
			dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_TR_REEXE;
			break;
		case DS_SUB_TR_REEXE:
			if(reqStatus == RS_DONE)
			{
				front = srqPointer->rqPointerEntry[chNo][wayNo].front;
				subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_FAIL;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;

					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					subReqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;

					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_TR_FAIL;
				}
				else
				{
					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_SUB_TR_REEXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",subReqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, subReqQueue->reqEntry[front][chNo][wayNo].rowAddr,completion);

					srqPointer->rqPointerEntry[chNo][wayNo].front = (srqPointer->rqPointerEntry[chNo][wayNo].front + 1) % SUB_REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
		case DS_SUB_FAIL:
			PopFromSubReqQueue(chNo, wayNo);
			dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_REEXE;
			break;
		case DS_SUB_REEXE:
			if(reqStatus == RS_DONE)
			{
				front = srqPointer->rqPointerEntry[chNo][wayNo].front;
				if(subReqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTrigger)
					subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransfer;
				else if(subReqQueue->reqEntry[front][chNo][wayNo].request == LLSCommand_ReadRawPage)
					subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTransferRaw;
				else
					srqPointer->rqPointerEntry[chNo][wayNo].front = (srqPointer->rqPointerEntry[chNo][wayNo].front + 1) % SUB_REQ_QUEUE_DEPTH;

				dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
			}
			else if(reqStatus == RS_FAIL)
			{
				if(retryLimitTable->retryLimitEntry[chNo][wayNo] > 0)
				{
					retryLimitTable->retryLimitEntry[chNo][wayNo]--;

					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					subReqQueue->reqEntry[front][chNo][wayNo].statusOption = STATUS_CHECK;
					if(subReqQueue->reqEntry[front][chNo][wayNo].request == V2FCommand_ReadPageTransfer)
					{
						subReqQueue->reqEntry[front][chNo][wayNo].request = V2FCommand_ReadPageTrigger;
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_TR_FAIL;
					}
					else
						dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_SUB_FAIL;
				}
				else
				{
					front = srqPointer->rqPointerEntry[chNo][wayNo].front;
					completion = completeTable->completeEntry[chNo][wayNo];

					xil_printf("DS_SUB_REEXE Request %d Fail - ch %d way %d rowAddr %x / status %x \r\n",subReqQueue->reqEntry[front][chNo][wayNo].request, chNo, wayNo, subReqQueue->reqEntry[front][chNo][wayNo].rowAddr, completion);

					if(subReqQueue->reqEntry[front][chNo][wayNo].request == LLSCommand_ReadRawPage)
					{
						unsigned char* badCheck = (unsigned char*)(subReqQueue->reqEntry[front][chNo][wayNo].pageDataBuf);
						*badCheck = 0;
					}

					srqPointer->rqPointerEntry[chNo][wayNo].front = (srqPointer->rqPointerEntry[chNo][wayNo].front + 1) % SUB_REQ_QUEUE_DEPTH;
					dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
				}
			}
			else if(reqStatus == RS_RUNNING)
				break;
			else
				xil_printf("Wrong request status \r\n");
			break;
	}

	return 1;
}



void LinkToIdle(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].idleTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].idleTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].idleTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].idleTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].idleHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].idleTail = wayNo;
	}
}

void LinkToStatusReport(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].statusReportTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].statusReportTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].statusReportTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = wayNo;
	}
}

void LinkToNvmeDma(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail = wayNo;
	}
}

void LinkToNandTrigger(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail = wayNo;
	}
}

void LinkToNandTrigNTrans(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail = wayNo;
	}
}

void LinkToNandTransfer(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail = wayNo;
	}
}

void LinkToNandStatus(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail = wayNo;
	}
}

void LinkToNandErase(unsigned int chNo, unsigned int wayNo)
{
	if(wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail != 0xf)
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail].nextWay = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail = wayNo;
	}
	else
	{
		dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay =  0xf;
		dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay =  0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead = wayNo;
		wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail = wayNo;
	}
}

void FindPriorityTable(int chNo, int wayNo, int firstQueue)
{
	unsigned int request, empty;

	if(firstQueue == REQ_QUEUE)
	{
		empty = rqPointer->rqPointerEntry[chNo][wayNo].front ==  rqPointer->rqPointerEntry[chNo][wayNo].rear;
		if(empty)
		{
			dieStatusTable->dieStatusEntry[chNo][wayNo].reqQueueEmpty = 1;
			dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect = SUB_REQ_QUEUE;
			empty = srqPointer->rqPointerEntry[chNo][wayNo].front ==  srqPointer->rqPointerEntry[chNo][wayNo].rear;
			if(empty)
			{
				dieStatusTable->dieStatusEntry[chNo][wayNo].subReqQueueEmpty = 1;
				LinkToIdle(chNo, wayNo);
				return;
			}
			request = subReqQueue->reqEntry[srqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].request;
		}
		else
		{
			dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect = REQ_QUEUE;
			request = reqQueue->reqEntry[rqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].request;
		}
	}
	else
	{
		empty = srqPointer->rqPointerEntry[chNo][wayNo].front ==  srqPointer->rqPointerEntry[chNo][wayNo].rear;
		if(empty)
		{
			dieStatusTable->dieStatusEntry[chNo][wayNo].subReqQueueEmpty = 1;
			dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect = REQ_QUEUE;
			empty = rqPointer->rqPointerEntry[chNo][wayNo].front ==  rqPointer->rqPointerEntry[chNo][wayNo].rear;
			if(empty)
			{
				dieStatusTable->dieStatusEntry[chNo][wayNo].reqQueueEmpty = 1;
				LinkToIdle(chNo, wayNo);
				return;
			}
			request = reqQueue->reqEntry[rqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].request;
		}
		else
		{
			dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect = SUB_REQ_QUEUE;
			request = subReqQueue->reqEntry[srqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].request;
		}
	}

	if(request >= LLSCommand_RxDMA)
		LinkToNvmeDma(chNo, wayNo);
	else if((request == V2FCommand_ReadPageTrigger) || (request == LLSCommand_ReadRawPage))
		LinkToNandTrigger(chNo, wayNo);
	else if((request == V2FCommand_ReadPageTransfer) || (request == V2FCommand_ReadPageTransferRaw))
		LinkToNandTransfer(chNo, wayNo);
	else if(request == V2FCommand_ProgramPage)
		LinkToNandTrigNTrans(chNo, wayNo);
	else if(request == V2FCommand_BlockErase)
		LinkToNandErase(chNo, wayNo);
	else
		LinkToNandStatus(chNo, wayNo);
}

int ExeLowLevelReqPerCh(int chNo, int firstQueue)
{
	int wayNo, idleWay, nextWay, enable, reqStatus, statusOption;
	unsigned int readyBusy;

	if(wayPriorityTable->wayPriorityEntry[chNo].idleHead != 0xf)
	{
		wayNo = wayPriorityTable->wayPriorityEntry[chNo].idleHead;
		idleWay = 0;

		while(wayNo != 0xf)
		{
			enable = (rqPointer->rqPointerEntry[chNo][wayNo].rear != rqPointer->rqPointerEntry[chNo][wayNo].front) || (srqPointer->rqPointerEntry[chNo][wayNo].rear != srqPointer->rqPointerEntry[chNo][wayNo].front);

			if(enable)
			{
				if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].idleTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].idleHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				}
				else
				{
					wayPriorityTable->wayPriorityEntry[chNo].idleHead = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].idleTail = 0xf;
				}

				nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				FindPriorityTable(chNo, wayNo, firstQueue);
				wayNo = nextWay;
			}
			else
			{
				idleWay++;
				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}

		if(idleWay == WAY_NUM)
			return 0;
	}
	if(wayPriorityTable->wayPriorityEntry[chNo].statusReportHead != 0xf)
	{
		readyBusy = V2FReadyBusyAsync(chCtlReg[chNo]);
		wayNo = wayPriorityTable->wayPriorityEntry[chNo].statusReportHead;

		while(wayNo != 0xf)
		{
			if ((readyBusy >> wayNo) & 1)
			{
				if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
				{
					 reqStatus = CheckReqStatusAsync(chNo, wayNo);
					 statusOption =  reqQueue->reqEntry[rqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].statusOption;
				}
				else
				{
					 reqStatus = CheckSubReqStatusAsync(chNo, wayNo);
					 statusOption =  subReqQueue->reqEntry[srqPointer->rqPointerEntry[chNo][wayNo].front][chNo][wayNo].statusOption;
				}

				if(reqStatus != RS_RUNNING)
				{
					if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					}
					else
					{
						wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = 0xf;
					}

					ExeLowLevelReqPerDie(chNo, wayNo, reqStatus);

					nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					FindPriorityTable(chNo, wayNo, firstQueue);
					wayNo = nextWay;
				}
				else if(statusOption == STATUS_CHECK)
				{
					if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					}
					else
					{
						wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = 0xf;
					}

					nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					LinkToNandStatus(chNo, wayNo);
					wayNo = nextWay;
				}
				else
					wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
			else
				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
		}
	}
	if(wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead != 0xf)
	{
		wayNo = wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead;

		while(wayNo != 0xf)
		{
			if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
				enable = CheckDMA(chNo, wayNo);
			else
				assert(!"[WARNING] Wrong request. [WARNING]");

			if(enable)
			{
				if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				}
				else
				{
					wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail = 0xf;
				}

				ExeLowLevelReqPerDie(chNo, wayNo, NONE);

				nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				FindPriorityTable(chNo, wayNo, firstQueue);
				wayNo = nextWay;
			}
			else
				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
		}
	}
	if(!V2FIsControllerBusy(chCtlReg[chNo]))
	{
		if(wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead != 0xf)
		{
			if(beforeNandReset)
				readyBusy = 0xffffffff;
			else
				readyBusy = V2FReadyBusyAsync(chCtlReg[chNo]);

			wayNo = wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead;

			while(wayNo != 0xf)
			{
				if((readyBusy >> wayNo) & 1)
				{
					if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					}
					else
					{
						wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail = 0xf;
					}

					if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
						 reqStatus = CheckReqStatusAsync(chNo, wayNo);
					else
						 reqStatus = CheckSubReqStatusAsync(chNo, wayNo);

					LinkToStatusReport(chNo, wayNo);

					if(V2FIsControllerBusy(chCtlReg[chNo]))
						return 1;
				}

				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}
		if(wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead != 0xf)
		{
			wayNo = wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead;
			while(wayNo != 0xf)
			{
				if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				}
				else
				{
					wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail = 0xf;
				}

				ExeLowLevelReqPerDie(chNo, wayNo, NONE);
				LinkToNandStatus(chNo, wayNo);

				if(V2FIsControllerBusy(chCtlReg[chNo]))
					return 1;

				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}

		if(wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead != 0xf)
		{
			wayNo = wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead;
			while(wayNo != 0xf)
			{
				if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
				}
				else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
				{
					dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
				}
				else
				{
					wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead = 0xf;
					wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail = 0xf;
				}

				ExeLowLevelReqPerDie(chNo, wayNo, NONE);
				LinkToNandStatus(chNo, wayNo);

				if(V2FIsControllerBusy(chCtlReg[chNo]))
					return 1;

				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}
		if(wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead != 0xf)
		{
			wayNo = wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead;
			while(wayNo != 0xf)
			{
				if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
					enable = CheckDMA(chNo, wayNo);
				else
					enable = 1;

				if(enable)
				{
					if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					}
					else
					{
						wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail = 0xf;
					}

					ExeLowLevelReqPerDie(chNo, wayNo, NONE);
					LinkToNandStatus(chNo, wayNo);

					if(V2FIsControllerBusy(chCtlReg[chNo]))
						return 1;
				}

				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}
		if(wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead != 0xf)
		{
			wayNo = wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead;
			while(wayNo != 0xf)
			{
				if(dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect == REQ_QUEUE)
					enable = CheckDMA(chNo, wayNo);
				else
					enable = 1;

				if(enable)
				{
					if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay == 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay != 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay].nextWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail = dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay;
					}
					else if((dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay != 0xf) && (dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay == 0xf))
					{
						dieStatusTable->dieStatusEntry[chNo][dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay].prevWay = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
					}
					else
					{
						wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead = 0xf;
						wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail = 0xf;
					}

					ExeLowLevelReqPerDie(chNo, wayNo, NONE);
					LinkToStatusReport(chNo, wayNo);

					if(V2FIsControllerBusy(chCtlReg[chNo]))
						return 1;
				}

				wayNo = dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay;
			}
		}
	}
	return 1;
}

void ExeLowLevelReq(int firstQueue)
{
	int chNo;

	reservedReq = 0;
	for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
		reservedReq += ExeLowLevelReqPerCh(chNo, firstQueue);

	if(badBlockUpdate)
		EmptyLowLevelQ(firstQueue);
}

void EmptyReqQ()
{
	int chNo, wayNo, emptyCount;

	emptyCount = 0;
	while (emptyCount < DIE_NUM)
	{
		reservedReq = 0;
		emptyCount = 0;
		for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
		{
			reservedReq += ExeLowLevelReqPerCh(chNo, REQ_QUEUE);

			for(wayNo = 0; wayNo < WAY_NUM; ++wayNo)
				emptyCount += dieStatusTable->dieStatusEntry[chNo][wayNo].reqQueueEmpty;
		}
	}

	if(badBlockUpdate)
		EmptyLowLevelQ(REQ_QUEUE);
}

void EmptySubReqQ()
{
	int chNo, wayNo, emptyCount;

	emptyCount = 0;
	while (emptyCount < DIE_NUM)
	{
		reservedReq = 0;
		emptyCount = 0;
		for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
		{
			reservedReq += ExeLowLevelReqPerCh(chNo, SUB_REQ_QUEUE);

			for(wayNo = 0; wayNo < WAY_NUM; ++wayNo)
				emptyCount += dieStatusTable->dieStatusEntry[chNo][wayNo].subReqQueueEmpty;
		}
	}

	if(badBlockUpdate)
		EmptyLowLevelQ(SUB_REQ_QUEUE);
}

void EmptyLowLevelQ(int firstQueue)
{
	int chNo, wayNo, entry, loop, dataSize;
	unsigned int diePpn, tempBuffer;
	unsigned char* shifter;
	unsigned int badBlockTableUpdate[CHANNEL_NUM][WAY_NUM];
	unsigned int realBlockNoPerDie;

	reservedReq = 1;
	while(reservedReq)
	{
		reservedReq = 0;
		for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
			reservedReq += ExeLowLevelReqPerCh(chNo, firstQueue);
	}


	if(badBlockUpdate)
	{
		badBlockUpdate = 0;
		realBlockNoPerDie = MAX_BLOCK_NUM_PER_LUN * MAX_LUN_NUM_PER_DIE;

		//read bad block marks
		loop = 0;
		dataSize = realBlockNoPerDie;
		diePpn = metadataBlockNo * PAGE_NUM_PER_SLC_BLOCK + 1; //bad block table is stored in LSB page, start at second page

		while(dataSize>0)
		{
			for(wayNo = 0; wayNo < WAY_NUM; wayNo++)
				for(chNo = 0; chNo < CHANNEL_NUM; chNo++)
				{
					tempBuffer = GC_BUFFER_ADDR + (wayNo * CHANNEL_NUM + chNo) * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + loop * PAGE_SIZE;
					PushToSubReqQueue(chNo, wayNo, LLSCommand_ReadLsbPage, diePpn, tempBuffer, SPARE_ADDR);	//spare region address is test address

					badBlockTableUpdate[chNo][wayNo] = 0;
				}

			diePpn++;
			loop++;
			dataSize -= PAGE_SIZE;
		}

		reservedReq = 1;
		while(reservedReq)
		{
			reservedReq = 0;
			for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
				reservedReq += ExeLowLevelReqPerCh(chNo, firstQueue);
		}


		for(entry = 0; entry < REQ_QUEUE_DEPTH; ++entry)
			for(wayNo = 0; wayNo <WAY_NUM; ++wayNo)
				for(chNo = 0; chNo < CHANNEL_NUM; ++chNo)
					if(newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] != 0xffffffff)
					{
						shifter = (unsigned char*)(GC_BUFFER_ADDR + newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] + (wayNo * CHANNEL_NUM + chNo) * (realBlockNoPerDie / PAGE_SIZE + 1)  * PAGE_SIZE);
						*shifter = 1;

						UpdateBadBlockTable(chNo, wayNo, newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo]);
						newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] = 0xffffffff;

						badBlockTableUpdate[chNo][wayNo] = 1;
					}


		// save bad block mark
		loop = 0;
		dataSize = realBlockNoPerDie;
		diePpn = metadataBlockNo * PAGE_NUM_PER_SLC_BLOCK + 1; //bad block table is stored in LSB page, start at second page

		while(dataSize>0)
		{
			for(wayNo = 0; wayNo < WAY_NUM; wayNo++)
				for(chNo = 0; chNo < CHANNEL_NUM; chNo++)
					if(badBlockTableUpdate[chNo][wayNo])
					{
						if(loop == 0)
							PushToSubReqQueue(chNo, wayNo, V2FCommand_BlockErase, metadataBlockNo * PAGE_NUM_PER_BLOCK, NONE, NONE);

						tempBuffer = GC_BUFFER_ADDR + (wayNo * CHANNEL_NUM + chNo) * (realBlockNoPerDie / PAGE_SIZE + 1)  * PAGE_SIZE + loop * PAGE_SIZE;
						PushToSubReqQueue(chNo, wayNo, LLSCommand_WriteLsbPage, diePpn, tempBuffer, SPARE_ADDR); 	//spare region address is test address
					}

			diePpn++;
			loop++;
			dataSize -= PAGE_SIZE;
		}

		reservedReq = 1;
	}
}

