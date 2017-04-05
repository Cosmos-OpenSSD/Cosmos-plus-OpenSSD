//////////////////////////////////////////////////////////////////////////////////
// lru_buffer.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
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
// Module Name: Buffer Management
// File Name: lru_buffer.c
//
// Version: v1.0.0
//
// Description:
//   - store the data accessed by host system
//	 - determine whether it is necessary to access NAND flash memory
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////


#include	"page_map.h"
#include	"lru_buffer.h"
#include	"memory_map.h"
#include	"nvme/host_lld.h"
#include	"low_level_scheduler.h"

struct bufArray* bufMap;
struct bufLruArray* bufLruList;

void LRUBufInit()
{
	bufMap = (struct bufArray*) BUFFER_MAP_ADDR;
	bufLruList = (struct bufLruArray*) BUFFER_LRU_LIST_ADDR;

	int i,j,tempEntry;
	for(i = 0; i < BUF_ENTRY_NUM; i++)
	{
		bufMap->bufEntry[i].dirty = 0;
		bufMap->bufEntry[i].prevEntry = 0x7fff;
		bufMap->bufEntry[i].nextEntry = 0x7fff;
		bufMap->bufEntry[i].txDmaExe = 0;
		bufMap->bufEntry[i].rxDmaExe = 0;
		bufMap->bufEntry[i].lpn = 0xffffffff;
	}

	for(i = 0; i < DIE_NUM; i++)
	{
		for(j = 0; j < BUF_ENTRY_NUM_PER_DIE; j++)
		{
			tempEntry = i * BUF_ENTRY_NUM_PER_DIE + j;
			bufMap->bufEntry[tempEntry].prevEntry = tempEntry - 1;
			bufMap->bufEntry[tempEntry].nextEntry = tempEntry + 1;
		}

		bufMap->bufEntry[i * BUF_ENTRY_NUM_PER_DIE].prevEntry = 0x7fff;
		bufMap->bufEntry[(i+1) * BUF_ENTRY_NUM_PER_DIE - 1].nextEntry = 0x7fff;
		bufLruList->bufLruEntry[i].head = i * BUF_ENTRY_NUM_PER_DIE ;
		bufLruList->bufLruEntry[i].tail = (i+1) * BUF_ENTRY_NUM_PER_DIE - 1;
	}
}

unsigned int AllocateBufEntry(unsigned int lpn)
{
	unsigned int dieNo = lpn % DIE_NUM;
	unsigned int evictionEntry = bufLruList->bufLruEntry[dieNo].tail;

	if((bufMap->bufEntry[evictionEntry].nextEntry == 0x7fff) && (bufMap->bufEntry[evictionEntry].prevEntry != 0x7fff))
	{
		bufMap->bufEntry[bufMap->bufEntry[evictionEntry].prevEntry].nextEntry = 0x7fff;
		bufLruList->bufLruEntry[dieNo].tail = bufMap->bufEntry[evictionEntry].prevEntry;
	}
	else
	{
		bufLruList->bufLruEntry[dieNo].tail = 0x7fff;
		bufLruList->bufLruEntry[dieNo].head = 0x7fff;
	}

	if(bufMap->bufEntry[evictionEntry].dirty)
	{
		BUFFER_REQ_INFO bufferCmd;
		bufferCmd.lpn = bufMap->bufEntry[evictionEntry].lpn;
		bufferCmd.bufferEntry  = evictionEntry;

		PmWrite(&bufferCmd);
		return evictionEntry;
	}
	else
		return evictionEntry;
}

