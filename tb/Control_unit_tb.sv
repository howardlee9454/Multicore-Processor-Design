`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
`include "Control_unit_def.vh"

module Control_unit_tb();

    parameter PERIOD = 10;

    logic CLK = 0; 

    // clock
    always #(PERIOD/2) CLK++;

    Control_unit_def CU();

    test PROG(CLK, CU);

    `ifndef MAPPED
    Control_unit DUT(CU); 
    `else

    Control_unit DUT(
        .\CU.opcode (CU.opcode),
        .\CU.Branch (CU.Branch),
        .\CU.halt, (CU.halt),
        .\CU.MemtoReg (CU.MemtoReg),
        .\CU.Mem_Read (CU.Mem_Read),
        .\CU.Mem_Write (CU.Mem_Write),
        .\CU.ALU_src (CU.ALU_src),
        .\CU.Reg_write (CU.Reg_write),
        .\CU.funct3_enable (CU.funct3_enable)
    );

`endif

    endmodule


program test(
    input logic CLK,
    Control_unit_def.CU_tb CU
);
    initial begin
    CU.opcode = 7'b0000011; // lw 
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b0010011; // I type
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b0100011; // sw
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b0110011; // R type
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b0110111; // lui
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b1100011; // branch
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b1101111; // jal
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b1100111; // jalr
    @(posedge CLK);
    @(posedge CLK);
    CU.opcode = 7'b1111111; // halt
    @(posedge CLK);
    @(posedge CLK);


    end

endprogram
