//////////////////////////////////////////////////////////////////////////////////
// page_map.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//                Sanghyuk Jung <shjung@enc.hanyang.ac.kr>
//                Gyeongyong Lee <gylee@enc.hanyang.ac.kr>
//				Jaewook Kwak	<jwkwak@enc.hanyang.ac.kr>
//
// This file is part of Cosmos OpenSSD.
//
// Cosmos OpenSSD is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// Cosmos OpenSSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cosmos OpenSSD; see the file COPYING.
// If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: ENC Lab. <http://enc.hanyang.ac.kr>
// Engineer: Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
//
// Project Name: Cosmos OpenSSD
// Design Name: Cosmos Firmware
// Module Name: Flash Translation Layer
// File Name: page_map.c
//
// Version: v1.5.0
//
// Description:
//   - initialize map tables
//	 - check bad blocks
//   - manage read/write request
//   - manage garbage collection
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.5.0
//	 - Bad block table is stored to LSB pages of a metadata block of each flash die
//
// * v1.4.0
//	 - Maximum count among bad block count of each die determines the bad block size to satisfy the feature of static mapping
//
// * v1.3.0
//	 - NVMe DMA generation process and DMA partial done check process is moved to low level scheduler
//   - header file for buffer is changed from "ia_lru_buffer.h" to "lru_buffer.h"
//	 - user can select whether delete existing bad block table
//	 - garbage collection is triggered at once for all NAND flash dies
//	 - valid pages are copied to current block until current block becomes closed block
//
// * v1.2.0
//   - DMA check options for low level requests are deleted
//   - DMA status information is saved for DMA partial done check process
//	 - DMA done check process is replaced by DMA partial done check process
//
// * v1.1.0
//   - PrePmRead and PmRead are modified for IALRU buffer
//   - DirtyPmWrite is deleted
//   - PmWrite is added for IALRU buffer
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#include "page_map.h"
#include "low_level_scheduler.h"
#include "memory_map.h"
#include "nvme/host_lld.h"
#include <assert.h>

struct pmArray* pageMap;
struct bmArray* blockMap;
struct dieArray* dieBlock;
struct gcArray* gcMap;

// A free block selected to save meta-data
unsigned int metadataBlockNo;

void InitPageMap()
{
	// page status initialization, allows lpn, ppn access
	int i, j;
	for(i=0 ; i<DIE_NUM ; i++)
	{
		for(j=0 ; j<PAGE_NUM_PER_DIE ; j++)
		{
			pageMap->pmEntry[i][j].ppn = 0xffffffff;

			pageMap->pmEntry[i][j].valid = 1;
			pageMap->pmEntry[i][j].lpn = 0x7fffffff;
		}
	}
}

void InitBlockMap(unsigned int badBlockTableAddr)
{
	int i, j, phyBlock;

	xil_printf("Press 'X' to re-make the bad block table.\r\n");
	if (inbyte() == 'X')
	{
		for (i = 0; i < BLOCK_NUM_PER_DIE; ++i)
			for (j = 0; j < DIE_NUM; ++j)
				PushToSubReqQueue(j % CHANNEL_NUM, j / CHANNEL_NUM, V2FCommand_BlockErase, i*PAGE_NUM_PER_BLOCK, NONE, NONE);

		EmptyLowLevelQ(SUB_REQ_QUEUE);
		xil_printf("Done.\r\n");
	}

	RecoverBadBlockTable(badBlockTableAddr);

	xil_printf("[ block erasure start. ]\r\n");

	// block status initialization except bad block marks, allows only physical access
	for(i=0 ; i<BLOCK_NUM_PER_DIE ; i++)
	{
		for(j=0 ; j<DIE_NUM ; j++)
		{
			phyBlock = (i / BLOCK_NUM_PER_LUN) * MAX_BLOCK_NUM_PER_LUN + i % BLOCK_NUM_PER_LUN;
			if(phyBlock == metadataBlockNo)
				blockMap->bmEntry[j][i].free = 0;
			else
				blockMap->bmEntry[j][i].free = 1;

			blockMap->bmEntry[j][i].eraseCnt = 0;
			blockMap->bmEntry[j][i].invalidPageCnt = 0;
			blockMap->bmEntry[j][i].currentPage = 0xffff;
			blockMap->bmEntry[j][i].prevBlock = 0xffffffff;
			blockMap->bmEntry[j][i].nextBlock = 0xffffffff;
		}
	}

	//initial block erase
	for (i = 0; i < BLOCK_NUM_PER_DIE; ++i)
		for (j = 0; j < DIE_NUM; ++j)
		{
			phyBlock = (i / BLOCK_NUM_PER_LUN) * MAX_BLOCK_NUM_PER_LUN + i % BLOCK_NUM_PER_LUN;
			if (!blockMap->bmEntry[j][i].bad && (phyBlock != metadataBlockNo))
				PushToSubReqQueue(j % CHANNEL_NUM, j / CHANNEL_NUM, V2FCommand_BlockErase, i*PAGE_NUM_PER_BLOCK, NONE, NONE);
		}

	EmptyLowLevelQ(SUB_REQ_QUEUE);

	xil_printf("[ entire block erasure completed. ]\r\n");
}

