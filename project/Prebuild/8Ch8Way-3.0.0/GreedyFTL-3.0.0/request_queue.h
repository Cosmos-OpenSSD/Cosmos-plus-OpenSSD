//////////////////////////////////////////////////////////////////////////////////
// request_queue.h for Cosmos+ OpenSSD
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
// Module Name: Request Allocator
// File Name: request_queue.h
//
// Version: v1.0.0
//
// Description:
//   - define data structure of request queue
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////
#ifndef REQUEST_QUEUE_H_
#define REQUEST_QUEUE_H_


typedef struct _FREE_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} FREE_REQUEST_QUEUE, *P_FREE_REQUEST_QUEUE;

typedef struct _SLICE_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} SLICE_REQUEST_QUEUE, *P_SLICE_REQUEST_QUEUE;

typedef struct _BLOCKED_BY_BUFFER_DEPENDENCY_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} BLOCKED_BY_BUFFER_DEPENDENCY_REQUEST_QUEUE, *P_BLOCKED_BY_BUFFER_DEPENDENCY_REQUEST_QUEUE;

typedef struct _BLOCKED_BY_ROW_ADDR_DEPENDENCY_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} BLOCKED_BY_ROW_ADDR_DEPENDENCY_REQUEST_QUEUE, *PBLOCKED_BY_ROW_ADDR_DEPENDENCY_REQUEST_QUEUE;

typedef struct _NVME_DMA_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} NVME_DMA_REQUEST_QUEUE, *P_NVME_DMA_REQUEST_QUEUE;

typedef struct _NAND_REQUEST_QUEUE
{
	unsigned int headReq : 16;
	unsigned int tailReq : 16;
	unsigned int reqCnt : 16;
	unsigned int reserved0 : 16;
} NAND_REQUEST_QUEUE, *P_NAND_REQUEST_QUEUE;


#endif /* REQUEST_QUEUE_H_ */
