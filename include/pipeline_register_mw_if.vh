`ifndef PIPELINE_REGISTER_MW_IF_VH
`define PIPELINE_REGISTER_MW_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface pipeline_register_mw_if;
  // import types
  import cpu_types_pkg::*;

    word_t next_memaddr, out_port, utype, dmemload, n_out_port, n_next_memaddr, n_utype, n_dmemload, imemload, n_imemload;
    logic halt, dhit, ihit, Reg_write, n_Reg_write, n_halt,pc_mux, n_pc_mux;
    logic [4:0]wsel, n_wsel;
    logic [2:0] final_mux, n_final_mux;



  // register file ports
  modport rf (
    input   halt, dhit, ihit, out_port, next_memaddr, utype, dmemload, final_mux, wsel, Reg_write, imemload, pc_mux,
    output  n_out_port, n_next_memaddr, n_utype, n_dmemload, n_final_mux, n_Reg_write, n_halt, n_wsel, n_imemload, n_pc_mux
  );
 
endinterface

`endif //REGISTER_FILE_IF_VH