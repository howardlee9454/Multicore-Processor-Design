`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
`include "Request_unit_def.vh"

module Request_unit_tb();

    parameter PERIOD = 10;

    logic CLK = 0; 
    logic nRST;

    // clock
    always #(PERIOD/2) CLK++;

    Request_unit_def RU();

    test PROG(CLK, nRST, RU);

    `ifndef MAPPED
    Request_unit DUT(CLK, nRST, RU); 
    `else

    Request_unit DUT(
        .\RU.ihit (RU.ihit),
        .\RU.dhit (RU.Branch),
        .\RU.Mem_read, (RU.Mem_read),
        .\RU.Mem_Write (RU.Mem_Write),
        .\RU.dmemREN (RU.dmemREN),
        .\RU.dmemWEN (RU.dmemWEN),
        .\RU.imemREN (RU.imemREN)
        .\nRST (nRST),
        .\CLK (CLK)
    );

`endif

    endmodule


program test(
    input logic CLK, 
    output logic nRST,
    Request_unit_def.RU_tb RU
);
    initial begin
    
    nRST = 1;
    @(posedge CLK);
    @(posedge CLK);
    RU.ihit = 1;
    RU.Mem_Read = 1;
    @(posedge CLK);
    @(posedge CLK);
    RU.Mem_Write = 1;
    @(posedge CLK);
    @(posedge CLK);
    RU.dhit = 1;
    @(posedge CLK);
    @(posedge CLK);


    end

endprogram