void RecoverBadBlockTable(unsigned int readBufAddr)
{
	unsigned int dieNo, diePpn, blockNo, tempBuffer, maxBadBlockCount, phyBlockNo, checkBadBlock, realBlockNoPerDie;
	unsigned char* shifter = (unsigned char*)readBufAddr;
	int loop, chNo, wayNo, dataSize;
	unsigned int badBlockCount[DIE_NUM];
	unsigned int badBlockTableExist[DIE_NUM];
	unsigned int tempBadMark[DIE_NUM];
	unsigned char* markPointer1;
	unsigned char* markPointer2;

	realBlockNoPerDie = MAX_BLOCK_NUM_PER_LUN * MAX_LUN_NUM_PER_DIE;

	//read badblock marks
	loop = 0;
	dataSize = realBlockNoPerDie;
	diePpn = metadataBlockNo * PAGE_NUM_PER_SLC_BLOCK + 1;	//bad block table is stored in LSB page, start at second page

	while(dataSize>0)
	{
		for(wayNo = 0; wayNo < WAY_NUM; wayNo++)
			for(chNo = 0; chNo < CHANNEL_NUM; chNo++)
			{
				tempBuffer = readBufAddr + (wayNo * CHANNEL_NUM + chNo) * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + loop * PAGE_SIZE;
				PushToSubReqQueue(chNo, wayNo, LLSCommand_ReadLsbPage, diePpn, tempBuffer, SPARE_ADDR);	// bad block table is stored in LSB page, spare region address is test address
			}

		diePpn++;
		loop++;
		dataSize -= PAGE_SIZE;
	}

	EmptyLowLevelQ(SUB_REQ_QUEUE);

	checkBadBlock = 0;
	for(dieNo=0; dieNo<DIE_NUM; dieNo++)
	{
		shifter = (unsigned char*)(readBufAddr + dieNo * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE);
		badBlockCount[dieNo] = 0;

		if((*shifter==0)||(*shifter==1))
		{
			xil_printf("[ bad block table of ch %d way %d exists.]\r\n",dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM);
			badBlockTableExist[dieNo] = 1;

			for(blockNo=0; blockNo<BLOCK_NUM_PER_DIE; blockNo++)
			{
				phyBlockNo = (blockNo / BLOCK_NUM_PER_LUN) * MAX_BLOCK_NUM_PER_LUN + blockNo % BLOCK_NUM_PER_LUN;
				shifter = (unsigned char*)(readBufAddr + phyBlockNo + dieNo * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE);
				blockMap->bmEntry[dieNo][blockNo].bad = *shifter;
				if(blockMap->bmEntry[dieNo][blockNo].bad)
				{
					xil_printf("	bad block: ch %d Way %d Block %d (phyBlock %d)  \r\n",dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM, blockNo, phyBlockNo);
					badBlockCount[dieNo]++;
				}
			}

			xil_printf("[ bad blocks of ch %d way %d are checked. ]\r\n",dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM);
		}
		else
		{
			xil_printf("[ bad block table of ch %d way %d does not exist.]\r\n",dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM);
			badBlockTableExist[dieNo] = 0;
			checkBadBlock = 1;
		}
	}

	//if bad block table dose not exist
	if(checkBadBlock)
	{
		for(phyBlockNo = 0; phyBlockNo < realBlockNoPerDie; phyBlockNo++)
		{
			for(dieNo=0; dieNo < DIE_NUM; dieNo++)
				if(!badBlockTableExist[dieNo])
				{
					tempBadMark[dieNo] = 0;
					tempBuffer =  readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE);

					PushToSubReqQueue(dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM, LLSCommand_ReadRawPage, phyBlockNo*PAGE_NUM_PER_SLC_BLOCK, tempBuffer, tempBuffer + PAGE_SIZE);
				}

			EmptyLowLevelQ(SUB_REQ_QUEUE);

			for(dieNo=0; dieNo < DIE_NUM; dieNo++)
				if(!badBlockTableExist[dieNo])
				{
					markPointer1 = (unsigned char*)(readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE) + BAD_BLOCK_MARK_LOCATION1);
					markPointer2 = (unsigned char*)(readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE) + BAD_BLOCK_MARK_LOCATION2);

					if((*markPointer1 == 0xff) && (*markPointer2 == 0xff))
					{
						tempBuffer =  readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE);
						PushToSubReqQueue(dieNo % CHANNEL_NUM, dieNo / CHANNEL_NUM, LLSCommand_ReadRawPage, ((phyBlockNo+1)*PAGE_NUM_PER_SLC_BLOCK - 1), tempBuffer, tempBuffer + PAGE_SIZE);
					}
					else
					{
						xil_printf("	bad block is detected: Ch %d Way %d phyBlock %d",dieNo%CHANNEL_NUM, dieNo/CHANNEL_NUM, phyBlockNo);
						tempBadMark[dieNo] = 1;

						if((phyBlockNo % MAX_BLOCK_NUM_PER_LUN) < BLOCK_NUM_PER_LUN)
						{
							blockNo = (phyBlockNo / MAX_BLOCK_NUM_PER_LUN) * BLOCK_NUM_PER_LUN + phyBlockNo % MAX_BLOCK_NUM_PER_LUN;
							xil_printf(" (Block %d) \r\n", blockNo);
						}
						else
							xil_printf("\r\n");
					}
				}

			EmptyLowLevelQ(SUB_REQ_QUEUE);

			for(dieNo=0; dieNo < DIE_NUM; dieNo++)
				if(!badBlockTableExist[dieNo])
				{
					markPointer1 = (unsigned char*)(readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE) + BAD_BLOCK_MARK_LOCATION1);
					markPointer2 = (unsigned char*)(readBufAddr + DIE_NUM * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + dieNo*(PAGE_SIZE+SPARE_SIZE) + BAD_BLOCK_MARK_LOCATION2);

					if(!((*markPointer1 == 0xff) && (*markPointer2 == 0xff)) && (!tempBadMark[dieNo]))
					{
						xil_printf("	bad block is detected: Ch %d Way %d phyBlock %d ",dieNo%CHANNEL_NUM, dieNo/CHANNEL_NUM, phyBlockNo);
						tempBadMark[dieNo] = 1;

						if((phyBlockNo % MAX_BLOCK_NUM_PER_LUN) < BLOCK_NUM_PER_LUN)
						{
							blockNo = (phyBlockNo / MAX_BLOCK_NUM_PER_LUN) * BLOCK_NUM_PER_LUN + phyBlockNo % MAX_BLOCK_NUM_PER_LUN;
							xil_printf(" (Block %d) \r\n", blockNo);
						}
						else
							xil_printf("\r\n");
					}

					shifter= (unsigned char*)(readBufAddr + phyBlockNo + dieNo *  (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE);//gather badblock mark at GC buffer
					*shifter = tempBadMark[dieNo];

					if((phyBlockNo % MAX_BLOCK_NUM_PER_LUN) < BLOCK_NUM_PER_LUN)
					{
						blockNo = (phyBlockNo / MAX_BLOCK_NUM_PER_LUN) * BLOCK_NUM_PER_LUN + phyBlockNo % MAX_BLOCK_NUM_PER_LUN;
						blockMap->bmEntry[dieNo][blockNo].bad = tempBadMark[dieNo];

						if(tempBadMark[dieNo])
							badBlockCount[dieNo]++;
					}
				}
		}

		// save bad block mark
		loop = 0;
		dataSize = realBlockNoPerDie;
		diePpn = metadataBlockNo * PAGE_NUM_PER_SLC_BLOCK + 1; //bad block table is stored in LSB page, start at second page

		while(dataSize>0)
		{
			for(wayNo = 0; wayNo < WAY_NUM; wayNo++)
				for(chNo = 0; chNo < CHANNEL_NUM; chNo++)
					if(!badBlockTableExist[wayNo * CHANNEL_NUM + chNo])
					{
						if(loop == 0)
							PushToSubReqQueue(chNo, wayNo, V2FCommand_BlockErase, metadataBlockNo * PAGE_NUM_PER_BLOCK, NONE, NONE);

						tempBuffer = readBufAddr + (wayNo * CHANNEL_NUM + chNo) * (realBlockNoPerDie / PAGE_SIZE + 1) * PAGE_SIZE + loop * PAGE_SIZE;
						PushToSubReqQueue(chNo, wayNo, LLSCommand_WriteLsbPage, diePpn, tempBuffer, SPARE_ADDR); 	//bad block table is stored in LSB page, spare region address is test address
					}

			diePpn++;
			loop++;
			dataSize -= PAGE_SIZE;
		}

		EmptyLowLevelQ(SUB_REQ_QUEUE);
	}

	maxBadBlockCount = 0;
	for(dieNo=0; dieNo < DIE_NUM; dieNo++)
	{
		if(!badBlockTableExist[dieNo])
			xil_printf("[ bad block table of Ch %d Way %d is saved. ]\r\n",dieNo%CHANNEL_NUM, dieNo/CHANNEL_NUM);

		if(maxBadBlockCount < badBlockCount[dieNo])
			maxBadBlockCount = badBlockCount[dieNo];
	}

	badBlockSize = maxBadBlockCount * DIE_NUM * BLOCK_SIZE_MB;
}

