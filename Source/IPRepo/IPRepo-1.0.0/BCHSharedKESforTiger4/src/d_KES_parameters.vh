//////////////////////////////////////////////////////////////////////////////////
// d_KES_parameters.vh for Cosmos OpenSSD
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
// File Name: d_KES_parameters.vh
//
// Version: v1.0.1-256B_T14
//
// Description: 
//   - global parameters for BCH decoder: key equation solver (KES)
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

`define D_KES_GF_ORDER 12 // Galois field order, GF(2^15)

`define D_KES_ECC_T 14 // error correction capability t = 32
`define D_KES_ECC_T_BIT 4 // must be bigger than D_KES_ECC_T, 2^6 = 64

`define D_KES_L_CNT 14 // key equation solver loop count, D_KES_ECC_T = 32
`define D_KES_L_CNT_BIT 4 // must be bigger than D_KES_L_CNT, 2^6 = 64

//parameter ECC_PARAM_T = 32; // t = 32
//parameter KES_LOOP_COUNT = 32; // t = 32
//parameter KES_LOOP_COUNT_BIT = 6; // must be bigger than t, 2^6 = 64
