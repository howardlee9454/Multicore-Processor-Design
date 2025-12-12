`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
`include "Forward_unit_def.vh"

import cpu_types_pkg::*;

module Forward_unit_tb;

    parameter PERIOD = 10;

    logic CLK = 0; 

    // clock
    always #(PERIOD/2) CLK++;

    Forward_unit_def fu();

    test PROG(CLK, fu);

    `ifndef MAPPED

    Forward_unit DUT(fu);

    `else

    Forward_unit DUT(
        .\fu.wsel_writeback (fu.wsel_writeback),
        .\fu.wsel_memory (fu.wsel_memory),
        .\fu.Reg_write_writeback (fu.Reg_write_writeback),
        .\fu.Reg_write_memory (fu.Reg_write_memory),
        .\fu.rsel1 (fu.rsel1),
        .\fu.rsel2 (fu.rsel2),
        .\fu.forward1 (fu.forward1),
        .\fu.forward2 (fu.forward2)
    );

    `endif

endmodule

program test(
    input logic CLK,
    Forward_unit_def.frwd_tb fu
);
    initial begin

        fu.wsel_writeback = '0;
        fu.wsel_memory = '0;
        fu.Reg_write_writeback = 0;
        fu.Reg_write_memory = 0;
        fu.rsel1 = '0;
        fu.rsel2 = '0;
        @(posedge CLK);
        @(posedge CLK);
        fu.Reg_write_writeback = 1;
        fu.Reg_write_memory = 1;
        fu.wsel_writeback = 5'd3;
        fu.wsel_memory = 5'd3;
        fu.rsel1 = 5'd3;
        @(posedge CLK);
        @(posedge CLK);
        fu.Reg_write_memory = 0;
        fu.wsel_memory = 5'd0;
        @(posedge CLK);
        @(posedge CLK);
        fu.Reg_write_writeback = 1;
        fu.Reg_write_memory = 1;
        fu.wsel_writeback = 5'd5;
        fu.wsel_memory = 5'd5;
        fu.rsel2 = 5'd5;
        @(posedge CLK);
        @(posedge CLK);
        fu.Reg_write_memory = 0;
        fu.wsel_memory = 5'd0;
        @(posedge CLK);
        @(posedge CLK); 
    end
endprogram