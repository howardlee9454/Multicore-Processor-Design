`ifndef FETCH_DATAPATH_IF_VH
`define FETCH_DATAPATH_IF_VH

// types
`include "cpu_types_pkg.vh"

interface fetch_datapath_if;

    import cpu_types_pkg::*;

    logic CLK, nRST, pc_cntrl, ihit, halt, stall, halt_mem;
    word_t final_memaddr, next_memaddr, imemaddr;

    modport fetch (
        input CLK, nRST, pc_cntrl, ihit, final_memaddr, halt, stall, halt_mem, 
        output next_memaddr, imemaddr
    );

endinterface

`endif 