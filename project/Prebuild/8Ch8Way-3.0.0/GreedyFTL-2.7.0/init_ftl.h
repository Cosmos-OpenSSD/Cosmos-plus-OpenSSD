//////////////////////////////////////////////////////////////////////////////////
// init_ftl.h for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//                Sanghyuk Jung <shjung@enc.hanyang.ac.kr>
//                Gyeongyong Lee <gylee@enc.hanyang.ac.kr>
//				Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
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
// File Name: init_ftl.h
//
// Version: v1.3.1
//
// Description:
//   - define parameters of NAND flash memory and FTL
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.3.1
//   - MAX_X_NUM indicates maximum number of the X configuration option
//   - X_SLC_X indicates the case of SLC mode
//   - X_MLC_X indicates the case of MLC mode
//
// * v1.3.0
//   - user can select bit count per flash cell by modifying the value of BIT_PER_FLASH_CELL
//   - over provision block alleviates the performance degradation in worst case of on-demand GC
//
// * v1.2.0
//   - CHANNEL_NUM_PER_HP_PORT indicates the number of flash channel which is connected to each HP-port
//
// * v1.1.0
//   - Storage capacity is managed by global variable
//   - BeforeNandReset indicates whether NAND flash array reset
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#ifndef	INIT_FTL_H_
#define	INIT_FTL_H_

#include "fmc_driver.h"

#define	SECTOR_SIZE_FTL			4096	//4KB

#define	PAGE_SIZE				16384	//16KB
#define SPARE_SIZE				256		//last 8 bytes are CRC bytes

#define	SLC_MODE				1
#define	MLC_MODE				2
#define	BIT_PER_FLASH_CELL		SLC_MODE //select SLC_MODE or MLC_MODE

#define	PAGE_NUM_PER_BLOCK		(128 * BIT_PER_FLASH_CELL)
#define	PAGE_NUM_PER_SLC_BLOCK	128
#define	PAGE_NUM_PER_MLC_BLOCK	256
#define	BLOCK_NUM_PER_LUN		(4096 / BIT_PER_FLASH_CELL) //DRAM size doesn't enough for page mapping when MLC mode uses all blocks. If you want to use all blocks, map cache function should be implemented.
#define	MAX_BLOCK_NUM_PER_LUN	4096
#define LUN_NUM_PER_DIE			2
#define	MAX_LUN_NUM_PER_DIE		2
#define	BLOCK_SIZE_MB			((PAGE_SIZE * PAGE_NUM_PER_BLOCK) / (1024 * 1024))

#define	CHANNEL_NUM				8
#define	MAX_CHANNEL_NUM			8
#define	WAY_NUM					8
#define	MAX_WAY_NUM				8
#define	DIE_NUM					(CHANNEL_NUM * WAY_NUM)

#define	SECTOR_NUM_PER_PAGE		(PAGE_SIZE / SECTOR_SIZE_FTL)

#define	PAGE_NUM_PER_LUN			(PAGE_NUM_PER_BLOCK * BLOCK_NUM_PER_LUN)
#define	MAX_PAGE_NUM_PER_SLC_LUN		(PAGE_NUM_PER_SLC_BLOCK * MAX_BLOCK_NUM_PER_LUN)
#define	PAGE_NUM_PER_DIE			(PAGE_NUM_PER_LUN * LUN_NUM_PER_DIE)
#define	PAGE_NUM_PER_CHANNEL		(PAGE_NUM_PER_DIE * WAY_NUM)
#define	PAGE_NUM_PER_SSD			(PAGE_NUM_PER_CHANNEL * CHANNEL_NUM)

#define	BLOCK_NUM_PER_DIE		(BLOCK_NUM_PER_LUN * LUN_NUM_PER_DIE)
#define	BLOCK_NUM_PER_CHANNEL	(BLOCK_NUM_PER_DIE * WAY_NUM)
#define	BLOCK_NUM_PER_SSD		(BLOCK_NUM_PER_CHANNEL * CHANNEL_NUM)

#define SSD_SIZE				(BLOCK_NUM_PER_SSD * BLOCK_SIZE_MB) //MB
#define FREE_BLOCK_SIZE			(DIE_NUM * BLOCK_SIZE_MB)			//MB
#define METADATA_BLOCK_SIZE		(DIE_NUM * BLOCK_SIZE_MB)			//MB
#define OVER_PROVISION_BLOCK_SIZE		((BLOCK_NUM_PER_SSD / 20) * BLOCK_SIZE_MB)	//MB

#define BAD_BLOCK_MARK_LOCATION1	0 			//first byte of data region
#define BAD_BLOCK_MARK_LOCATION2 	(PAGE_SIZE)	//first byte of spare region

#define CHUNK_NUM				32
#define BIT_ERROR_THRESHOLD		20
#define RETRY_LIMIT				5				//retry the failed request

#define CHANNEL_NUM_PER_HP_PORT	4

void InitChCtlReg();
void InitDieReqQueue();
void InitDieStatusTable();
void InitNandReset();
void InitFtlMapTable();

extern unsigned int badBlockSize;
extern unsigned int beforeNandReset;
extern unsigned int storageCapacity_L;
extern V2FMCRegisters* chCtlReg[CHANNEL_NUM];

#endif /* INIT_FTL_H_ */