unsigned int CheckBufHit(unsigned int lpn)
{
	unsigned int dieNo = lpn % DIE_NUM;
	unsigned int hitEntry = bufLruList->bufLruEntry[dieNo].head;

	while(1)
	{
		if(hitEntry != 0x7fff)
		{
			if(bufMap->bufEntry[hitEntry].lpn == lpn)
			{
				//unlink
				if((bufMap->bufEntry[hitEntry].nextEntry != 0x7fff) && (bufMap->bufEntry[hitEntry].prevEntry != 0x7fff))
				{
					bufMap->bufEntry[bufMap->bufEntry[hitEntry].prevEntry].nextEntry = bufMap->bufEntry[hitEntry].nextEntry;
					bufMap->bufEntry[bufMap->bufEntry[hitEntry].nextEntry].prevEntry = bufMap->bufEntry[hitEntry].prevEntry;
				}
				else if((bufMap->bufEntry[hitEntry].nextEntry == 0x7fff) && (bufMap->bufEntry[hitEntry].prevEntry != 0x7fff))
				{
					bufMap->bufEntry[bufMap->bufEntry[hitEntry].prevEntry].nextEntry = 0x7fff;
					bufLruList->bufLruEntry[dieNo].tail = bufMap->bufEntry[hitEntry].prevEntry;
				}
				else if((bufMap->bufEntry[hitEntry].nextEntry != 0x7fff) && (bufMap->bufEntry[hitEntry].prevEntry== 0x7fff))
				{
					bufMap->bufEntry[bufMap->bufEntry[hitEntry].nextEntry].prevEntry  = 0x7fff;
					bufLruList->bufLruEntry[dieNo].head = bufMap->bufEntry[hitEntry].nextEntry;
				}
				else
				{
					bufLruList->bufLruEntry[dieNo].tail = 0x7fff;
					bufLruList->bufLruEntry[dieNo].head = 0x7fff;
				}

				//link
				if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
				{
					bufMap->bufEntry[hitEntry].prevEntry = 0x7fff;
					bufMap->bufEntry[hitEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
					bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = hitEntry;
					bufLruList->bufLruEntry[dieNo].head = hitEntry;
				}
				else
				{
					bufMap->bufEntry[hitEntry].prevEntry = 0x7fff;
					bufMap->bufEntry[hitEntry].nextEntry = 0x7fff;
					bufLruList->bufLruEntry[dieNo].head = hitEntry;
					bufLruList->bufLruEntry[dieNo].tail = hitEntry;
				}
				return hitEntry;
			}
			else
				hitEntry = bufMap->bufEntry[hitEntry].nextEntry;
		}
		else
			return 0x7fff;
	}
}

void LRUBufRead(P_HOST_REQ_INFO hostCmd)
{
	BUFFER_REQ_INFO bufferCmd;
	LOW_LEVEL_REQ_INFO lowLevelCmd;
	unsigned int tempLpn, counter, hitEntry, dmaIndex, devAddr, subReqSect, dieNo;
	unsigned int loop = ((hostCmd->curSect % SECTOR_NUM_PER_PAGE) + hostCmd->reqSect) / SECTOR_NUM_PER_PAGE;

	counter = 0;
	dmaIndex = 0;
	tempLpn = hostCmd->curSect / SECTOR_NUM_PER_PAGE;

	hitEntry = CheckBufHit(tempLpn);
	if(hitEntry != 0x7fff)
	{
		devAddr = BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE + (hostCmd->curSect % SECTOR_NUM_PER_PAGE) * SECTOR_SIZE_FTL;
		if(loop)
			subReqSect = SECTOR_NUM_PER_PAGE - (hostCmd->curSect % SECTOR_NUM_PER_PAGE);
		else
			subReqSect = hostCmd->reqSect;

		dieNo = tempLpn % DIE_NUM;
		lowLevelCmd.devAddr = devAddr;
		lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = dmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect = subReqSect;
		lowLevelCmd.bufferEntry = hitEntry;
		lowLevelCmd.request = LLSCommand_TxDMA;

		PushToReqQueue(&lowLevelCmd);
		dmaIndex += lowLevelCmd.subReqSect;

		reservedReq = 1;
	}
	else
	{
		bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
		bufferCmd.lpn = tempLpn;
		bufferCmd.devAddr = (BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE + (hostCmd->curSect % SECTOR_NUM_PER_PAGE) * SECTOR_SIZE_FTL);
		bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		bufferCmd.startDmaIndex = dmaIndex;
		if(loop)
			bufferCmd.subReqSect = SECTOR_NUM_PER_PAGE - hostCmd->curSect % SECTOR_NUM_PER_PAGE;
		else
			bufferCmd.subReqSect = hostCmd->reqSect;

		bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 0;

		//link
		dieNo = tempLpn % DIE_NUM;
		if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
			bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
		}
		else
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
		}
		bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

		PmRead(&bufferCmd);
		dmaIndex += bufferCmd.subReqSect;
	}
	tempLpn++;
	counter++;

	while(counter<loop)
	{
		hitEntry = CheckBufHit(tempLpn);
		if(hitEntry != 0x7fff)
		{
			devAddr = BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE;
			subReqSect = SECTOR_NUM_PER_PAGE;

			dieNo = tempLpn % DIE_NUM;
			lowLevelCmd.devAddr = devAddr;
			lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
			lowLevelCmd.startDmaIndex = dmaIndex;
			lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
			lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
			lowLevelCmd.subReqSect = subReqSect;
			lowLevelCmd.bufferEntry = hitEntry;
			lowLevelCmd.request = LLSCommand_TxDMA;

			PushToReqQueue(&lowLevelCmd);
			dmaIndex += lowLevelCmd.subReqSect;

			reservedReq = 1;
		}
		else
		{
			bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
			bufferCmd.lpn = tempLpn;
			bufferCmd.devAddr = BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE;
			bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
			bufferCmd.startDmaIndex = dmaIndex;
			bufferCmd.subReqSect = SECTOR_NUM_PER_PAGE;

			bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 0;

			//link
			dieNo = tempLpn % DIE_NUM;
			if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
			{
				bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
				bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
				bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
				bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			}
			else
			{
				bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
				bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
				bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
				bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
			}
			bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

			PmRead(&bufferCmd);
			dmaIndex += bufferCmd.subReqSect;
		}
		tempLpn++;
		counter++;
	}

	subReqSect = (hostCmd->curSect + hostCmd->reqSect) % SECTOR_NUM_PER_PAGE;
	if((subReqSect == 0) || (loop == 0))
		return ;

	hitEntry = CheckBufHit(tempLpn);
	if(hitEntry != 0x7fff)
	{
		devAddr = BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE;

		dieNo = tempLpn % DIE_NUM;
		lowLevelCmd.devAddr = devAddr;
		lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = dmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect = subReqSect;
		lowLevelCmd.bufferEntry = hitEntry;
		lowLevelCmd.request = LLSCommand_TxDMA;

		PushToReqQueue(&lowLevelCmd);
		dmaIndex += lowLevelCmd.subReqSect;

		reservedReq = 1;
	}
	else
	{
		bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
		bufferCmd.lpn = tempLpn;
		bufferCmd.devAddr = BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE;
		bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		bufferCmd.startDmaIndex = dmaIndex;
		bufferCmd.subReqSect = subReqSect;
		bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 0;

		//link
		dieNo = tempLpn % DIE_NUM;
		if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
			bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
		}
		else
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
		}
		bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

		PmRead(&bufferCmd);
	}
}

