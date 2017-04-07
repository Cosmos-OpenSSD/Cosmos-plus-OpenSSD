//////////////////////////////////////////////////////////////////////////////////
// fmc_driver.h for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
//
// Project Name: Cosmos OpenSSD
// Design Name: Cosmos Firmware
// Module Name: Low Level Driver
// File Name: fmc_driver.h
//
// Version: v1.1.0
//
// Description:
//   - define parameters and data structure of the low level driver
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.1.0
//   - V2FReadPageTransferAsync needs additional input (rowAddress)
//   - Opcode of some commands is modified
//   - LLSCommand_ReadRawPage is deleted
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#ifndef FMC_DRIVER_H_
#define FMC_DRIVER_H_

typedef struct
{
	unsigned int cmdSelect;
	unsigned int rowAddress;
	unsigned int userData;
	unsigned int dataAddress;
	unsigned int spareAddress;
	unsigned int errorCountAddress;
	unsigned int completionAddress;
	unsigned int waySelection;
	unsigned int channelBusy;
	unsigned int readyBusy;
} V2FMCRegisters;

#define V2FCommand_NOP 0
#define V2FCommand_Reset 1
#define V2FCommand_SetFeatures 6
#define V2FCommand_GetFeatures 46
#define V2FCommand_ReadPageTrigger 13
#define V2FCommand_ReadPageTransfer 18
#define V2FCommand_ProgramPage 28
#define V2FCommand_BlockErase 37
#define V2FCommand_StatusCheck 41
#define V2FCommand_ReadPageTransferRaw 55


unsigned int V2FIsControllerBusy(V2FMCRegisters* dev);
void V2FResetSync(V2FMCRegisters* dev, int way);
void V2FSetFeaturesSync(V2FMCRegisters* dev, int way, unsigned int feature0x02, unsigned int feature0x10, unsigned int feature0x01, unsigned int payLoadAddr);
void V2FGetFeaturesSync(V2FMCRegisters* dev, int way, unsigned int* feature0x01, unsigned int* feature0x02, unsigned int* feature0x10, unsigned int* feature0x30);
void V2FReadPageTriggerAsync(V2FMCRegisters* dev, int way, unsigned int rowAddress);
void V2FReadPageTransferAsync(V2FMCRegisters* dev, int way, void* pageDataBuffer, void* spareDataBuffer, unsigned int* errorInformation, unsigned int* completion, unsigned int rowAddress);
void V2FReadPageTransferRawAsync(V2FMCRegisters* dev, int way, void* pageDataBuffer, unsigned int* completion);
void V2FProgramPageAsync(V2FMCRegisters* dev, int way, unsigned int rowAddress, void* pageDataBuffer, void* spareDataBuffer);
void V2FEraseBlockAsync(V2FMCRegisters* dev, int way, unsigned int rowAddress);
void V2FStatusCheckAsync(V2FMCRegisters* dev, int way, unsigned int* statusReport);
unsigned int V2FStatusCheckSync(V2FMCRegisters* dev, int way);
unsigned int V2FReadyBusyAsync(V2FMCRegisters* dev);

#define V2FCrcValid(errorInformation) !!((errorInformation) & (0x10000000))
#define V2FSpareChunkValid(errorInformation) !!((errorInformation) & (0x01000000))
#define V2FPageChunkValid(errorInformation) ((errorInformation) == 0xffffffff)
#define V2FWorstChunkErrorCount(errorInformation) (((errorInformation) & 0x00ff0000) >> 16)

#define V2FEnterToggleMode(dev, way) V2FSetFeaturesSync(dev, way, 0x00000006, 0x00000008, 0x00000020, PAY_LOAD_ADDR)

#endif /* FMC_DRIVER_H_ */
