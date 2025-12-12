`ifndef DECODE_DATAPATH_IF_VH
`define DECODE_DATAPATH_IF_VH

// types
`include "cpu_types_pkg.vh"

interface decode_datapath_if;

    import cpu_types_pkg::*;

    logic CLK, nRST, WEN, Branch, halt, jump, Mem_Read, Mem_Write, Reg_write, u_active, atomic;
    word_t imemload, rdat1, rdat2, dat2, u_type, immediate, wdat, imemaddr;
    logic [4:0] wsel, out_wsel, rsel1, rsel2;
    logic [2:0] branch_select, funct3, final_mux;
    logic [6:0] opcode, funct7; 
    logic ALU_src;

    modport decode (
        input CLK, nRST, WEN, imemload, wsel, wdat, imemaddr, 
        output Branch, halt, jump, Mem_Read, Mem_Write, Reg_write, u_active, out_wsel,
        branch_select, funct3, final_mux, rdat1, rdat2, dat2, u_type, immediate, opcode, funct7,
        rsel1, rsel2, ALU_src, atomic
    );

endinterface

`endif 