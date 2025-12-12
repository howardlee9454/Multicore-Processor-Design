`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
import cpu_types_pkg::*;
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module bus_controller_tb;
    parameter PERIOD = 10;
    logic CLK = 0, nRST;
    logic halt;
    logic [13:0]               dbg_addr;
    logic [31:0]               dbg_data_out;
  // clock
    always #(PERIOD/2) CLK++;
    // datapath_cache_if dcif();
    // caches_if cif();
    caches_if cif0();
    caches_if cif1();
    cache_control_if ccif(cif0, cif1);
    cpu_ram_if rif();

    always_comb begin
        ccif.ramload = rif.ramload;
        ccif.ramstate = rif.ramstate;
        rif.ramWEN = ccif.ramWEN;
        rif.ramREN = ccif.ramREN;
        rif.ramstore = ccif.ramstore;
        rif.ramaddr = ccif.ramaddr;
    end
   
    bus_controller DUT(CLK, nRST, ccif);
    ram c1(CLK, nRST, halt, rif, dbg_addr, dbg_data_out);
    test PROG (.CLK, .nRST, .ccif, .halt, .rif);
endmodule

program test(
    input logic CLK, 
    input logic [31:0] dbg_data_out,
    output logic nRST, halt, 
    output logic [13:0] dbg_addr, 
    cache_control_if.cc ccif,
    cpu_ram_if.ram rif
);
    initial begin
        nRST = 0;
        halt = 0;
        cif0.iREN = 0;
        cif0.dREN = 0;
        cif0.dWEN = 0;
        cif0.dstore = 0;
        cif0.iaddr = 0;
        cif0.daddr = 0;
        cif0.ccwrite = 0;
        cif0.cctrans = 0;

        cif1.iREN = 0;
        cif1.dREN = 0;
        cif1.dWEN = 0;
        cif1.dstore = 0;
        cif1.iaddr = 0;
        cif1.daddr = 0;
        cif1.ccwrite = 0;
        cif1.cctrans = 0;
        @(posedge CLK);
        // TESTING icache logic -----------------------------------------------------------------------------
        @(posedge CLK);
        nRST = 1;
        cif1.iREN = 1;
        cif1.iaddr = 32'd4;
        @(posedge CLK);
        @(posedge CLK);
        cif1.iREN = 0;
        @(posedge CLK);
        cif0.iREN = 1;
        cif0.iaddr = 32'd8;
        @(posedge CLK);
        @(posedge CLK);
        cif0.iREN = 0;
        @(posedge CLK);
        @(posedge CLK);
        cif0.iaddr = '0;
        cif1.iaddr = '0;
        // TESTING dcache logic (WRITE HIT) -------------------------------------------------------------------
        cif1.dWEN = 1;
       
        @(posedge CLK);
         cif1.dstore = 32'hDEAD1234;
        cif1.daddr = 32'd1;
        @(posedge CLK);
        @(posedge CLK);
        cif1.dstore = 32'h1234BEEF;
        cif1.daddr = 32'd1;
        @(posedge CLK);
        cif1.dWEN = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dWEN = 1;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dstore = 32'h12DEAD34;
        cif0.daddr = 32'd2;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dstore = 32'h12BEEF34;
        cif0.daddr = 32'd2;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dWEN = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.daddr = '0;
        cif0.dstore = '0;
        cif1.daddr = '0;
        cif1.dstore = '0;
        // TESTING dcache logic (reading) -------------------------------------------------------------------
        cif1.dREN = 1;
        cif1.daddr = 32'd2;
        @(posedge CLK);
        // ccwait should be high for the other cache (cif0)
        @(posedge CLK);
        // This should be where snoop address is set
        @(posedge CLK);
        // First data is being loaded from memory
        @(posedge CLK);
        ///cif1.daddr = 32'd1;
        @(posedge CLK);
        cif1.daddr = 32'd1;
        @(posedge CLK);
        @(posedge CLK);
        cif1.dREN = 0;
        @(posedge CLK);
        cif0.dREN = 1;
        cif0.daddr = 32'd2;
        @(posedge CLK);
        // ccwait should be high for the other cache (cif1)
        @(posedge CLK);
        // This should be where snoop address is set
        cif1.cctrans = 1;
        @(posedge CLK);
        cif1.cctrans = 0;
        cif1.dstore = 32'hBEEEEEEF;
        // First data is being loaded from memory
        @(posedge CLK);
        ///cif1.daddr = 32'd1;
        @(posedge CLK);
        cif0.daddr = 32'd1;
        cif1.dstore = 32'hBEEFDEAD;
        @(posedge CLK);
        @(posedge CLK);
        cif0.dREN = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);

    end
endprogram