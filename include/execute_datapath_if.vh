`ifndef EXECUTE_DATAPATH_IF_VH
`define EXECUTE_DATAPATH_IF_VH

// types
`include "cpu_types_pkg.vh"

interface execute_datapath_if;

    import cpu_types_pkg::*;

    logic pc_mux,branch, jump, ihit, pc_cntrl;
    word_t rdat1, dat2, immediate, imemaddr, out_port, final_memaddr, next_memaddr;
    logic [2:0] funct3, branch_select;
    logic [6:0] opcode, funct7;

    modport execute (
        input rdat1, dat2, immediate, imemaddr, funct3, branch_select, opcode, funct7, branch, jump, ihit, next_memaddr,
        output out_port, final_memaddr, pc_cntrl, pc_mux
    );

endinterface

`endif 