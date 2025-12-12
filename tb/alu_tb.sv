`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
`include "alu_def.vh"
import cpu_types_pkg::*;

module alu_tb;
    parameter PERIOD = 10;

    logic CLK = 0; 

    // clock
    always #(PERIOD/2) CLK++;

    // Interface ??
    alu_def alu_mod();

    // sending values to program ??
    test PROG(CLK, alu_mod);

    `ifndef MAPPED
    // Calling DUT
    alu DUT(alu_mod);
    `else
    alu DUT(
        .\alu_mod.porta (alu_mod.porta),
        .\alu_mod.portb (alu_mod.portb),
        .\alu_mod.aluop (alu_mod.aluop),
        .\alu_mod.negative (alu_mod.negative),
        .\alu_mod.out_port (alu_mod.out_port),
        .\alu_mod.overflow (alu_mod.overflow),
        .\alu_mod.zero (alu_mod.zero)
    );

//       modport alu_ports(
//     input porta, portb, aluop,
//     output negative, out_port, overflow, zero
//   );   
    `endif

endmodule

program test(

    input logic CLK,
    alu_def.alu_tb alu_mod

);
    initial begin
        alu_mod.porta = 32'h0001;
        alu_mod.portb = 32'h0001;
        alu_mod.aluop = ALU_SLL; // working 
        @(posedge CLK);
        alu_mod.porta = 32'h80000000;
        alu_mod.portb = 32'h00000001;
        alu_mod.aluop = ALU_SRL; // working 
        @(posedge CLK);
        alu_mod.porta = 32'hC0000000;
        alu_mod.portb = 32'h00000001;
        alu_mod.aluop = ALU_SRA; // working (copies signed bit and shifts it in)
        @(posedge CLK);
        alu_mod.porta = 32'h7FFFFFFF;
        alu_mod.portb = 32'h7FFFFFFF;
        alu_mod.aluop = ALU_ADD; // working
        @(posedge CLK);
        alu_mod.porta = 32'h80000000;
        alu_mod.portb = 32'h00000008;
        alu_mod.aluop = ALU_SUB; // working
        @(posedge CLK);
        alu_mod.porta = 32'h000F;
        alu_mod.portb = 32'h0003;
        alu_mod.aluop = ALU_AND; // working
        @(posedge CLK);
        alu_mod.porta = 32'h000F;
        alu_mod.portb = 32'h0003;
        alu_mod.aluop = ALU_OR; // working
        @(posedge CLK);
        alu_mod.porta = 32'h0005;
        alu_mod.portb = 32'h000A;
        alu_mod.aluop = ALU_XOR; // working
        @(posedge CLK);
        alu_mod.porta = 32'h00000001;
        alu_mod.portb = 32'hFFFFFFFF;
        alu_mod.aluop = ALU_SLT; // working
        @(posedge CLK);
        alu_mod.porta = 32'h00000001;
        alu_mod.portb = 32'hFFFFFFFF; // working
        alu_mod.aluop = ALU_SLTU;
        @(posedge CLK);
    end

endprogram