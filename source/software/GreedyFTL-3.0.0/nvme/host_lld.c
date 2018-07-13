//////////////////////////////////////////////////////////////////////////////////
// host_lld.c for Cosmos+ OpenSSD
// Copyright (c) 2016 Hanyang University ENC Lab.
// Contributed by Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//				  Youngjin Jo <yjjo@enc.hanyang.ac.kr>
//				  Sangjin Lee <sjlee@enc.hanyang.ac.kr>
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
// Engineer: Sangjin Lee <sjlee@enc.hanyang.ac.kr>
//			 Jaewook Kwak <jwkwak@enc.hanyang.ac.kr>
//
// Project Name: Cosmos+ OpenSSD
// Design Name: Cosmos+ Firmware
// Module Name: NVMe Low Level Driver
// File Name: host_lld.c
//
// Version: v1.1.0
//
// Description:
//   - defines functions to control the NVMe controller
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.1.0
//	 - DMA partial done check functions are added
//	 - DMA assist status is added to support DMA partial done check functions
//
// * v1.0.0
//   - First draft
//////////////////////////////////////////////////////////////////////////////////

#include "stdio.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "debug.h"
#include "io_access.h"

#include "nvme.h"
#include "host_lld.h"

extern NVME_CONTEXT g_nvmeTask;
HOST_DMA_STATUS g_hostDmaStatus;
HOST_DMA_ASSIST_STATUS g_hostDmaAssistStatus;

void dev_irq_init()
{
	DEV_IRQ_REG devReg;

	devReg.dword = 0;
	devReg.pcieLink = 1;
	devReg.busMaster = 1;
	devReg.pcieIrq = 1;
	devReg.pcieMsi = 1;
	devReg.pcieMsix = 1;
	devReg.nvmeCcEn = 1;
	devReg.nvmeCcShn = 1;
	devReg.mAxiWriteErr = 1;
	devReg.pcieMreqErr = 1;
	devReg.pcieCpldErr = 1;
	devReg.pcieCpldLenErr = 1;

	IO_WRITE32(DEV_IRQ_MASK_REG_ADDR, devReg.dword);
}

void dev_irq_handler()
{
	DEV_IRQ_REG devReg;

//	Xil_ExceptionDisable();

	devReg.dword = IO_READ32(DEV_IRQ_STATUS_REG_ADDR);
	IO_WRITE32(DEV_IRQ_CLEAR_REG_ADDR, devReg.dword);
//	xil_printf("IRQ: 0x%X\r\n", devReg.dword);

	if(devReg.pcieLink == 1)
	{
		PCIE_STATUS_REG pcieReg;
		pcieReg.dword = IO_READ32(PCIE_STATUS_REG_ADDR);
		xil_printf("PCIe Link: %d\r\n", pcieReg.pcieLinkUp);
		if(pcieReg.pcieLinkUp == 0)
			g_nvmeTask.status = NVME_TASK_RESET;
	}

	if(devReg.busMaster == 1)
	{
		PCIE_FUNC_REG pcieReg;
		pcieReg.dword = IO_READ32(PCIE_FUNC_REG_ADDR);
		xil_printf("PCIe Bus Master: %d\r\n", pcieReg.busMaster);
	}

	if(devReg.pcieIrq == 1)
	{
		PCIE_FUNC_REG pcieReg;
		pcieReg.dword = IO_READ32(PCIE_FUNC_REG_ADDR);
		xil_printf("PCIe IRQ Disable: %d\r\n", pcieReg.irqDisable);
	}

	if(devReg.pcieMsi == 1)
	{
		PCIE_FUNC_REG pcieReg;
		pcieReg.dword = IO_READ32(PCIE_FUNC_REG_ADDR);
		xil_printf("PCIe MSI Enable: %d, 0x%x\r\n", pcieReg.msiEnable, pcieReg.msiVecNum);
	}

	if(devReg.pcieMsix == 1)
	{
		PCIE_FUNC_REG pcieReg;
		pcieReg.dword = IO_READ32(PCIE_FUNC_REG_ADDR);
		xil_printf("PCIe MSI-X Enable: %d\r\n", pcieReg.msixEnable);
	}

	if(devReg.nvmeCcEn == 1)
	{
		NVME_STATUS_REG nvmeReg;
		nvmeReg.dword = IO_READ32(NVME_STATUS_REG_ADDR);
		xil_printf("NVME CC.EN: %d\r\n", nvmeReg.ccEn);

		if(nvmeReg.ccEn == 1)
			g_nvmeTask.status = NVME_TASK_WAIT_CC_EN;
		else
			g_nvmeTask.status = NVME_TASK_RESET;
	}

	if(devReg.nvmeCcShn == 1)
	{
		NVME_STATUS_REG nvmeReg;
		nvmeReg.dword = IO_READ32(NVME_STATUS_REG_ADDR);
		xil_printf("NVME CC.SHN: %d\r\n", nvmeReg.ccShn);
		if(nvmeReg.ccShn == 1)
			g_nvmeTask.status = NVME_TASK_SHUTDOWN;
	}

	if(devReg.mAxiWriteErr == 1)
	{
		xil_printf("mAxiWriteErr\r\n");
	}

	if(devReg.pcieMreqErr == 1)
	{
		xil_printf("pcieMreqErr\r\n");
	}

	if(devReg.pcieCpldErr == 1)
	{
		xil_printf("pcieCpldErr\r\n");
	}

	if(devReg.pcieCpldLenErr == 1)
	{
		xil_printf("pcieCpldLenErr\r\n");
	}
//	Xil_ExceptionEnable();
}

