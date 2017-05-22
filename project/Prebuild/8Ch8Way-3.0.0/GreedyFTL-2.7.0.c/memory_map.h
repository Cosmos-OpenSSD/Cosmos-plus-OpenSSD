//////////////////////////////////////////////////////////////////////////////////
// memory_map.h for Cosmos+ OpenSSD
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
// File Name: memory_map.h
//
// Version: v1.4.0
//
// Description:
//   - define parameters and data structure of the low level scheduler
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.4.0
//   - Address for completion and error information are re-allocated for supporting Predefined_Project
//
// * v1.3.0
//   - Address for completion and error information are re-allocated
//
// * v1.2.0
//   - Address for buffer and metadata are re-allocated
//   - Clean pool is deleted
//   - header file for buffer is changed from "ia_lru_buffer.h" to "lru_buffer.h"
//
// * v1.1.0
//   - Address for buffer and metadata are re-allocated
//   - Clean pool is added
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#ifndef	MEMORY_MAP_H_
#define	MEMORY_MAP_H_

#include "lru_buffer.h"
#include "page_map.h"

// Uncached & Unbuffered
#define BUFFER_ADDR 		0x10000000
#define SPARE_ADDR			(BUFFER_ADDR + BUF_ENTRY_NUM * BUF_ENTRY_SIZE)
#define GC_BUFFER_ADDR		(SPARE_ADDR + SPARE_SIZE * DIE_NUM)

#define COMPLETE_TABLE_ADDR		0x12300000
#define ERROR_INFO_TABLE_ADDR	(COMPLETE_TABLE_ADDR + sizeof(struct completeArray))
#define PAY_LOAD_ADDR	(ERROR_INFO_TABLE_ADDR+ sizeof(struct errorInfoArray))

// for buffers
#define BUFFER_MAP_ADDR		 0x12500000
#define BUFFER_LRU_LIST_ADDR 	(BUFFER_MAP_ADDR + sizeof(struct bufEntry) * BUF_ENTRY_NUM)

// for map tables
#define PAGE_MAP_ADDR	(BUFFER_LRU_LIST_ADDR + sizeof(struct bufLruEntry) * DIE_NUM)
#define BLOCK_MAP_ADDR	(PAGE_MAP_ADDR + sizeof(struct pmEntry) * PAGE_NUM_PER_SSD)
#define DIE_MAP_ADDR	(BLOCK_MAP_ADDR + sizeof(struct bmEntry) * BLOCK_NUM_PER_SSD)
#define GC_MAP_ADDR		(DIE_MAP_ADDR + sizeof(struct dieEntry) * DIE_NUM)

// for request queues
#define REQ_QUEUE_ADDR	(GC_MAP_ADDR + sizeof(struct gcEntry) * DIE_NUM *(PAGE_NUM_PER_BLOCK + 1))
#define REQ_QUEUE_POINTER_ADDR	(REQ_QUEUE_ADDR + sizeof(struct reqEntry) * DIE_NUM * REQ_QUEUE_DEPTH)
#define SUB_REQ_QUEUE_ADDR	(REQ_QUEUE_POINTER_ADDR+ sizeof(struct rqPointerEntry) * DIE_NUM)
#define SUB_REQ_QUEUE_POINTER_ADDR	(SUB_REQ_QUEUE_ADDR + sizeof(struct subReqEntry) * DIE_NUM * SUB_REQ_QUEUE_DEPTH)

// for low level scheduler
#define DIE_STATUS_TABLE_ADDR	(SUB_REQ_QUEUE_POINTER_ADDR+ sizeof(struct rqPointerEntry) * DIE_NUM)
#define NEW_BAD_BLOCK_TABLE_ADDR	(DIE_STATUS_TABLE_ADDR + sizeof(struct dieStatusEntry) * DIE_NUM)
#define RETRY_LIMIT_TABLE_ADDR	(NEW_BAD_BLOCK_TABLE_ADDR + sizeof(struct newBadBlockArray))
#define WAY_PRIORITY_TABLE_ADDR (RETRY_LIMIT_TABLE_ADDR + sizeof(struct retryLimitArray))

/*
// for 0-3 flash channel (HP port 0)
#define COMPLETE_TABLE_ADDR0		0x80000000
#define ERROR_INFO_TABLE_ADDR0	(COMPLETE_TABLE_ADDR0 + sizeof(struct completeArray))

// for 4-7 flash channel (HP port 1)
#define COMPLETE_TABLE_ADDR1		0x80010000
#define ERROR_INFO_TABLE_ADDR1	(COMPLETE_TABLE_ADDR1 + sizeof(struct completeArray))
*/


#endif	/* MEMORY_MAP_H_ */
