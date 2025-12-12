`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface hazard_unit_if;
  // import types
  import cpu_types_pkg::*;

    logic flush, stall, pc_mux, MemRead, halt, datomic
    ;
    logic [4:0] wsel, rsel1, rsel2;



  // register file ports
  modport rf (
    input   pc_mux, MemRead, wsel, rsel1, rsel2, halt, datomic,
    output  flush, stall
  );
  // register file tb
  modport tb (
    input   flush, stall,
    output  pc_mux, MemRead, wsel, rsel1, rsel2, halt, datomic
  );
endinterface

`endif //REGISTER_FILE_IF_VH