void LRUBufWrite(P_HOST_REQ_INFO hostCmd)
{
	BUFFER_REQ_INFO bufferCmd;
	LOW_LEVEL_REQ_INFO lowLevelCmd;
	unsigned int tempLpn, counter, hitEntry, dmaIndex, devAddr, subReqSect,  dieNo;
	unsigned int loop = ((hostCmd->curSect % SECTOR_NUM_PER_PAGE) + hostCmd->reqSect) / SECTOR_NUM_PER_PAGE;

	counter = 0;
	dmaIndex = 0;
	tempLpn = hostCmd->curSect / SECTOR_NUM_PER_PAGE;

	hitEntry = CheckBufHit(tempLpn);
	if(hitEntry != 0x7fff)
	{
		devAddr = (BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE + (hostCmd->curSect % SECTOR_NUM_PER_PAGE) * SECTOR_SIZE_FTL);
		if(loop)
			subReqSect = SECTOR_NUM_PER_PAGE - (hostCmd->curSect % SECTOR_NUM_PER_PAGE);
		else
			subReqSect = hostCmd->reqSect;
		bufMap->bufEntry[hitEntry].dirty = 1;

		dieNo = tempLpn % DIE_NUM;
		lowLevelCmd.devAddr = devAddr;
		lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = dmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect = subReqSect;
		lowLevelCmd.bufferEntry = hitEntry;
		lowLevelCmd.request = LLSCommand_RxDMA;

		PushToReqQueue(&lowLevelCmd);
		dmaIndex += lowLevelCmd.subReqSect;

		reservedReq = 1;
	}
	else
	{
		bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
		bufferCmd.lpn = tempLpn;
		bufferCmd.devAddr = BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE + (hostCmd->curSect % SECTOR_NUM_PER_PAGE) * SECTOR_SIZE_FTL;
		bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		bufferCmd.startDmaIndex = dmaIndex;
		if(loop)
			bufferCmd.subReqSect = SECTOR_NUM_PER_PAGE - hostCmd->curSect % SECTOR_NUM_PER_PAGE;
		else
			bufferCmd.subReqSect  = hostCmd->reqSect;
		bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 1;

		//link
		dieNo = tempLpn % DIE_NUM;
		if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
			bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
		}
		else
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
		}
		bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

		PrePmRead(&bufferCmd);
		dmaIndex += bufferCmd.subReqSect;
	}
	tempLpn++;
	counter++;

	while(counter<loop)
	{
		hitEntry = CheckBufHit(tempLpn);
		if(hitEntry != 0x7fff)
		{
			devAddr = BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE;
			subReqSect = SECTOR_NUM_PER_PAGE;
			bufMap->bufEntry[hitEntry].dirty = 1;

			dieNo = tempLpn % DIE_NUM;
			lowLevelCmd.devAddr = devAddr;
			lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
			lowLevelCmd.startDmaIndex = dmaIndex;
			lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
			lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
			lowLevelCmd.subReqSect = subReqSect;
			lowLevelCmd.bufferEntry = hitEntry;
			lowLevelCmd.request = LLSCommand_RxDMA;

			PushToReqQueue(&lowLevelCmd);
			dmaIndex += lowLevelCmd.subReqSect;

			reservedReq = 1;
		}
		else
		{
			bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
			bufferCmd.subReqSect = SECTOR_NUM_PER_PAGE;
			bufferCmd.lpn = tempLpn;
			bufferCmd.devAddr = BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE;
			bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
			bufferCmd.startDmaIndex = dmaIndex;
			bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 1;

			//link
			dieNo = tempLpn % DIE_NUM;
			if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
			{
				bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
				bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
				bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
				bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			}
			else
			{
				bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
				bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
				bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
				bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
			}
			bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

			PrePmRead(&bufferCmd);
			dmaIndex += bufferCmd.subReqSect;
		}
		tempLpn++;
		counter++;
	}

	subReqSect = (hostCmd->curSect + hostCmd->reqSect) % SECTOR_NUM_PER_PAGE;
	if((subReqSect == 0) || (loop == 0))
		return ;

	hitEntry = CheckBufHit(tempLpn);
	if(hitEntry != 0x7fff)
	{
		devAddr = BUFFER_ADDR + hitEntry * BUF_ENTRY_SIZE;
		bufMap->bufEntry[hitEntry].dirty = 1;

		dieNo = tempLpn % DIE_NUM;
		lowLevelCmd.devAddr = devAddr;
		lowLevelCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		lowLevelCmd.startDmaIndex = dmaIndex;
		lowLevelCmd.chNo = dieNo % CHANNEL_NUM;
		lowLevelCmd.wayNo = dieNo / CHANNEL_NUM;
		lowLevelCmd.subReqSect = subReqSect;
		lowLevelCmd.bufferEntry = hitEntry;
		lowLevelCmd.request = LLSCommand_RxDMA;

		PushToReqQueue(&lowLevelCmd);
		dmaIndex += lowLevelCmd.subReqSect;

		reservedReq = 1;
	}
	else
	{
		bufferCmd.bufferEntry =  AllocateBufEntry(tempLpn);
		bufferCmd.subReqSect = subReqSect;
		bufferCmd.lpn = tempLpn;
		bufferCmd.devAddr = BUFFER_ADDR + bufferCmd.bufferEntry * BUF_ENTRY_SIZE;
		bufferCmd.cmdSlotTag = hostCmd->cmdSlotTag;
		bufferCmd.startDmaIndex = dmaIndex;
		bufMap->bufEntry[bufferCmd.bufferEntry].dirty = 1;

		//link
		dieNo = tempLpn % DIE_NUM;
		if(bufLruList->bufLruEntry[dieNo].head != 0x7fff)
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = bufLruList->bufLruEntry[dieNo].head;
			bufMap->bufEntry[bufLruList->bufLruEntry[dieNo].head].prevEntry = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
		}
		else
		{
			bufMap->bufEntry[bufferCmd.bufferEntry].prevEntry = 0x7fff;
			bufMap->bufEntry[bufferCmd.bufferEntry].nextEntry = 0x7fff;
			bufLruList->bufLruEntry[dieNo].head = bufferCmd.bufferEntry;
			bufLruList->bufLruEntry[dieNo].tail = bufferCmd.bufferEntry;
		}
		bufMap->bufEntry[bufferCmd.bufferEntry].lpn = tempLpn;

		PrePmRead(&bufferCmd);
	}
}



