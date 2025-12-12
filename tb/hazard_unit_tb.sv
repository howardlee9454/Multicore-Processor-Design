`include "cpu_types_pkg.vh"
`include "hazard_unit_if.vh"
import cpu_types_pkg::*;
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module hazard_unit_tb;

  parameter PERIOD = 10;
  logic CLK = 0;
 
  // clock
  always #(PERIOD/2) CLK++;
    hazard_unit_if huif();

    test PROG (.CLK, .huif);

 
    hazard_unit DUT(huif);
  
endmodule

program test(
    input logic CLK,
    hazard_unit_if.tb huif

);
  
    
    
  initial begin
    
    //Test1:
    @(posedge CLK);
    huif.MemRead = 0;
    huif.rsel1 = 0;
    huif.rsel2 = 0;
    huif.wsel = 0;
    huif.pc_mux = 0;
    @(posedge CLK);
    huif.MemRead = 0;
    huif.rsel1 = 2;
    huif.rsel2 = 2;
    huif.wsel = 5;
    huif.pc_mux = 1;
    @(posedge CLK);
    huif.MemRead = 1;
    huif.rsel1 = 2;
    huif.rsel2 = 2;
    huif.wsel = 2;
    huif.pc_mux = 0;
    @(posedge CLK);
  end
endprogram