unsigned int check_nvme_cc_en()
{
	NVME_STATUS_REG nvmeReg;

	nvmeReg.dword = IO_READ32(NVME_STATUS_REG_ADDR);
	
	return (unsigned int)nvmeReg.ccEn;
}

void set_nvme_csts_rdy(unsigned int rdy)
{
	NVME_STATUS_REG nvmeReg;

	nvmeReg.dword = IO_READ32(NVME_STATUS_REG_ADDR);
	nvmeReg.cstsRdy = rdy;

	IO_WRITE32(NVME_STATUS_REG_ADDR, nvmeReg.dword);
}

void set_nvme_csts_shst(unsigned int shst)
{
	NVME_STATUS_REG nvmeReg;

	nvmeReg.dword = IO_READ32(NVME_STATUS_REG_ADDR);
	nvmeReg.cstsShst = shst;

	IO_WRITE32(NVME_STATUS_REG_ADDR, nvmeReg.dword);
}

void set_nvme_admin_queue(unsigned int sqValid, unsigned int cqValid, unsigned int cqIrqEn)
{
	NVME_ADMIN_QUEUE_SET_REG nvmeReg;

	nvmeReg.dword = IO_READ32(NVME_ADMIN_QUEUE_SET_REG_ADDR);
	nvmeReg.sqValid = sqValid;
	nvmeReg.cqValid = cqValid;
	nvmeReg.cqIrqEn = cqIrqEn;

	IO_WRITE32(NVME_ADMIN_QUEUE_SET_REG_ADDR, nvmeReg.dword);
}


unsigned int get_nvme_cmd(unsigned short *qID, unsigned short *cmdSlotTag, unsigned int *cmdSeqNum, unsigned int *cmdDword)
{
	NVME_CMD_FIFO_REG nvmeReg;
	
	nvmeReg.dword = IO_READ32(NVME_CMD_FIFO_REG_ADDR);

	if(nvmeReg.cmdValid == 1)
	{
		unsigned int addr;
		unsigned int idx;
		*qID = nvmeReg.qID;
		*cmdSlotTag = nvmeReg.cmdSlotTag;
		*cmdSeqNum = nvmeReg.cmdSeqNum;

		addr = NVME_CMD_SRAM_ADDR + (nvmeReg.cmdSlotTag * 64);
		for(idx = 0; idx < 16; idx++)
			*(cmdDword + idx) = IO_READ32(addr + (idx * 4));
	}

	return (unsigned int)nvmeReg.cmdValid;
}

void set_auto_nvme_cpl(unsigned int cmdSlotTag, unsigned int specific, unsigned int statusFieldWord)
{
	NVME_CPL_FIFO_REG nvmeReg;

	nvmeReg.specific = specific;
	nvmeReg.cmdSlotTag = cmdSlotTag;
	nvmeReg.statusFieldWord = statusFieldWord;
	nvmeReg.cplType = AUTO_CPL_TYPE;

	//IO_WRITE32(NVME_CPL_FIFO_REG_ADDR, nvmeReg.dword[0]);
	IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 4), nvmeReg.dword[1]);
	IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 8), nvmeReg.dword[2]);
}

