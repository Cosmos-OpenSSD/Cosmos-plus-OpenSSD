//////////////////////////////////////////////////////////////////////////////////
// page_map.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//                Sanghyuk Jung <shjung@enc.hanyang.ac.kr>
//                Gyeongyong Lee <gylee@enc.hanyang.ac.kr>
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
// Module Name: Flash Translation Layer
// File Name: page_map.c
//
// Version: v1.1.1
//
// Description:
//   - define data structure of map tables
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.1.1
//   - metadataDieNo is deleted (Each flash die has a own metadata block)
//
// * v1.1.0
//   - DirtyPmWrite is deleted
//   - PmWrite is added for LRU buffer
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#ifndef PAGE_MAP_H_
#define PAGE_MAP_H_

#include "init_ftl.h"
#include "nvme/nvme.h"
#include "xil_printf.h"
#include "internal_req.h"

struct pmEntry {
	unsigned int ppn;	// Physical Page Number (PPN) to which a logical page is mapped
	unsigned int valid : 1;	// validity of a physical page
	unsigned int lpn : 31;	// Logical Page Number (LPN) of a physical page
};

struct pmArray {
	struct pmEntry pmEntry[DIE_NUM][PAGE_NUM_PER_DIE];
};

struct bmEntry {
	unsigned int bad : 1;
	unsigned int free : 1;
	unsigned int eraseCnt : 30;
	unsigned int invalidPageCnt : 16;
	unsigned int currentPage : 16;
	unsigned int prevBlock;
	unsigned int nextBlock;
};

struct bmArray {
	struct bmEntry bmEntry[DIE_NUM][BLOCK_NUM_PER_DIE];
};

struct dieEntry {
	unsigned int currentBlock;
	unsigned int freeBlock;
};

struct dieArray {
	struct dieEntry dieEntry[DIE_NUM];
};

struct gcEntry {
	unsigned int head;
	unsigned int tail;
};

struct gcArray {
	struct gcEntry gcEntry[DIE_NUM][PAGE_NUM_PER_BLOCK + 1];
};

void InitPageMap();
void InitBlockMap(unsigned int badBlockTableAddr);
void InitDieBlock();
void InitGcMap();

int FindFreePage(unsigned int dieNo);
int PrePmRead(P_BUFFER_REQ_INFO bufCmd);
int PmRead(P_BUFFER_REQ_INFO bufCmd);
int PmWrite(P_BUFFER_REQ_INFO bufCmd);
int UpdateMetaForInvalidate(unsigned int lpn);

void EraseBlock(unsigned int dieNo, unsigned int blockNo);
void GarbageCollection();
void CompulsoryGC(unsigned int dieNo, unsigned int blockNo);

void RecoverBadBlockTable(unsigned int readBufAddr);
void UpdateBadBlockTable(int chNo, int wayNo, unsigned int blockNo);

extern struct pmArray* pageMap;
extern struct bmArray* blockMap;
extern struct dieArray* dieBlock;
extern struct gcArray* gcMap;

extern unsigned int metadataBlockNo;

#endif /* PAGE_MAP_H_ */
