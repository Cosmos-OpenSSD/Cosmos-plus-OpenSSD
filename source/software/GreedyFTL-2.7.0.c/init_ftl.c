//////////////////////////////////////////////////////////////////////////////////
// init_ftl.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//                Sanghyuk Jung <shjung@enc.hanyang.ac.kr>
//                Gyeongyong Lee <gylee@enc.hanyang.ac.kr>
//                Jaewook Kwak	<jwkwak@enc.hanyang.ac.kr>
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
// Module Name: Flash Translation Layer
// File Name: init_ftl.c
//
// Version: v1.3.0
//
// Description:
//   - initial NAND flash memory reset
//   - initialize map tables
//	 - initialize low level scheduler
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.3.0
//	 - Completion table0 and completion table1 are integrated into a metadata region in DRAM for supporting Predefined_Project
//	 - Error information table0 and error information table1 are integrated into a metadata region in DRAM for supporting Predefined_Project
//
// * v1.2.2
//	 - meta die initialization for bad block table is removed (each die has own bad block table)
//
// * v1.2.1
//	 - Storage capacity is calculated excluding free blocks, meta blocks, bad blocks and over provision blocks
//
// * v1.2.0
//	 - Completion table and error information table are divided according to HP-port which is connected by each flash channel
//
// * v1.1.0
//   - Storage size (storageCapacity_L) is determined by FTL
//   - Way priority table and die status table for low level scheduler are initialized
//
// * v1.0.2
//   - hold bit initialization for way queue is removed
//
// * v1.0.1
//   - hold bit and busy index for way queue are initialized
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#include "init_ftl.h"
#include "page_map.h"
#include "low_level_scheduler.h"
#include "memory_map.h"

unsigned int badBlockSize;
unsigned int beforeNandReset;
unsigned int storageCapacity_L;
V2FMCRegisters* chCtlReg[CHANNEL_NUM];

void InitChCtlReg()
{
	chCtlReg[0] = (V2FMCRegisters*) XPAR_TIGER4NSC_0_BASEADDR;
	chCtlReg[1] = (V2FMCRegisters*) XPAR_TIGER4NSC_1_BASEADDR;
	chCtlReg[2] = (V2FMCRegisters*) XPAR_TIGER4NSC_2_BASEADDR;
	chCtlReg[3] = (V2FMCRegisters*) XPAR_TIGER4NSC_3_BASEADDR;
	chCtlReg[4] = (V2FMCRegisters*) XPAR_TIGER4NSC_4_BASEADDR;
	chCtlReg[5] = (V2FMCRegisters*) XPAR_TIGER4NSC_5_BASEADDR;
	chCtlReg[6] = (V2FMCRegisters*) XPAR_TIGER4NSC_6_BASEADDR;
	chCtlReg[7] = (V2FMCRegisters*) XPAR_TIGER4NSC_7_BASEADDR;
}

void InitFtlMapTable()
{
	pageMap = (struct pmArray*)(PAGE_MAP_ADDR);
	blockMap = (struct bmArray*)(BLOCK_MAP_ADDR);
	dieBlock = (struct dieArray*)(DIE_MAP_ADDR);
	gcMap = (struct gcArray*)(GC_MAP_ADDR);

	InitPageMap();
	InitBlockMap(GC_BUFFER_ADDR);
	InitDieBlock();
	InitGcMap();

	storageCapacity_L = (SSD_SIZE - (FREE_BLOCK_SIZE + METADATA_BLOCK_SIZE + badBlockSize + OVER_PROVISION_BLOCK_SIZE)) * ((1024*1024) / SECTOR_SIZE_FTL);

	xil_printf("[ storage capacity %d MB ]\r\n", storageCapacity_L / ((1024*1024) / SECTOR_SIZE_FTL));
	xil_printf("[ map table reset complete. ]\r\n");
}

