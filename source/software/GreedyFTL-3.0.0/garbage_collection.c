//////////////////////////////////////////////////////////////////////////////////
// garbage_collection.c for Cosmos+ OpenSSD
// Copyright (c) 2017 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
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
// Module Name: Garbage Collector
// File Name: garbage_collection.c
//
// Version: v1.0.0
//
// Description:
//   - select a victim block
//   - collect valid pages to a free block
//   - erase a victim block to make a free block
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#include "xil_printf.h"
#include <assert.h>
#include "memory_map.h"

P_GC_VICTIM_MAP gcVictimMapPtr;

/* 
@ initialzie GC victim Mapping table
*/
void InitGcVictimMap()
{
	int dieNo, invalidSliceCnt;

	gcVictimMapPtr = (P_GC_VICTIM_MAP) GC_VICTIM_MAP_ADDR;

	for(dieNo=0 ; dieNo<USER_DIES; dieNo++)
	{
		for(invalidSliceCnt=0 ; invalidSliceCnt<SLICES_PER_BLOCK+1; invalidSliceCnt++)
		{
			gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = BLOCK_NONE;
			gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = BLOCK_NONE;
		}
	}
}

/*
@ perform garbage collection on *specific* die
@ 1) select victim block number 
@ 2) start for-loop in block 
@ 3) check the page(slice) valid or not 
@		* valid = (current virtual address) == (logical-to-virtual mapping)
@ 4) find free block and then copy the valid page(slice)
@ 5) erase victim block
@[in] dieNo : Die number 
*/
void GarbageCollection(unsigned int dieNo)
{
	unsigned int victimBlockNo, pageNo, virtualSliceAddr, logicalSliceAddr, dieNoForGcCopy, reqSlotTag;

	victimBlockNo = GetFromGcVictimList(dieNo);
	dieNoForGcCopy = dieNo;

	if(virtualBlockMapPtr->block[dieNo][victimBlockNo].invalidSliceCnt != SLICES_PER_BLOCK)
	{
		for(pageNo=0 ; pageNo<USER_PAGES_PER_BLOCK ; pageNo++)
		{
			virtualSliceAddr = Vorg2VsaTranslation(dieNo, victimBlockNo, pageNo);
			logicalSliceAddr = virtualSliceMapPtr->virtualSlice[virtualSliceAddr].logicalSliceAddr;

			if(logicalSliceAddr != LSA_NONE)
				if(logicalSliceMapPtr->logicalSlice[logicalSliceAddr].virtualSliceAddr ==  virtualSliceAddr) //valid data
				{
					//@pjh : copy-back ?
					
					//read
					reqSlotTag = GetFromFreeReqQ();

					reqPoolPtr->reqPool[reqSlotTag].reqType = REQ_TYPE_NAND;
					reqPoolPtr->reqPool[reqSlotTag].reqCode = REQ_CODE_READ;
					reqPoolPtr->reqPool[reqSlotTag].logicalSliceAddr = logicalSliceAddr;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.dataBufFormat = REQ_OPT_DATA_BUF_TEMP_ENTRY;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandAddr = REQ_OPT_NAND_ADDR_VSA;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandEcc = REQ_OPT_NAND_ECC_ON;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandEccWarning = REQ_OPT_NAND_ECC_WARNING_OFF;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.rowAddrDependencyCheck = REQ_OPT_ROW_ADDR_DEPENDENCY_CHECK;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.blockSpace = REQ_OPT_BLOCK_SPACE_MAIN;
					reqPoolPtr->reqPool[reqSlotTag].dataBufInfo.entry = AllocateTempDataBuf(dieNo);
					UpdateTempDataBufEntryInfoBlockingReq(reqPoolPtr->reqPool[reqSlotTag].dataBufInfo.entry, reqSlotTag);
					reqPoolPtr->reqPool[reqSlotTag].nandInfo.virtualSliceAddr = virtualSliceAddr;

					SelectLowLevelReqQ(reqSlotTag);

					//write
					reqSlotTag = GetFromFreeReqQ();

					reqPoolPtr->reqPool[reqSlotTag].reqType = REQ_TYPE_NAND;
					reqPoolPtr->reqPool[reqSlotTag].reqCode = REQ_CODE_WRITE;
					reqPoolPtr->reqPool[reqSlotTag].logicalSliceAddr = logicalSliceAddr;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.dataBufFormat = REQ_OPT_DATA_BUF_TEMP_ENTRY;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandAddr = REQ_OPT_NAND_ADDR_VSA;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandEcc = REQ_OPT_NAND_ECC_ON;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.nandEccWarning = REQ_OPT_NAND_ECC_WARNING_OFF;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.rowAddrDependencyCheck = REQ_OPT_ROW_ADDR_DEPENDENCY_CHECK;
					reqPoolPtr->reqPool[reqSlotTag].reqOpt.blockSpace = REQ_OPT_BLOCK_SPACE_MAIN;
					reqPoolPtr->reqPool[reqSlotTag].dataBufInfo.entry = AllocateTempDataBuf(dieNo);
					UpdateTempDataBufEntryInfoBlockingReq(reqPoolPtr->reqPool[reqSlotTag].dataBufInfo.entry, reqSlotTag);
					reqPoolPtr->reqPool[reqSlotTag].nandInfo.virtualSliceAddr = FindFreeVirtualSliceForGc(dieNoForGcCopy, victimBlockNo);

					logicalSliceMapPtr->logicalSlice[logicalSliceAddr].virtualSliceAddr = reqPoolPtr->reqPool[reqSlotTag].nandInfo.virtualSliceAddr;
					virtualSliceMapPtr->virtualSlice[reqPoolPtr->reqPool[reqSlotTag].nandInfo.virtualSliceAddr].logicalSliceAddr = logicalSliceAddr;

					SelectLowLevelReqQ(reqSlotTag);
				}
		}
	}

	EraseBlock(dieNo, victimBlockNo);
}


