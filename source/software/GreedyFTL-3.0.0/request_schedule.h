//////////////////////////////////////////////////////////////////////////////////
// request_schedule.h for Cosmos+ OpenSSD
// Copyright (c) 2017 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
//			      Sangjin Lee <sjlee@enc.hanyang.ac.kr>
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
// Module Name: Request Scheduler
// File Name: request_schedule.h
//
// Version: v1.0.0
//
// Description:
//   - define parameters, data structure and functions of request scheduler
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////


#ifndef REQUEST_SCHEDULE_H_
#define REQUEST_SCHEDULE_H_

#include "ftl_config.h"

#define WAY_NONE 			0xF

#define LUN_0_BASE_ADDR		0x00000000
#define LUN_1_BASE_ADDR		0x00200000

#define PSEUDO_BAD_BLOCK_MARK	0

#define RETRY_LIMIT				5	//retry the failed request to the extent that the limit number allows

#define DIE_STATE_IDLE			0
#define DIE_STATE_EXE			1

#define REQ_STATUS_CHECK_OPT_NONE 				0
#define REQ_STATUS_CHECK_OPT_CHECK				1
#define REQ_STATUS_CHECK_OPT_REPORT 			2
#define REQ_STATUS_CHECK_OPT_COMPLETION_FLAG 	3

#define REQ_STATUS_RUNNING	0
#define REQ_STATUS_DONE		1
#define REQ_STATUS_FAIL		2
#define REQ_STATUS_WARNING	3

#define ERROR_INFO_FAIL		0
#define ERROR_INFO_PASS		1
#define ERROR_INFO_WARNING	2


typedef struct _COMPLETE_FLAG_TABLE {
	unsigned int completeFlag[USER_CHANNELS][USER_WAYS];
} COMPLETE_FLAG_TABLE, *P_COMPLETE_FLAG_TABLE;

typedef struct _STATUS_REPORT_TABLE {
	unsigned int statusReport[USER_CHANNELS][USER_WAYS];
} STATUS_REPORT_TABLE, *P_STATUS_REPORT_TABLE;

typedef struct _ERROR_INFO_TABLE {
	unsigned int errorInfo[USER_CHANNELS][USER_WAYS][ERROR_INFO_WORD_COUNT];
} ERROR_INFO_TABLE, *P_ERROR_INFO_TABLE;

typedef struct _RETRY_LIMIT_TABLE {
	int retryLimit[USER_CHANNELS][USER_WAYS];
} RETRY_LIMIT_TABLE, *P_RETRY_LIMIT_TABLE;

typedef struct _DIE_STATE_ENTRY {
	unsigned int dieState	:	8;
	unsigned int reqStatusCheckOpt	:	4;
	unsigned int prevWay	:	4;
	unsigned int nextWay 	:	4;
	unsigned int reserved	:	12;
} DIE_STATE_ENTRY, *P_DIE_STATE_ENTRY;

typedef struct _DIE_STATE_TABLE {
	DIE_STATE_ENTRY dieState[USER_CHANNELS][USER_WAYS];
} DIE_STATE_TABLE, *P_DIE_STATE_TABLE;


typedef struct _WAY_PRIORITY_ENTRY {
	unsigned int idleHead :	4;
	unsigned int idleTail :	4;
	unsigned int statusReportHead	:	4;
	unsigned int statusReportTail 	:	4;
	unsigned int readTriggerHead	:	4;
	unsigned int readTriggerTail	:	4;
	unsigned int writeHead	:	4;
	unsigned int writeTail	:	4;
	unsigned int readTransferHead	:	4;
	unsigned int readTransferTail	:	4;
	unsigned int eraseHead	:	4;
	unsigned int eraseTail	:	4;
	unsigned int statusCheckHead	:	4;
	unsigned int statusCheckTail	:	4;
	unsigned int reserved : 8;
} WAY_PRIORITY_ENTRY, *P_WAY_PRIORITY_ENTRY;

typedef struct _WAY_PRIORITY_TABLE {
	WAY_PRIORITY_ENTRY wayPriority[USER_CHANNELS];
} WAY_PRIORITY_TABLE, *P_WAY_PRIORITY_TABLE;


void InitReqScheduler();

void SyncAllLowLevelReqDone();
void SyncAvailFreeReq();
void SyncReleaseEraseReq(unsigned int chNo, unsigned int wayNo, unsigned int blockNo);
void SchedulingNandReq();
void SchedulingNandReqPerCh(unsigned int chNo);

void PutToNandWayPriorityTable(unsigned int reqSlotTag, unsigned int chNo, unsigned int wayNo);
void PutToNandIdleList(unsigned int chNo, unsigned int wayNo);
void SelectivGetFromNandIdleList(unsigned int chNo, unsigned int wayNo);
void PutToNandStatusReportList(unsigned int chNo, unsigned int wayNo);
void SelectivGetFromNandStatusReportList(unsigned int chNo, unsigned int wayNo);
void PutToNandReadTriggerList(unsigned int chNo, unsigned int wayNo);
void SelectiveGetFromNandReadTriggerList(unsigned int chNo, unsigned int wayNo);
void PutToNandWriteList(unsigned int chNo, unsigned int wayNo);
void SelectiveGetFromNandWriteList(unsigned int chNo, unsigned int wayNo);
void PutToNandReadTransferList(unsigned int chNo, unsigned int wayNo);
void SelectiveGetFromNandReadTransferList(unsigned int chNo, unsigned int wayNo);
void PutToNandEraseList(unsigned int chNo, unsigned int wayNo);
void SelectiveGetFromNandEraseList(unsigned int chNo, unsigned int wayNo);
void PutToNandStatusCheckList(unsigned int chNo, unsigned int wayNo);
void SelectiveGetFromNandStatusCheckList(unsigned int chNo, unsigned int wayNo);

void IssueNandReq(unsigned int chNo, unsigned int wayNo);
unsigned int GenerateNandRowAddr(unsigned int reqSlotTag);
unsigned int GenerateDataBufAddr(unsigned int reqSlotTag);
unsigned int GenerateSpareDataBufAddr(unsigned int reqSlotTag);
unsigned int CheckReqStatus(unsigned int chNo, unsigned int wayNo);
unsigned int CheckEccErrorInfo(unsigned int chNo, unsigned int wayNo);

void ExecuteNandReq(unsigned int chNo, unsigned int wayNo, unsigned int reqStatus);


extern P_COMPLETE_FLAG_TABLE completeFlagTablePtr;
extern P_STATUS_REPORT_TABLE statusReportTablePtr;
extern P_ERROR_INFO_TABLE eccErrorInfoTablePtr;
extern P_RETRY_LIMIT_TABLE retryLimitTablePtr;
extern P_DIE_STATE_TABLE dieStatusTablePtr;
extern P_WAY_PRIORITY_TABLE wayPriorityTablePtr;


#endif /* REQUEST_SCHEDULE_H_ */
