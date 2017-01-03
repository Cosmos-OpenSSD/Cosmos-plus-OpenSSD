//////////////////////////////////////////////////////////////////////////////////
// d_SC_evaluation_matrices.v for Cosmos OpenSSD
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
// Module Name: d_SC_evaluation_matrix_***
// File Name: d_SC_evaluation_matrices.v
//
// Version: v1.0.1-256B_T14
//
// Description: Evaluation matrix for BCH page decoder: syndrome calculator (SC)
//
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

`include "d_SC_parameters.vh"
`timescale 1ns / 1ps

module d_SC_evaluation_matrix_001(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0];
    assign o_out[1] = i_in[1];
    assign o_out[2] = i_in[2];
    assign o_out[3] = i_in[3];
    assign o_out[4] = i_in[4];
    assign o_out[5] = i_in[5];
    assign o_out[6] = i_in[6];
    assign o_out[7] = i_in[7];
    assign o_out[8] = i_in[8];
    assign o_out[9] = i_in[9];
    assign o_out[10] = i_in[10];
    assign o_out[11] = i_in[11];
endmodule

module d_SC_evaluation_matrix_002(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[6] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[9] ^ i_in[11];
    assign o_out[2] = i_in[1] ^ i_in[7] ^ i_in[11];
    assign o_out[3] = i_in[6] ^ i_in[11];
    assign o_out[4] = i_in[2] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[5] = i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[6] = i_in[3] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[7] = i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[8] = i_in[4] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[9] = i_in[7] ^ i_in[9];
    assign o_out[10] = i_in[5] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[8] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_003(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[6] ^ i_in[7] ^ i_in[11];
    assign o_out[2] = i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[4] = i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[5] = i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[10];
    assign o_out[7] = i_in[4] ^ i_in[5] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[9] = i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[10] = i_in[5] ^ i_in[6] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_004(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[1] = i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[2] = i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[3] = i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[4] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[5] = i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[5] ^ i_in[7] ^ i_in[11];
    assign o_out[7] = i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[5] ^ i_in[8] ^ i_in[9];
    assign o_out[11] = i_in[4] ^ i_in[5] ^ i_in[8] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_005(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[4] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[2] = i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[4] = i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[5] = i_in[1] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[9] = i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[11];
    assign o_out[11] = i_in[4] ^ i_in[6] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_006(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[4] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[2] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[11];
    assign o_out[3] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[4] = i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[5] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10];
    assign o_out[6] = i_in[1] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[7] = i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[11];
    assign o_out[11] = i_in[5] ^ i_in[8] ^ i_in[9] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_007(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[10];
    assign o_out[1] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[2] = i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[4] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[10];
    assign o_out[6] = i_in[2] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[7] = i_in[1] ^ i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[11] = i_in[3] ^ i_in[8] ^ i_in[9] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_008(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[2] = i_in[3] ^ i_in[5] ^ i_in[9];
    assign o_out[3] = i_in[4] ^ i_in[7] ^ i_in[8];
    assign o_out[4] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[5] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[9] = i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[4] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[2] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_009(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[5] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[1] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[2] = i_in[4] ^ i_in[8] ^ i_in[10];
    assign o_out[3] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[4] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[8] ^ i_in[10];
    assign o_out[6] = i_in[2] ^ i_in[5] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[3] ^ i_in[7];
    assign o_out[8] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[10] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[11] = i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
endmodule

module d_SC_evaluation_matrix_010(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[1] = i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9];
    assign o_out[2] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[3] ^ i_in[5] ^ i_in[9];
    assign o_out[4] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[5] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[7] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8];
    assign o_out[8] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[9] = i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[11] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_011(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[9];
    assign o_out[2] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[3] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[4] = i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[8] ^ i_in[10];
    assign o_out[6] = i_in[2] ^ i_in[4] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[7] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8];
    assign o_out[8] = i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[9] = i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[11] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_012(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7];
    assign o_out[2] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[1] ^ i_in[3] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[4] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[7] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9];
    assign o_out[8] = i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[11];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_013(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[5] ^ i_in[9] ^ i_in[10];
    assign o_out[1] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7];
    assign o_out[2] = i_in[2] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[3] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[5] = i_in[1] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[10];
    assign o_out[7] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[8] = i_in[1] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7];
    assign o_out[10] = i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9];
endmodule

module d_SC_evaluation_matrix_014(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8];
    assign o_out[2] = i_in[1] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[4] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[5] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[8] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[9];
    assign o_out[7] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10];
    assign o_out[8] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[11];
    assign o_out[10] = i_in[3] ^ i_in[5] ^ i_in[8] ^ i_in[9];
    assign o_out[11] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_015(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6];
    assign o_out[1] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[9];
    assign o_out[2] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10];
    assign o_out[3] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[4] = i_in[4] ^ i_in[5] ^ i_in[9] ^ i_in[11];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[7] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[2] ^ i_in[8] ^ i_in[9] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_016(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[11];
    assign o_out[2] = i_in[6];
    assign o_out[3] = i_in[2] ^ i_in[4] ^ i_in[8] ^ i_in[11];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[8] ^ i_in[10];
    assign o_out[5] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[6] = i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[7] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7];
    assign o_out[8] = i_in[1] ^ i_in[4] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[11] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_017(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10];
    assign o_out[1] = i_in[2] ^ i_in[4] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[2] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[3] = i_in[1] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[4] = i_in[1] ^ i_in[4] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[5] = i_in[1] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8];
    assign o_out[6] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[9] ^ i_in[11];
    assign o_out[7] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9];
    assign o_out[9] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[7];
    assign o_out[10] = i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[11] = i_in[2] ^ i_in[4] ^ i_in[9] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_018(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[10];
    assign o_out[1] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[2] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[4] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[5] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[6] ^ i_in[9];
    assign o_out[8] = i_in[1] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[3] ^ i_in[4] ^ i_in[8];
endmodule

module d_SC_evaluation_matrix_019(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[2] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[9];
    assign o_out[3] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[4] = i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[5] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9];
    assign o_out[6] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[10];
    assign o_out[7] = i_in[1] ^ i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[8] = i_in[6] ^ i_in[9] ^ i_in[11];
    assign o_out[9] = i_in[1] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[8] ^ i_in[10];
    assign o_out[11] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_020(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[3] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[1] = i_in[2] ^ i_in[9];
    assign o_out[2] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[3] = i_in[6] ^ i_in[9];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[6] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[11];
    assign o_out[8] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[9];
    assign o_out[9] = i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[11];
    assign o_out[11] = i_in[1] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_021(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[1] ^ i_in[4] ^ i_in[8] ^ i_in[10];
    assign o_out[2] = i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[3] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[6] ^ i_in[7];
    assign o_out[5] = i_in[1] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[6] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[7] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[8] = i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[11] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[8];
endmodule

module d_SC_evaluation_matrix_022(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8];
    assign o_out[1] = i_in[1] ^ i_in[3] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[2] = i_in[1] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[7] ^ i_in[8];
    assign o_out[4] = i_in[2] ^ i_in[4] ^ i_in[7] ^ i_in[9];
    assign o_out[5] = i_in[1] ^ i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[8];
    assign o_out[7] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[10];
    assign o_out[8] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[10] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[11] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_023(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8];
    assign o_out[1] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[2] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[10];
    assign o_out[3] = i_in[1] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[11];
    assign o_out[5] = i_in[3] ^ i_in[4] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[9];
    assign o_out[7] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[8] = i_in[1] ^ i_in[3] ^ i_in[4];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[10] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[8] ^ i_in[9];
    assign o_out[11] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_024(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[9];
    assign o_out[2] = i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10];
    assign o_out[3] = i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[4] = i_in[2] ^ i_in[3] ^ i_in[8];
    assign o_out[5] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5];
    assign o_out[6] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[7] = i_in[2] ^ i_in[8] ^ i_in[9];
    assign o_out[8] = i_in[1] ^ i_in[6] ^ i_in[8];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[10];
    assign o_out[10] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9];
    assign o_out[11] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[10];
endmodule

module d_SC_evaluation_matrix_025(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[1] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[10];
    assign o_out[2] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[3] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7];
    assign o_out[4] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5];
    assign o_out[5] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[6] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[7] ^ i_in[8] ^ i_in[10] ^ i_in[11];
    assign o_out[7] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7];
    assign o_out[8] = i_in[6] ^ i_in[7] ^ i_in[9];
    assign o_out[9] = i_in[1] ^ i_in[2] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[4] ^ i_in[6] ^ i_in[9];
    assign o_out[11] = i_in[2] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[11];