void InitDieBlock()
{
	int i,j,phyBlock;
	for(i=0 ; i<DIE_NUM ; i++)
		for(j=0 ; j<BLOCK_NUM_PER_DIE ; j++)
		{
			phyBlock = (j / BLOCK_NUM_PER_LUN) * MAX_BLOCK_NUM_PER_LUN + j % BLOCK_NUM_PER_LUN;
			if ((!blockMap->bmEntry[i][j].bad) &&  (phyBlock != metadataBlockNo))
			{
				dieBlock->dieEntry[i].currentBlock = j;
				blockMap->bmEntry[i][j].free = 0;
				break;
			}
		}

	for(i=0 ; i<DIE_NUM; i++)
		for(j=BLOCK_NUM_PER_DIE-1; j>=0 ; j--)
		{
			phyBlock = (j / BLOCK_NUM_PER_LUN) * MAX_BLOCK_NUM_PER_LUN + j % BLOCK_NUM_PER_LUN;
			if ((!blockMap->bmEntry[i][j].bad) && (phyBlock != metadataBlockNo))
			{
				dieBlock->dieEntry[i].freeBlock = j;
				blockMap->bmEntry[i][j].free = 0;
				break;
			}
		}
}

void InitGcMap()
{
	// gc table status initialization
	int i, j;
	for(i=0 ; i<DIE_NUM ; i++)
	{
		for(j=0 ; j<PAGE_NUM_PER_BLOCK+1 ; j++)
		{
			gcMap->gcEntry[i][j].head = 0xffffffff;
			gcMap->gcEntry[i][j].tail = 0xffffffff;
		}
	}
}

