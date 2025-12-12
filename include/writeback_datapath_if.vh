`ifndef WRITEBACK_DATAPATH_IF_VH
`define WRITEBACK_DATAPATH_IF_VH

// types
`include "cpu_types_pkg.vh"

interface writeback_datapath_if;

    import cpu_types_pkg::*;

    logic temp_halt, halt;
    logic [2:0] final_mux;
    word_t dmemload, out_port, next_memaddr, u_type, wdat;

    modport writeback (
        input final_mux, dmemload, out_port, next_memaddr, u_type, temp_halt,
        output wdat, halt
    );

endinterface

`endif 