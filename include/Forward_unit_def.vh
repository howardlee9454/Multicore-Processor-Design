`ifndef FORWARD_UNIT_DEF_VH
`define FORWARD_UNIT_DEF_VH

// types
`include "cpu_types_pkg.vh"

interface Forward_unit_def;

    import cpu_types_pkg::*;

    logic Reg_write_writeback, Reg_write_memory;
    logic [4:0] wsel_writeback, wsel_memory, rsel1, rsel2;
    logic [1:0] forward1, forward2;

    modport frwd (
        input wsel_writeback, wsel_memory, Reg_write_writeback, Reg_write_memory, rsel1, rsel2,
        output forward1, forward2
    );

    modport frwd_tb (
        output wsel_writeback, wsel_memory, Reg_write_writeback, Reg_write_memory, rsel1, rsel2,
        input forward1, forward2
    );

endinterface

`endif 