int FindFreePage(unsigned int dieNo)
{
	unsigned int tempBlock;
	int i;

	if(blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage == PAGE_NUM_PER_BLOCK-1)
	{
		tempBlock = dieBlock->dieEntry[dieNo].currentBlock + 1;

		for(i=tempBlock; i<(tempBlock + BLOCK_NUM_PER_DIE) ; i++)
		{
			if((blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].free) && (!blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].bad))
			{
				blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].free = 0;
				dieBlock->dieEntry[dieNo].currentBlock = i % BLOCK_NUM_PER_DIE;

				blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage++;
				return (dieBlock->dieEntry[dieNo].currentBlock * PAGE_NUM_PER_BLOCK) + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage;
			}
		}
		GarbageCollection();

		blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage++;
		return (dieBlock->dieEntry[dieNo].currentBlock * PAGE_NUM_PER_BLOCK) + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage;
	}
	else
	{
		blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage++;
		return (dieBlock->dieEntry[dieNo].currentBlock * PAGE_NUM_PER_BLOCK) + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage;
	}
}

int PrePmRead(P_BUFFER_REQ_INFO bufCmd)
{
	LOW_LEVEL_REQ_INFO lowLevelCmd;
	unsigned int dieNo = bufCmd->lpn % DIE_NUM;
	unsigned int dieLpn = bufCmd->lpn / DIE_NUM;

	if(bufCmd->subReqSect == SECTOR_NUM_PER_PAGE)
	{
		lowLevelCmd.devAddr = bufCmd->devAddr;
		lowLevelCmd.cmdSlotTag = bufCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = bufCmd->startDmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect =  bufCmd->subReqSect;
		lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
		lowLevelCmd.request = LLSCommand_RxDMA;

		PushToReqQueue(&lowLevelCmd);
	}
	else
	{
		if (pageMap->pmEntry[dieNo][dieLpn].ppn != 0xffffffff)
		{
			lowLevelCmd.rowAddr = pageMap->pmEntry[dieNo][dieLpn].ppn;
			lowLevelCmd.spareDataBuf = SPARE_ADDR;
			lowLevelCmd.devAddr = bufCmd->devAddr;
			lowLevelCmd.cmdSlotTag = bufCmd->cmdSlotTag;
			lowLevelCmd.startDmaIndex = bufCmd->startDmaIndex;
			lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
			lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
			lowLevelCmd.subReqSect =  bufCmd->subReqSect;
			lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
			lowLevelCmd.request = V2FCommand_ReadPageTrigger;
			PushToReqQueue(&lowLevelCmd);

			lowLevelCmd.request = LLSCommand_RxDMA;
			PushToReqQueue(&lowLevelCmd);

		}
		else
		{
			lowLevelCmd.devAddr = bufCmd->devAddr;
			lowLevelCmd.cmdSlotTag = bufCmd->cmdSlotTag;
			lowLevelCmd.startDmaIndex = bufCmd->startDmaIndex;
			lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
			lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
			lowLevelCmd.subReqSect =  bufCmd->subReqSect;
			lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
			lowLevelCmd.request = LLSCommand_RxDMA;

			PushToReqQueue(&lowLevelCmd);
		}
	}

	reservedReq = 1;
	return 0;
}

