`ifndef PIPELINE_REGISTER_EM_IF_VH
`define PIPELINE_REGISTER_EM_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface pipeline_register_em_if;
  // import types
  import cpu_types_pkg::*;

    word_t next_memaddr, out_port, rdat2, utype, n_out_port, n_next_memaddr, n_rdat2, n_utype, imemload, n_imemload, final_memaddr, n_final_memaddr;
    logic halt, ihit, dhit, Mem_Read, Mem_Write, Reg_write, dmemWEN, dmemREN, n_Reg_write, n_halt, pc_mux, pc_cntrl, n_pc_mux, n_pc_cntrl, 
    flush, mw_pc_mux, n1_atomic, n2_atomic;
    logic [4:0]wsel, n_wsel;
    logic [2:0] final_mux, n_final_mux;



  // register file ports
  modport rf (
    input   halt, out_port, next_memaddr, rdat2, utype, wsel, final_mux, ihit, dhit, Mem_Read, Mem_Write, Reg_write, imemload, 
            pc_mux, pc_cntrl, final_memaddr, flush,mw_pc_mux, n1_atomic,
    output  n_out_port, n_next_memaddr, n_rdat2, n_utype, n_final_mux, dmemWEN, dmemREN, n_Reg_write, n_halt, n_wsel, n_imemload,
            n_pc_mux, n_pc_cntrl, n_final_memaddr, n2_atomic
  );
  
endinterface

`endif //REGISTER_FILE_IF_VH