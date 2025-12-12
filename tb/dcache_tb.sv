`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
import cpu_types_pkg::*;
// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module dcache_tb;
    parameter PERIOD = 10;
    logic CLK = 0, nRST;
 
  // clock
    always #(PERIOD/2) CLK++;
    datapath_cache_if dcif();
    caches_if cif();

    test PROG (.CLK, .nRST, .dcif, .cif);

 
    dcache DUT(CLK, nRST, dcif, cif);
endmodule

program test(
    input logic CLK, 
    output logic nRST,
    datapath_cache_if.dcache dcif,
    caches_if.dcache cif
);
    initial begin
        // TAG 26 INDEX 3 Block off 1 Byte off 2
        int i, j;
        logic [2:0] k;
        logic l;
        nRST = 0;
        dcif.dmemREN = 0;
        dcif.dmemWEN = 0;
        dcif.dmemaddr = '0;
        cif.dwait = 0;
        cif.dload = '0;
        dcif.dmemstore = '0;
        cif.ccinv = 0;
        cif.ccwait = 0;
        cif.ccsnoopaddr = '0;
        @(negedge CLK);
        nRST = 1;
        dcif.dmemWEN = 1;
        dcif.dmemstore = 32'd64;
        for (i=0; i<8; i++) begin
            l = 1'b0;
            k = i;
            dcif.dmemaddr = {26'd1028, k, l, 2'b0};
            cif.dwait = 1;
            @(negedge CLK);
            cif.dload = (i * 128) + 1;
            cif.dwait = 0;
            @(negedge CLK);
            cif.dload = (i * 1024) + 1;
            @(negedge CLK);
            @(negedge CLK);
            // Working on second Blcok
            l = 1'b1;
            k = i;
            dcif.dmemaddr = {26'd2048, k, l, 2'b0};
            cif.dwait = 1;
            @(negedge CLK);
            cif.dload = (i * 256) + 2;
            cif.dwait = 0;
            @(negedge CLK);
            cif.dload = (i * 2048) + 2;
            @(negedge CLK);
        end
        @(negedge CLK);
        dcif.dmemaddr = {26'd1028, 3'b0, 1'b0, 2'b0};
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        dcif.dmemWEN = 0;
        dcif.dmemREN = 1;
        dcif.halt = 0;
        dcif.dmemaddr = {26'd3, 3'b0, 1'b0, 2'b0};
        cif.dload = 32'd100;
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        dcif.dmemREN = 0;
        dcif.dmemWEN = 1;
        for (i=0; i<8; i++) begin
            l = 1'b0;
            k = i;
            dcif.dmemaddr = {26'd1028, k, l, 2'b0};
            cif.dwait = 1;
            @(negedge CLK);
            cif.dload = (i * 128) + 1;
            cif.dwait = 0;
            @(negedge CLK);
            cif.dload = (i * 1024) + 1;
            @(negedge CLK);
            @(negedge CLK);
            // Working on second Blcok
            l = 1'b1;
            k = i;
            dcif.dmemaddr = {26'd2048, k, l, 2'b0};
            cif.dwait = 1;
            @(negedge CLK);
            cif.dload = (i * 256) + 2;
            cif.dwait = 0;
            @(negedge CLK);
            cif.dload = (i * 2048) + 2;
            @(negedge CLK);
        end
        // Snooping test -----------------------------------------------------------------------------------
        l = 1'b0;
        k = 1;
        dcif.dmemaddr = {26'd1028, k, l, 2'b0};
        cif.dwait = 1;
        @(negedge CLK);
        cif.dload = (i * 128) + 1;
        cif.dwait = 0;
        @(negedge CLK);
        cif.dload = (i * 1024) + 1;
        @(negedge CLK);
        cif.ccwait = 1;
        cif.ccsnoopaddr = {26'd2048, k, l, 2'b0};
        cif.ccinv = 1;
        @(negedge CLK);
        @(negedge CLK);
        cif.dwait = 0;
        cif.ccwait = 0;
        cif.ccinv = 0;
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        // Reperforming dcache action
        l = 1'b0;
        k = 1;
        dcif.dmemaddr = {26'd1028, k, l, 2'b0};
        cif.dwait = 1;
        dcif.dmemstore = 32'd32;
        @(negedge CLK);
        cif.dload = 32'd1234;
        cif.dwait = 0;
        @(negedge CLK);
        cif.dload = 32'd5678;
        @(negedge CLK);
        @(negedge CLK);
        // Working on second Blcok
        l = 1'b1;
        k = 1;
        dcif.dmemaddr = {26'd2048, k, l, 2'b0};
        cif.dwait = 1;
        @(negedge CLK);
        cif.dload = 32'd1000;
        cif.dwait = 0;
        @(negedge CLK);
        cif.dload = 32'd2000;
        @(negedge CLK);
        // End of Snooping Test
        @(negedge CLK);
        dcif.dmemWEN = 0;
        dcif.dmemREN = 1;
        dcif.halt = 1;
        repeat (100) begin
            @(negedge CLK);
        end


    end
endprogram