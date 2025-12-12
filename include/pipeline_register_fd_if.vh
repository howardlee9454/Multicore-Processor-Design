`ifndef PIPELINE_REGISTER_FD_IF_VH
`define PIPELINE_REGISTER_FD_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface pipeline_register_fd_if;
  // import types
  import cpu_types_pkg::*;

    word_t next_memaddr, imemaddr, imemload, n1_next_memaddr,
    n1_imemaddr, n1_imemload;
    logic ihit, stall, flush;



  // register file ports
  modport rf (
    input   next_memaddr, imemaddr, imemload, ihit, stall, flush,
    output  n1_next_memaddr, n1_imemaddr, n1_imemload
  );
  // register file tb
  modport tb (
    input   n1_next_memaddr, n1_imemaddr, n1_imemload,
    output  next_memaddr, imemaddr, imemload, ihit
  );
endinterface

`endif //REGISTER_FILE_IF_VH