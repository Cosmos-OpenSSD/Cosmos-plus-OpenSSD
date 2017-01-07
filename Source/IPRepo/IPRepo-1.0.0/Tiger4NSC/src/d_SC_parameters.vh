//////////////////////////////////////////////////////////////////////////////////
// d_SC_parameters.vh for Cosmos OpenSSD
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
// Engineer: Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//           Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH Page Decoder
// Module Name: -
// File Name: d_SC_parameters.vh
//
// Version: v1.1.0-256B_T14
//
// Description: 
//   - global parameters for BCH decoder: syndrome calculator (SC)
//   - for data area
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.1.0
//   - change the specification
//
// * v1.0.1
//   - minor modification for releasing
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`define D_SC_GF_ORDER 12 // Galois field order, GF(2^12)
`define D_SC_ECC_T 14 // error correction capability t = 14

`define D_SC_P_LVL 8 // data area BCH decoder SC parallel level, 8bit I/F with NAND

`define D_SC_I_CNT 277 // received coded message length, (256B chunk + 21B parity) / 8b = 277
`define D_SC_I_CNT_BIT 9 // 2^8 = 256

`define D_SC_MSG_LENGTH 256 // message length, 256B chunk / 8b = 256
`define D_SC_MSG_LENGTH_BIT 8 // 2^8 = 256
