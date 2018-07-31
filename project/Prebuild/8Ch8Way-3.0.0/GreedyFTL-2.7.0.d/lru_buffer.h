//////////////////////////////////////////////////////////////////////////////////
// ia_lru_buffer.h for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
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
// Module Name: Buffer Management
// File Name: ia_lru_buffer.h
//
// Version: v1.0.0
//
// Description:
//   - define parameters and data structure of the interleaving-aware lru buffer
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////



#ifndef IA_LRU_BUFFER_H_
#define IA_LRU_BUFFER_H_

#include "init_ftl.h"
#include "internal_req.h"

#define BUF_ENTRY_NUM_PER_DIE	16
#define BUF_ENTRY_NUM	(BUF_ENTRY_NUM_PER_DIE * DIE_NUM)
#define BUF_ENTRY_SIZE	PAGE_SIZE

struct bufEntry {
	unsigned int reserved0 : 1;
	unsigned int dirty : 1;
	unsigned int prevEntry : 15;
	unsigned int nextEntry : 15;
	unsigned int lpn;
	unsigned int reserved1	: 7;
	unsigned int reserved2	: 7;
	unsigned int txDmaExe	: 1;
	unsigned int rxDmaExe	: 1;
	unsigned int txDmaTail	: 8;
	unsigned int rxDmaTail	: 8;
	unsigned int txDmaOverFlowCnt;
	unsigned int rxDmaOverFlowCnt;
};

struct bufArray {
	struct bufEntry bufEntry[BUF_ENTRY_NUM];
};

struct bufLruEntry {
	unsigned int head : 15;
	unsigned int tail : 15;
	unsigned int reserved : 2;
};

struct bufLruArray {
	struct bufLruEntry bufLruEntry[DIE_NUM];
};

extern struct bufArray* bufMap;
extern struct bufLruArray* bufLruList;

void LRUBufRead(P_HOST_REQ_INFO hostCmd);
void LRUBufWrite(P_HOST_REQ_INFO hostCmd);
void LRUBufInit();
unsigned int AllocateBufEntry(unsigned int lpn);
unsigned int CheckBufHit(unsigned int lpn);

#endif /* IA_LRU_BUFFER_H_ */