void set_nvme_slot_release(unsigned int cmdSlotTag)
{
	NVME_CPL_FIFO_REG nvmeReg;

	nvmeReg.cmdSlotTag = cmdSlotTag;
	nvmeReg.cplType = CMD_SLOT_RELEASE_TYPE;

	IO_WRITE32(NVME_CPL_FIFO_REG_ADDR, nvmeReg.dword[0]);
	//IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 4), nvmeReg.dword[1]);
	IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 8), nvmeReg.dword[2]);
}

void set_nvme_cpl(unsigned int sqId, unsigned int cid, unsigned int specific, unsigned int statusFieldWord)
{
	NVME_CPL_FIFO_REG nvmeReg;

	nvmeReg.cid = cid;
	nvmeReg.sqId = sqId;
	nvmeReg.specific = specific;
	nvmeReg.statusFieldWord = statusFieldWord;
	nvmeReg.cplType = ONLY_CPL_TYPE;

	IO_WRITE32(NVME_CPL_FIFO_REG_ADDR, nvmeReg.dword[0]);
	IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 4), nvmeReg.dword[1]);
	IO_WRITE32((NVME_CPL_FIFO_REG_ADDR + 8), nvmeReg.dword[2]);
}

void set_io_sq(unsigned int ioSqIdx, unsigned int valid, unsigned int cqVector, unsigned int qSzie, unsigned int pcieBaseAddrL, unsigned int pcieBaseAddrH)
{
	NVME_IO_SQ_SET_REG nvmeReg;
	unsigned int addr;

	nvmeReg.valid = valid;
	nvmeReg.cqVector = cqVector;
	nvmeReg.sqSize = qSzie;
	nvmeReg.pcieBaseAddrL = pcieBaseAddrL;
	nvmeReg.pcieBaseAddrH = pcieBaseAddrH;

	addr = NVME_IO_SQ_SET_REG_ADDR + (ioSqIdx * 8);
	IO_WRITE32(addr, nvmeReg.dword[0]);
	IO_WRITE32((addr + 4), nvmeReg.dword[1]);
}

void set_io_cq(unsigned int ioCqIdx, unsigned int valid, unsigned int irqEn, unsigned int irqVector, unsigned int qSzie, unsigned int pcieBaseAddrL, unsigned int pcieBaseAddrH)
{
	NVME_IO_CQ_SET_REG nvmeReg;
	unsigned int addr;

	nvmeReg.valid = valid;
	nvmeReg.irqEn = irqEn;
	nvmeReg.irqVector = irqVector;
	nvmeReg.cqSize = qSzie;
	nvmeReg.pcieBaseAddrL = pcieBaseAddrL;
	nvmeReg.pcieBaseAddrH = pcieBaseAddrH;

	addr = NVME_IO_CQ_SET_REG_ADDR + (ioCqIdx * 8);
	IO_WRITE32(addr, nvmeReg.dword[0]);
	IO_WRITE32((addr + 4), nvmeReg.dword[1]);

}


void set_direct_tx_dma(unsigned int devAddr, unsigned int pcieAddrH, unsigned int pcieAddrL, unsigned int len)
{
	HOST_DMA_CMD_FIFO_REG hostDmaReg;

	ASSERT((len <= 0x1000) && (pcieAddrH < 0x10) && ((pcieAddrL & 0xF) == 0));
	
	hostDmaReg.devAddr = devAddr;
	hostDmaReg.pcieAddrL = pcieAddrL;
	hostDmaReg.pcieAddrH = pcieAddrH;
	
	hostDmaReg.dword[3] = 0;
	hostDmaReg.dmaType = HOST_DMA_DIRECT_TYPE;
	hostDmaReg.dmaDirection = HOST_DMA_TX_DIRECTION;
	hostDmaReg.dmaLen = len;

	IO_WRITE32(HOST_DMA_CMD_FIFO_REG_ADDR, hostDmaReg.dword[0]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 4), hostDmaReg.dword[1]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 8), hostDmaReg.dword[2]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 12), hostDmaReg.dword[3]);


	g_hostDmaStatus.fifoTail.directDmaTx++;
	g_hostDmaStatus.directDmaTxCnt++;
}