endmodule

module d_SC_evaluation_matrix_026(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[5] ^ i_in[7] ^ i_in[10] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[6] ^ i_in[9];
    assign o_out[2] = i_in[1] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[11];
    assign o_out[3] = i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[9] ^ i_in[10];
    assign o_out[4] = i_in[1] ^ i_in[3] ^ i_in[5] ^ i_in[9];
    assign o_out[5] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[11];
    assign o_out[6] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[7];
    assign o_out[7] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[6] ^ i_in[8] ^ i_in[11];
    assign o_out[8] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[9] = i_in[2] ^ i_in[3] ^ i_in[9] ^ i_in[11];
    assign o_out[10] = i_in[1] ^ i_in[5] ^ i_in[7] ^ i_in[8] ^ i_in[9];
    assign o_out[11] = i_in[1] ^ i_in[2] ^ i_in[6] ^ i_in[7] ^ i_in[8] ^ i_in[9];
endmodule

module d_SC_evaluation_matrix_027(i_in, o_out);

    input wire [11:0] i_in;
    output wire [`D_SC_GF_ORDER-1:0] o_out;
    assign o_out[0] = i_in[0] ^ i_in[1] ^ i_in[3] ^ i_in[4] ^ i_in[9] ^ i_in[11];
    assign o_out[1] = i_in[2] ^ i_in[5] ^ i_in[6] ^ i_in[8];
    assign o_out[2] = i_in[6] ^ i_in[8] ^ i_in[9];
    assign o_out[3] = i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[8];
    assign o_out[4] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[9];
    assign o_out[5] = i_in[1] ^ i_in[6] ^ i_in[7];
    assign o_out[6] = i_in[3] ^ i_in[4] ^ i_in[5] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[10];
    assign o_out[7] = i_in[1] ^ i_in[4] ^ i_in[6] ^ i_in[8] ^ i_in[9] ^ i_in[11];
    assign o_out[8] = i_in[1] ^ i_in[3] ^ i_in[6] ^ i_in[7];
    assign o_out[9] = i_in[2] ^ i_in[4] ^ i_in[5] ^ i_in[7] ^ i_in[9] ^ i_in[10] ^ i_in[11];
    assign o_out[10] = i_in[3] ^ i_in[8];
    assign o_out[11] = i_in[1] ^ i_in[2] ^ i_in[3] ^ i_in[5] ^ i_in[11];
endmodule