void PutToGcVictimList(unsigned int dieNo, unsigned int blockNo, unsigned int invalidSliceCnt)
{
	if(gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock != BLOCK_NONE)
	{
		virtualBlockMapPtr->block[dieNo][blockNo].prevBlock = gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock;
		virtualBlockMapPtr->block[dieNo][blockNo].nextBlock = BLOCK_NONE;
		virtualBlockMapPtr->block[dieNo][gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock].nextBlock = blockNo;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = blockNo;
	}
	else
	{
		virtualBlockMapPtr->block[dieNo][blockNo].prevBlock = BLOCK_NONE;
		virtualBlockMapPtr->block[dieNo][blockNo].nextBlock = BLOCK_NONE;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = blockNo;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = blockNo;
	}
}

/*
@ get GC victim list on *specific* die
@ 1) start for-loop in gcVictimList array.
@ 2) check current slice's headBlock BLOCK_NONE (-> goto step3 ) or NOT (-> goto step1)
@ 3) check eviction block's next block BLOCK_NONE or NOT
@ 3-1) BLOCK_NONE  : set current block's head/tail to BLOCK_NONE
@ 3-2) !BLOCK_NONE : remove current block in linked-list 
@ 4) return evictedBlockNo
@ (*) if there is no free block then abort and terminate SSD.
@[in] 	unsigned int dieNo : Die number
@[out] 	eviction block number 
*/
unsigned int GetFromGcVictimList(unsigned int dieNo)
{
	unsigned int evictedBlockNo;
	int invalidSliceCnt;

	for(invalidSliceCnt = SLICES_PER_BLOCK; invalidSliceCnt > 0 ; invalidSliceCnt--)
	{
		if(gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock != BLOCK_NONE)
		{
			evictedBlockNo = gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock;

			if(virtualBlockMapPtr->block[dieNo][evictedBlockNo].nextBlock != BLOCK_NONE)
			{
				virtualBlockMapPtr->block[dieNo][virtualBlockMapPtr->block[dieNo][evictedBlockNo].nextBlock].prevBlock = BLOCK_NONE;
				gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = virtualBlockMapPtr->block[dieNo][evictedBlockNo].nextBlock;

			}
			else
			{
				gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = BLOCK_NONE;
				gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = BLOCK_NONE;
			}
			return evictedBlockNo;

		}
	}

	assert(!"[WARNING] There are no free blocks. Abort terminate this ssd. [WARNING]");
	return BLOCK_FAIL;
}


void SelectiveGetFromGcVictimList(unsigned int dieNo, unsigned int blockNo)
{
	unsigned int nextBlock, prevBlock, invalidSliceCnt;

	nextBlock = virtualBlockMapPtr->block[dieNo][blockNo].nextBlock;
	prevBlock = virtualBlockMapPtr->block[dieNo][blockNo].prevBlock;
	invalidSliceCnt = virtualBlockMapPtr->block[dieNo][blockNo].invalidSliceCnt;

	if((nextBlock != BLOCK_NONE) && (prevBlock != BLOCK_NONE))
	{
		virtualBlockMapPtr->block[dieNo][prevBlock].nextBlock = nextBlock;
		virtualBlockMapPtr->block[dieNo][nextBlock].prevBlock = prevBlock;
	}
	else if((nextBlock == BLOCK_NONE) && (prevBlock != BLOCK_NONE))
	{
		virtualBlockMapPtr->block[dieNo][prevBlock].nextBlock = BLOCK_NONE;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = prevBlock;
	}
	else if((nextBlock != BLOCK_NONE) && (prevBlock == BLOCK_NONE))
	{
		virtualBlockMapPtr->block[dieNo][nextBlock].prevBlock = BLOCK_NONE;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = nextBlock;
	}
	else
	{
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].headBlock = BLOCK_NONE;
		gcVictimMapPtr->gcVictimList[dieNo][invalidSliceCnt].tailBlock = BLOCK_NONE;
	}
}