void set_direct_rx_dma(unsigned int devAddr, unsigned int pcieAddrH, unsigned int pcieAddrL, unsigned int len)
{
	HOST_DMA_CMD_FIFO_REG hostDmaReg;

	ASSERT((len <= 0x1000) && (pcieAddrH < 0x10) && ((pcieAddrL & 0xF) == 0));
	
	hostDmaReg.devAddr = devAddr;
	hostDmaReg.pcieAddrH = pcieAddrH;
	hostDmaReg.pcieAddrL = pcieAddrL;

	hostDmaReg.dword[3] = 0;
	hostDmaReg.dmaType = HOST_DMA_DIRECT_TYPE;
	hostDmaReg.dmaDirection = HOST_DMA_RX_DIRECTION;
	hostDmaReg.dmaLen = len;

	IO_WRITE32(HOST_DMA_CMD_FIFO_REG_ADDR, hostDmaReg.dword[0]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 4), hostDmaReg.dword[1]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 8), hostDmaReg.dword[2]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 12), hostDmaReg.dword[3]);

	g_hostDmaStatus.fifoTail.directDmaRx++;
	g_hostDmaStatus.directDmaRxCnt++;

}

void set_auto_tx_dma(unsigned int cmdSlotTag, unsigned int cmd4KBOffset, unsigned int devAddr, unsigned int autoCompletion)
{
	HOST_DMA_CMD_FIFO_REG hostDmaReg;
	unsigned char tempTail;

	ASSERT(cmd4KBOffset < 256);
	
	g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	while((g_hostDmaStatus.fifoTail.autoDmaTx + 1) % 256 == g_hostDmaStatus.fifoHead.autoDmaTx)
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);

	hostDmaReg.devAddr = devAddr;

	hostDmaReg.dword[3] = 0;
	hostDmaReg.dmaType = HOST_DMA_AUTO_TYPE;
	hostDmaReg.dmaDirection = HOST_DMA_TX_DIRECTION;
	hostDmaReg.cmd4KBOffset = cmd4KBOffset;
	hostDmaReg.cmdSlotTag = cmdSlotTag;
	hostDmaReg.autoCompletion = autoCompletion;

	IO_WRITE32(HOST_DMA_CMD_FIFO_REG_ADDR, hostDmaReg.dword[0]);
	//IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 4), hostDmaReg.dword[1]);
	//IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 8), hostDmaReg.dword[2]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 12), hostDmaReg.dword[3]);

	tempTail = g_hostDmaStatus.fifoTail.autoDmaTx++;
	if(tempTail > g_hostDmaStatus.fifoTail.autoDmaTx)
		g_hostDmaAssistStatus.autoDmaTxOverFlowCnt++;

	g_hostDmaStatus.autoDmaTxCnt++;
}

void set_auto_rx_dma(unsigned int cmdSlotTag, unsigned int cmd4KBOffset, unsigned int devAddr, unsigned int autoCompletion)
{
	HOST_DMA_CMD_FIFO_REG hostDmaReg;
	unsigned char tempTail;

	ASSERT(cmd4KBOffset < 256);
	
	g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	while((g_hostDmaStatus.fifoTail.autoDmaRx + 1) % 256 == g_hostDmaStatus.fifoHead.autoDmaRx)
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);

	hostDmaReg.devAddr = devAddr;

	hostDmaReg.dword[3] = 0;
	hostDmaReg.dmaType = HOST_DMA_AUTO_TYPE;
	hostDmaReg.dmaDirection = HOST_DMA_RX_DIRECTION;
	hostDmaReg.cmd4KBOffset = cmd4KBOffset;
	hostDmaReg.cmdSlotTag = cmdSlotTag;
	hostDmaReg.autoCompletion = autoCompletion;

	IO_WRITE32(HOST_DMA_CMD_FIFO_REG_ADDR, hostDmaReg.dword[0]);
	//IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 4), hostDmaReg.dword[1]);
	//IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 8), hostDmaReg.dword[2]);
	IO_WRITE32((HOST_DMA_CMD_FIFO_REG_ADDR + 12), hostDmaReg.dword[3]);

	tempTail = g_hostDmaStatus.fifoTail.autoDmaRx++;
	if(tempTail > g_hostDmaStatus.fifoTail.autoDmaRx)
		g_hostDmaAssistStatus.autoDmaRxOverFlowCnt++;

	g_hostDmaStatus.autoDmaRxCnt++;
}

