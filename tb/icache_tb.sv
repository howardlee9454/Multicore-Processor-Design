`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
import cpu_types_pkg::*;
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module icache_tb;

  parameter PERIOD = 10;
  logic CLK = 0, nRST;
 
  // clock
  always #(PERIOD/2) CLK++;
    datapath_cache_if dcif();
    caches_if cif();

    test PROG (.CLK, .nRST, .dcif, .cif);

 
   icache DUT(CLK, nRST, dcif, cif);
  
endmodule

program test(
    input logic CLK, 
    output logic nRST,
    datapath_cache_if.icache dcif,
    caches_if.icache cif
);
  initial begin
    // cif
    // input   iwait, iload,
    // output  iREN, iaddr
    // dcif
    // input   imemREN, imemaddr,
    // output  ihit, imemload
    //Test1:
    int i;
    logic [3:0] j;
    nRST = 0;
    dcif.imemREN = 1;
    dcif.imemaddr = '0;
    cif.iwait = 1;
    cif.iload = 0;
    @(negedge CLK);
    @(negedge CLK);
    nRST = 1;
    for (i=0; i<16; i++) begin
      j = i;
      dcif.imemaddr = {26'd1028, j, 2'b0};  // h123456 b1100 1100
      cif.iwait = 1;
      @(negedge CLK);
      cif.iload = i * 128;
      cif.iwait = 0;
      @(negedge CLK);
    end

    dcif.imemaddr = {26'd2048, 4'd0, 2'd0};
    cif.iwait = 1;
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
    cif.iload = 32'h12345678;
    cif.iwait = 0;


  end
endprogram