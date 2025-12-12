`ifndef CONTROL_UNIT_DEF_VH
`define CONTROL_UNIT_DEF_VH

`include "cpu_types_pkg.vh"

interface Control_unit_def;

    import cpu_types_pkg::*;

    logic [6:0] opcode;
    logic [4:0] funct5;
    logic jump, Branch, halt, MemtoReg, Mem_Read, Mem_Write, ALU_src, Reg_write, funct3_enable, atomic;

    modport CU(
        input opcode, funct5,
        output Branch, jump, halt, MemtoReg, Mem_Read, Mem_Write, ALU_src, Reg_write, funct3_enable, atomic
    );

    modport CU_tb(
        output opcode, funct5,
        input Branch, halt, MemtoReg, Mem_Read, Mem_Write, ALU_src, Reg_write, funct3_enable, atomic
    );

    endinterface
    

    `endif