int PmRead(P_BUFFER_REQ_INFO bufCmd)
{
	LOW_LEVEL_REQ_INFO lowLevelCmd;
	unsigned int dieNo = bufCmd->lpn % DIE_NUM;
	unsigned int dieLpn = bufCmd->lpn / DIE_NUM;

	if (pageMap->pmEntry[dieNo][dieLpn].ppn != 0xffffffff)
	{
		lowLevelCmd.rowAddr = pageMap->pmEntry[dieNo][dieLpn].ppn;
		lowLevelCmd.spareDataBuf = SPARE_ADDR;
		lowLevelCmd.devAddr = bufCmd->devAddr;
		lowLevelCmd.cmdSlotTag = bufCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = bufCmd->startDmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect =  bufCmd->subReqSect;
		lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
		lowLevelCmd.request = V2FCommand_ReadPageTrigger;
		PushToReqQueue(&lowLevelCmd);

		lowLevelCmd.request = LLSCommand_TxDMA;
		PushToReqQueue(&lowLevelCmd);
	}
	else
	{
		lowLevelCmd.devAddr = bufCmd->devAddr;
		lowLevelCmd.cmdSlotTag = bufCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = bufCmd->startDmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect =  bufCmd->subReqSect;
		lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
		lowLevelCmd.request = LLSCommand_TxDMA;

		PushToReqQueue(&lowLevelCmd);
	}

	reservedReq = 1;
	return 0;
}

int PmWrite(P_BUFFER_REQ_INFO bufCmd)
{
	LOW_LEVEL_REQ_INFO lowLevelCmd;
	unsigned int dieNo = bufCmd->lpn % DIE_NUM;
	unsigned int dieLpn = bufCmd->lpn / DIE_NUM;

	lowLevelCmd.rowAddr = FindFreePage(dieNo);
	lowLevelCmd.spareDataBuf = SPARE_ADDR;
	lowLevelCmd.bufferEntry = bufCmd->bufferEntry;
	lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
	lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
	lowLevelCmd.request = V2FCommand_ProgramPage;

	PushToReqQueue(&lowLevelCmd);
	UpdateMetaForInvalidate(bufCmd->lpn);

	// pageMap update
	pageMap->pmEntry[dieNo][dieLpn].ppn = lowLevelCmd.rowAddr;
	pageMap->pmEntry[dieNo][lowLevelCmd.rowAddr].lpn = dieLpn;

	reservedReq = 1;
	return 0;
}


