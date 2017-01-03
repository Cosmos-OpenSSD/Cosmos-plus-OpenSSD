//////////////////////////////////////////////////////////////////////////////////
// d_BCH_encoder_parameters.vh for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//                Ilyong Jung <iyjung@enc.hanyang.ac.kr>
//                Yong Ho Song <yhsong@enc.hanyang.ac.kr>
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
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH Encoder
// Module Name: -
// File Name: d_BCH_encoder_parameters.vh
//
// Version: v1.0.1-256B_T14
//
// Description: 
//   - global parameters for BCH encoder
//   - for data area
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.1
//   - minor modification for releasing
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////



`define D_BCH_ENC_P_LVL 8 // data area BCH encoder parallel level, 8bit I/F with NAND

//`define D_MSG_LENGTH 2048 // data area message length, 256B = 2048b
`define D_BCH_ENC_I_CNT 256 // data area BCH encoder input loop count, 256B chunk / 8b = 256
`define D_BCH_ENC_I_CNT_BIT 9 // must be bigger than D_BCH_ENC_I_CNT, 2^8 = 256

`define D_BCH_ENC_PRT_LENGTH 168 // data area parity length, 14b * 12b/b = 168b
`define D_BCH_ENC_O_CNT 21 // data area BCH encoder output loop count, 168b / 8b = 21
//`define D_BCH_ENC_O_CNT_BIT 6 // 2^6 = 64