void InitDieReqQueue()
{
	reqQueue = (struct reqArray*)(REQ_QUEUE_ADDR);
	rqPointer = (struct rqPointerArray*)(REQ_QUEUE_POINTER_ADDR);
	subReqQueue = (struct subReqArray*)(SUB_REQ_QUEUE_ADDR);
	srqPointer = (struct rqPointerArray*)(SUB_REQ_QUEUE_POINTER_ADDR);

	reservedReq = 0;
	badBlockUpdate = 0;

	int chNo,wayNo,queueDepth;
	for(chNo=0; chNo<CHANNEL_NUM; ++chNo)
		for(wayNo=0; wayNo<WAY_NUM; ++wayNo)
		{
			for(queueDepth=0; queueDepth<REQ_QUEUE_DEPTH; ++queueDepth)
			{
				reqQueue->reqEntry[queueDepth][chNo][wayNo].request = 0xffff;
				reqQueue->reqEntry[queueDepth][chNo][wayNo].statusOption = 0xff;
				subReqQueue->reqEntry[queueDepth][chNo][wayNo].request = 0xffff;
				subReqQueue->reqEntry[queueDepth][chNo][wayNo].statusOption = 0xff;
			}

			rqPointer->rqPointerEntry[chNo][wayNo].front = 0;
			rqPointer->rqPointerEntry[chNo][wayNo].rear = 0;
			srqPointer->rqPointerEntry[chNo][wayNo].front = 0;
			srqPointer->rqPointerEntry[chNo][wayNo].rear = 0;
		}
}

void InitDieStatusTable()
{
	dieStatusTable = (struct dieStatusArray*)DIE_STATUS_TABLE_ADDR;
	completeTable = (struct completeArray*)COMPLETE_TABLE_ADDR;
	errorInfoTable = (struct errorInfoArray*)ERROR_INFO_TABLE_ADDR;
	newBadBlockTable = 	(struct newBadBlockArray*)NEW_BAD_BLOCK_TABLE_ADDR;
	retryLimitTable = (struct retryLimitArray*)RETRY_LIMIT_TABLE_ADDR;
	wayPriorityTable = (struct wayPriorityArray*) WAY_PRIORITY_TABLE_ADDR;

	int chNo,wayNo,entry;
	for(chNo=0; chNo<CHANNEL_NUM; ++chNo)
	{
		wayPriorityTable->wayPriorityEntry[chNo].idleHead = 0;
		wayPriorityTable->wayPriorityEntry[chNo].idleTail = WAY_NUM-1;
		wayPriorityTable->wayPriorityEntry[chNo].statusReportHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].statusReportTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandEraseHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandEraseTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nvmeDmaTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTriggerHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTriggerTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTrigNTransTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTransferHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandTransferTail = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandStatusHead = 0xf;
		wayPriorityTable->wayPriorityEntry[chNo].nandStatusTail = 0xf;

		for(wayNo=0; wayNo<WAY_NUM; ++wayNo)
		{
			dieStatusTable->dieStatusEntry[chNo][wayNo].dieStatus = DS_IDLE;
			dieStatusTable->dieStatusEntry[chNo][wayNo].queueSelect = SUB_REQ_QUEUE;
			dieStatusTable->dieStatusEntry[chNo][wayNo].reqQueueEmpty = 1;
			dieStatusTable->dieStatusEntry[chNo][wayNo].subReqQueueEmpty = 1;
			dieStatusTable->dieStatusEntry[chNo][wayNo].prevWay = wayNo - 1;
			dieStatusTable->dieStatusEntry[chNo][wayNo].nextWay = wayNo + 1;

			completeTable->completeEntry[chNo][wayNo] = 0;

			for(entry = 0; entry < REQ_QUEUE_DEPTH; ++entry)
				newBadBlockTable->newBadBlockEntry[entry][chNo][wayNo] = 0xffffffff;
		}
		dieStatusTable->dieStatusEntry[chNo][0].prevWay = 0xf;
		dieStatusTable->dieStatusEntry[chNo][WAY_NUM-1].nextWay = 0xf;
	}
}

void InitNandReset()
{
	int chNo,wayNo;

	beforeNandReset = 1;

	for(chNo=0; chNo<CHANNEL_NUM; ++chNo)
		for(wayNo=0; wayNo<WAY_NUM; ++wayNo)
		{
			PushToSubReqQueue(chNo,wayNo,V2FCommand_Reset,0,0,0);
			PushToSubReqQueue(chNo,wayNo,V2FCommand_SetFeatures,0,0,0);
		}

	metadataBlockNo = 0;

	EmptyLowLevelQ(SUB_REQ_QUEUE);

	beforeNandReset = 0;

	xil_printf("[ NAND device reset complete. ]\r\n");
}