int UpdateMetaForInvalidate(unsigned lpn)
{
	unsigned int dieNo = lpn % DIE_NUM;
	unsigned int dieLpn = lpn / DIE_NUM;

	if(pageMap->pmEntry[dieNo][dieLpn].ppn != 0xffffffff)
	{
		if (pageMap->pmEntry[dieNo][pageMap->pmEntry[dieNo][dieLpn].ppn].valid == 0)
			return 0;

		// GC victim block list management
		unsigned int diePbn = pageMap->pmEntry[dieNo][dieLpn].ppn / PAGE_NUM_PER_BLOCK;

		// unlink
		if((blockMap->bmEntry[dieNo][diePbn].nextBlock != 0xffffffff) && (blockMap->bmEntry[dieNo][diePbn].prevBlock != 0xffffffff))
		{
			blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].prevBlock].nextBlock = blockMap->bmEntry[dieNo][diePbn].nextBlock;
			blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].nextBlock].prevBlock = blockMap->bmEntry[dieNo][diePbn].prevBlock;
		}
		else if((blockMap->bmEntry[dieNo][diePbn].nextBlock == 0xffffffff) && (blockMap->bmEntry[dieNo][diePbn].prevBlock != 0xffffffff))
		{
			blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].prevBlock].nextBlock = 0xffffffff;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail = blockMap->bmEntry[dieNo][diePbn].prevBlock;
		}
		else if((blockMap->bmEntry[dieNo][diePbn].nextBlock != 0xffffffff) && (blockMap->bmEntry[dieNo][diePbn].prevBlock == 0xffffffff))
		{
			blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].nextBlock].prevBlock = 0xffffffff;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].head = blockMap->bmEntry[dieNo][diePbn].nextBlock;
		}
		else
		{
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].head = 0xffffffff;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail = 0xffffffff;
		}

		// invalidation update
		pageMap->pmEntry[dieNo][pageMap->pmEntry[dieNo][dieLpn].ppn].valid = 0;
		blockMap->bmEntry[dieNo][diePbn].invalidPageCnt++;

		// insertion
		if(gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail != 0xffffffff)
		{
			blockMap->bmEntry[dieNo][diePbn].prevBlock = gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail;
			blockMap->bmEntry[dieNo][diePbn].nextBlock = 0xffffffff;
			blockMap->bmEntry[dieNo][gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail].nextBlock = diePbn;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail = diePbn;
		}
		else
		{
			blockMap->bmEntry[dieNo][diePbn].prevBlock = 0xffffffff;
			blockMap->bmEntry[dieNo][diePbn].nextBlock = 0xffffffff;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].head = diePbn;
			gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][diePbn].invalidPageCnt].tail = diePbn;
		}

		return 1;
	}
	return 0;
}

void EraseBlock(unsigned int dieNo, unsigned int blockNo)
{
	// block map indicated blockNo initialization
	blockMap->bmEntry[dieNo][blockNo].free = 1;
	blockMap->bmEntry[dieNo][blockNo].eraseCnt++;
	blockMap->bmEntry[dieNo][blockNo].invalidPageCnt = 0;
	blockMap->bmEntry[dieNo][blockNo].currentPage = 0xffff;
	blockMap->bmEntry[dieNo][blockNo].prevBlock = 0xffffffff;
	blockMap->bmEntry[dieNo][blockNo].nextBlock = 0xffffffff;

	int i;
	for(i=0 ; i<PAGE_NUM_PER_BLOCK ; i++)
	{
		pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + i].valid = 1;
		pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + i].lpn = 0x7fffffff;
	}

	int chNo = dieNo % CHANNEL_NUM;
	int wayNo =  dieNo / CHANNEL_NUM;

	PushToSubReqQueue(chNo, wayNo, V2FCommand_BlockErase, blockNo * PAGE_NUM_PER_BLOCK, NONE, NONE);
}

