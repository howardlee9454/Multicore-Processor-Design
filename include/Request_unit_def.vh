`ifndef REQUEST_UNIT_DEF_VH
`define REQUEST_UNIT_DEF_VH

`include "cpu_types_pkg.vh"

interface Request_unit_def;

    import cpu_types_pkg::*;

    logic ihit, dhit, Mem_Read, Mem_Write, dmemREN, dmemWEN, imemREN;

    modport RU(
        input ihit, dhit, Mem_Read, Mem_Write,
        output dmemREN, dmemWEN, imemREN
    );

    modport RU_tb(
        output ihit, dhit, Mem_Read, Mem_Write,
        input dmemREN, dmemWEN, imemREN
    );

    endinterface
    

    `endif