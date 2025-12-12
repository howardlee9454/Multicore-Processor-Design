`ifndef PIPELINE_REGISTER_DE_IF_VH
`define PIPELINE_REGISTER_DE_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface pipeline_register_de_if;
  // import types
  import cpu_types_pkg::*;

    word_t  n1_next_memaddr, n1_imemaddr, rdat1, dat2, imm, rdat2, utype, n2_next_memaddr, n2_imemaddr, n1_rdat1, n1_rdat2, n1_imm, n1_dat2, 
    utype_execute, imemload, n_imemload;
    logic [4:0]wsel, n_wsel, rsel1, rsel2, n_rsel1, n_rsel2;
    logic [2:0]final_mux, branch_select, funct3, n1_final_mux, n1_branch_select, n1_funct3;
    logic [6:0] opcode, funct7, n1_opcode, n1_funct7;
    logic halt, ihit, branch, jump, Mem_Read, Mem_Write, Reg_write, n1_branch, n1_jump, n1_Mem_Read, n1_Mem_Write, n1_Reg_write, flush, stall, n_halt;
    logic ALU_src, n1_ALU_src, atomic, n1_atomic;



  // register file ports
  modport rf (
    input   halt, wsel, n1_next_memaddr, n1_imemaddr, rdat1, imm, rdat2, utype, final_mux, branch_select, funct3, opcode, funct7, ihit, branch, 
    jump, Mem_Read, Mem_Write, Reg_write, rsel1, rsel2, flush, stall,ALU_src, imemload, atomic,
    output  n2_next_memaddr, n2_imemaddr, n1_rdat1, n1_rdat2, n1_imm, utype_execute, n1_final_mux, n1_branch_select, n1_funct3, n1_opcode, n1_funct7,
    n1_branch, n1_jump, n1_Mem_Read, n1_Mem_Write, n1_Reg_write, n_halt, n_wsel, n_rsel1, n_rsel2, n1_ALU_src, n_imemload, n1_atomic
  );
 
endinterface

`endif //REGISTER_FILE_IF_VH