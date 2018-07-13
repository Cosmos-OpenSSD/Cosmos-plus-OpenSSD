//////////////////////////////////////////////////////////////////////////////////
// nvme_identify.h for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Youngjin Jo <yjjo@enc.hanyang.ac.kr>
//				  Sangjin Lee <sjlee@enc.hanyang.ac.kr>
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
// Engineer: Sangjin Lee <sjlee@enc.hanyang.ac.kr>
//
// Project Name: Cosmos+ OpenSSD
// Design Name: Cosmos+ Firmware
// Module Name: NVMe Identifier
// File Name: nvme_identify.h
//
// Version: v1.0.0
//
// Description:
//   - declares functions for generating identify data
//   - defines parameters of NVMe identifier
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////


#ifndef __NVME_IDENTIFY_H_
#define __NVME_IDENTIFY_H_

#define PCI_VENDOR_ID				0x1EDC
#define PCI_SUBSYSTEM_VENDOR_ID		0x1EDC
#define SERIAL_NUMBER				"SSDD515T"
#define MODEL_NUMBER				"Cosmos+ OpenSSD"
#define FIRMWARE_REVISION			"TYPE0005"

void identify_controller(unsigned int pBuffer);

void identify_namespace(unsigned int pBuffer);


#endif	//__NVME_IDENTIFY_H_