void GarbageCollection()
{
	unsigned int victimBlock;
	unsigned int dieNo, pageCount, invalidPageCount, freePage, validPage, chNo, wayNo, lpn;
	unsigned char closedFlag = 0xff;

	EmptySubReqQ();
	for(dieNo = 0; dieNo < DIE_NUM; dieNo++)
	{
		for(invalidPageCount = PAGE_NUM_PER_BLOCK; invalidPageCount > 0 ; invalidPageCount--)
		{
			if((gcMap->gcEntry[dieNo][invalidPageCount].head != 0xffffffff) && (gcMap->gcEntry[dieNo][invalidPageCount].head != dieBlock->dieEntry[dieNo].currentBlock))
			{
				victimBlock = gcMap->gcEntry[dieNo][invalidPageCount].head;	// GC victim block

				// link setting
				if(blockMap->bmEntry[dieNo][victimBlock].nextBlock != 0xffffffff)
				{
					gcMap->gcEntry[dieNo][invalidPageCount].head = blockMap->bmEntry[dieNo][victimBlock].nextBlock;
					blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][victimBlock].nextBlock].prevBlock = 0xffffffff;
				}
				else
				{
					gcMap->gcEntry[dieNo][invalidPageCount].head = 0xffffffff;
					gcMap->gcEntry[dieNo][invalidPageCount].tail = 0xffffffff;
				}

				closedFlag = 0;
				if(blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage == (PAGE_NUM_PER_BLOCK - 1))
					closedFlag = 1;

				if(invalidPageCount != PAGE_NUM_PER_BLOCK)
				{
					for(pageCount=0 ; pageCount<PAGE_NUM_PER_BLOCK ; pageCount++)
					{
						if((pageMap->pmEntry[dieNo][(victimBlock * PAGE_NUM_PER_BLOCK) + pageCount].valid) && (pageMap->pmEntry[dieNo][(victimBlock * PAGE_NUM_PER_BLOCK) + pageCount].lpn != 0x7fffffff))
						{
							// page copy process
							validPage = victimBlock*PAGE_NUM_PER_BLOCK + pageCount;

							if(closedFlag == 0)
							{
								if(blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage == (PAGE_NUM_PER_BLOCK - 1))
								{
									closedFlag = 1;
									blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage++;
									freePage = dieBlock->dieEntry[dieNo].freeBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage;
								}
								else
								{
									blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage++;
									freePage = dieBlock->dieEntry[dieNo].currentBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage;
								}
							}
							else
							{
								blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage++;
								freePage = dieBlock->dieEntry[dieNo].freeBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage;
							}

							chNo = dieNo % CHANNEL_NUM;
							wayNo = dieNo / CHANNEL_NUM;

							PushToSubReqQueue(chNo, wayNo, V2FCommand_ReadPageTrigger, validPage, GC_BUFFER_ADDR + dieNo * PAGE_SIZE, SPARE_ADDR);
							PushToSubReqQueue(chNo, wayNo, V2FCommand_ProgramPage, freePage, GC_BUFFER_ADDR + dieNo * PAGE_SIZE, SPARE_ADDR);

							// pageMap, blockMap update
							lpn = pageMap->pmEntry[dieNo][validPage].lpn;

							pageMap->pmEntry[dieNo][lpn].ppn = freePage;
							pageMap->pmEntry[dieNo][freePage].lpn = lpn;
						}
						else if(pageMap->pmEntry[dieNo][(victimBlock * PAGE_NUM_PER_BLOCK) + pageCount].valid == 0)
						{
							lpn = pageMap->pmEntry[dieNo][(victimBlock * PAGE_NUM_PER_BLOCK) + pageCount].lpn;

							if (pageMap->pmEntry[dieNo][lpn].ppn == ((victimBlock * PAGE_NUM_PER_BLOCK) + pageCount))
								pageMap->pmEntry[dieNo][lpn].ppn = 0xffffffff;
						}
					}
				}

				EraseBlock(dieNo, victimBlock);
				if(closedFlag)
				{
					blockMap->bmEntry[dieNo][victimBlock].free = 0;
					dieBlock->dieEntry[dieNo].currentBlock = dieBlock->dieEntry[dieNo].freeBlock;
					dieBlock->dieEntry[dieNo].freeBlock = victimBlock;
				}
				break;
			}
		}

		if(invalidPageCount == 0)
			assert(!"[WARNING] There are no free blocks. Abort terminate this ssd. [WARNING]");
	}

	EmptyReqQ();
}