void check_direct_tx_dma_done()
{
	while(g_hostDmaStatus.fifoHead.directDmaTx != g_hostDmaStatus.fifoTail.directDmaTx)
	{
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	}
}

void check_direct_rx_dma_done()
{
	while(g_hostDmaStatus.fifoHead.directDmaRx != g_hostDmaStatus.fifoTail.directDmaRx)
	{
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	}
}

void check_auto_tx_dma_done()
{
	while(g_hostDmaStatus.fifoHead.autoDmaTx != g_hostDmaStatus.fifoTail.autoDmaTx)
	{
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	}
}

void check_auto_rx_dma_done()
{
	while(g_hostDmaStatus.fifoHead.autoDmaRx != g_hostDmaStatus.fifoTail.autoDmaRx)
	{
		g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);
	}
}

unsigned int check_auto_tx_dma_partial_done(unsigned int tailIndex, unsigned int tailAssistIndex)
{
	//xil_printf("check_auto_tx_dma_partial_done \r\n");

	g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);

	if(g_hostDmaStatus.fifoHead.autoDmaTx == g_hostDmaStatus.fifoTail.autoDmaTx)
		return 1;

	if(g_hostDmaStatus.fifoHead.autoDmaTx < tailIndex)
	{
		if(g_hostDmaStatus.fifoTail.autoDmaTx < tailIndex)
		{
			if(g_hostDmaStatus.fifoTail.autoDmaTx > g_hostDmaStatus.fifoHead.autoDmaTx)
				return 1;
			else
				if(g_hostDmaAssistStatus.autoDmaTxOverFlowCnt != (tailAssistIndex + 1))
					return 1;
		}
		else
			if(g_hostDmaAssistStatus.autoDmaTxOverFlowCnt != tailAssistIndex)
				return 1;

	}
	else if(g_hostDmaStatus.fifoHead.autoDmaTx == tailIndex)
		return 1;
	else
	{
		if(g_hostDmaStatus.fifoTail.autoDmaTx < tailIndex)
			return 1;
		else
		{
			if(g_hostDmaStatus.fifoTail.autoDmaTx > g_hostDmaStatus.fifoHead.autoDmaTx)
				return 1;
			else
				if(g_hostDmaAssistStatus.autoDmaTxOverFlowCnt != tailAssistIndex)
					return 1;
		}
	}

	return 0;
}

unsigned int check_auto_rx_dma_partial_done(unsigned int tailIndex, unsigned int tailAssistIndex)
{
	//xil_printf("check_auto_rx_dma_partial_done \r\n");

	g_hostDmaStatus.fifoHead.dword = IO_READ32(HOST_DMA_FIFO_CNT_REG_ADDR);

	if(g_hostDmaStatus.fifoHead.autoDmaRx == g_hostDmaStatus.fifoTail.autoDmaRx)
		return 1;

	if(g_hostDmaStatus.fifoHead.autoDmaRx < tailIndex)
	{
		if(g_hostDmaStatus.fifoTail.autoDmaRx < tailIndex)
		{
			if(g_hostDmaStatus.fifoTail.autoDmaRx > g_hostDmaStatus.fifoHead.autoDmaRx)
				return 1;
			else
				if(g_hostDmaAssistStatus.autoDmaRxOverFlowCnt != (tailAssistIndex + 1))
					return 1;
		}
		else
			if(g_hostDmaAssistStatus.autoDmaRxOverFlowCnt != tailAssistIndex)
				return 1;

	}
	else if(g_hostDmaStatus.fifoHead.autoDmaRx == tailIndex)
		return 1;
	else
	{
		if(g_hostDmaStatus.fifoTail.autoDmaRx < tailIndex)
			return 1;
		else
		{
			if(g_hostDmaStatus.fifoTail.autoDmaRx > g_hostDmaStatus.fifoHead.autoDmaRx)
				return 1;
			else
				if(g_hostDmaAssistStatus.autoDmaRxOverFlowCnt != tailAssistIndex)
					return 1;
		}
	}

	return 0;
}
