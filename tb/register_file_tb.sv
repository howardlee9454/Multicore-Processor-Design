/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (CLK, nRST, rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test(

  input logic CLK, 
  output logic nRST,
  register_file_if.tb rfif

);
  int j = 1;
  int i;
  initial begin
    rfif.rsel1 = '0;
    rfif.rsel2 = '0;
    nRST = 1'b0;
    @(posedge CLK);
    nRST = 1'b1;
    rfif.wsel = 5'd0;
    rfif.wdat = 32'd1;
    @(posedge CLK);
    rfif.WEN = 1'd0;
    @(posedge CLK);
    rfif.wsel = 5'd0;
    rfif.wdat = 32'd1;
    @(posedge CLK);
    rfif.wsel = 5'd1;
    rfif.wdat = 32'd4721;
    @(posedge CLK);
    rfif.wsel = 5'd2;
    rfif.wdat = 32'd25119;
    @(posedge CLK);
    rfif.WEN = 1'd1;

    for(i=0;i<32;i++) begin
      rfif.wsel = i;
      rfif.wdat = 10 + j;
      @(posedge CLK);
      j++;
    end

    for(i=0;i<32;i++) begin
      rfif.rsel1 = i;
      @(posedge CLK);
      rfif.rsel2 = i;
      @(posedge CLK);
    end


    rfif.wdat = 32'd4;
    rfif.wsel = 5'd4;
    @(posedge CLK);
    nRST = 1'b0;
    for(i=0;i<32;i++) begin
      rfif.rsel1 = i;
      @(posedge CLK);
      rfif.rsel2 = i;
      @(posedge CLK);
    end

  end

endprogram