void CompulsoryGC(unsigned int dieNo, unsigned int blockNo)
{
	unsigned int pageCount, lpn, freePage, validPage;
	unsigned char closedFlag = 0xff;

	// unlink GC list
	if((blockMap->bmEntry[dieNo][blockNo].nextBlock != 0xffffffff) && (blockMap->bmEntry[dieNo][blockNo].prevBlock != 0xffffffff))
	{
		blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].prevBlock].nextBlock = blockMap->bmEntry[dieNo][blockNo].nextBlock;
		blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].nextBlock].prevBlock = blockMap->bmEntry[dieNo][blockNo].prevBlock;
	}
	else if((blockMap->bmEntry[dieNo][blockNo].nextBlock == 0xffffffff) && (blockMap->bmEntry[dieNo][blockNo].prevBlock != 0xffffffff))
	{
		blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].prevBlock].nextBlock = 0xffffffff;
		gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].invalidPageCnt].tail = blockMap->bmEntry[dieNo][blockNo].prevBlock;
	}
	else if((blockMap->bmEntry[dieNo][blockNo].nextBlock != 0xffffffff) && (blockMap->bmEntry[dieNo][blockNo].prevBlock == 0xffffffff))
	{
		blockMap->bmEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].nextBlock].prevBlock = 0xffffffff;
		gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].invalidPageCnt].head = blockMap->bmEntry[dieNo][blockNo].nextBlock;
	}
	else
	{
		gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].invalidPageCnt].head = 0xffffffff;
		gcMap->gcEntry[dieNo][blockMap->bmEntry[dieNo][blockNo].invalidPageCnt].tail = 0xffffffff;
	}

	//valid page copy
	closedFlag = 0;

	if((blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage == (PAGE_NUM_PER_BLOCK - 1)) || (blockNo ==  dieBlock->dieEntry[dieNo].currentBlock))
		closedFlag = 1;

	for(pageCount=0 ; pageCount<PAGE_NUM_PER_BLOCK ; pageCount++)
	{
		if((pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + pageCount].valid == 1) && (pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + pageCount].lpn != 0x7fffffff))
		{
			//allocate freepage
			if(closedFlag == 0)
			{
				if(blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage == (PAGE_NUM_PER_BLOCK - 1))
				{
					closedFlag = 1;
					blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage++;
					freePage = dieBlock->dieEntry[dieNo].freeBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage;
				}
				else
				{
					blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage++;
					freePage = dieBlock->dieEntry[dieNo].currentBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].currentBlock].currentPage;
				}
			}
			else
			{
				blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage++;
				freePage = dieBlock->dieEntry[dieNo].freeBlock * PAGE_NUM_PER_BLOCK + blockMap->bmEntry[dieNo][dieBlock->dieEntry[dieNo].freeBlock].currentPage;
			}

			// page copy process
			validPage = blockNo*PAGE_NUM_PER_BLOCK + pageCount;

			int chNo = dieNo % CHANNEL_NUM;
			int wayNo = dieNo / CHANNEL_NUM;

			PushToSubReqQueue(chNo, wayNo, V2FCommand_ReadPageTrigger, validPage, GC_BUFFER_ADDR + DIE_NUM*BLOCK_NUM_PER_DIE +  (dieNo + 1)*PAGE_SIZE, SPARE_ADDR);
			PushToSubReqQueue(chNo, wayNo, V2FCommand_ProgramPage,  freePage, GC_BUFFER_ADDR + DIE_NUM*BLOCK_NUM_PER_DIE + (dieNo + 1)*PAGE_SIZE, SPARE_ADDR);

			// pageMap update
			lpn = pageMap->pmEntry[dieNo][validPage].lpn;

			pageMap->pmEntry[dieNo][lpn].ppn = freePage;
			pageMap->pmEntry[dieNo][freePage].lpn = lpn;
		}
		else if(pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + pageCount].valid == 0)
		{
			lpn = pageMap->pmEntry[dieNo][(blockNo * PAGE_NUM_PER_BLOCK) + pageCount].lpn;

			if(pageMap->pmEntry[dieNo][lpn].ppn == ((blockNo * PAGE_NUM_PER_BLOCK) + pageCount))
				pageMap->pmEntry[dieNo][lpn].ppn = 0xffffffff;
		}
	}
	EraseBlock(dieNo, blockNo);

	if(closedFlag == 1)
	{
		dieBlock->dieEntry[dieNo].currentBlock = dieBlock->dieEntry[dieNo].freeBlock;

		int i;
		for(i=blockNo+1 ; i<(blockNo + BLOCK_NUM_PER_DIE) ; i++)
			if((blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].free) && (!blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].bad))
			{
				blockMap->bmEntry[dieNo][i % BLOCK_NUM_PER_DIE].free = 0;
				dieBlock->dieEntry[dieNo].freeBlock = i % BLOCK_NUM_PER_DIE;

				return ;
			}

		assert(!"[WARNING] There are no free blocks. Abort terminate this ssd. [WARNING]");
	}
}

void UpdateBadBlockTable(int chNo, int wayNo, unsigned int blockNo)
{
	int dieNo = wayNo * CHANNEL_NUM + chNo;

	CompulsoryGC(dieNo, blockNo);
	blockMap->bmEntry[dieNo][blockNo].bad = 1;

	reservedReq = 1;
}


