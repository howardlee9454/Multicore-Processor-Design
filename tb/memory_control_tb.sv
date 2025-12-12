// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

`include "caches_if.vh"
`include "cpu_ram_if.vh"

`timescale 1 ns / 1 ns

module memory_control_tb ();

    parameter PERIOD = 10;
    logic CLK = 0, nRST;

    always #(PERIOD/2) CLK++;

    caches_if cif0();
    caches_if cif1();
    cache_control_if ccif(cif0, cif1);
    cpu_ram_if ramif();

    logic tbCTRL;
    test PROG (CLK, nRST, ccif, tbCTRL);
 
    memory_control DUT(CLK, nRST, ccif);

    ram DUT2(.CLK(CLK), .nRST(nRST), .ramif(ramif));

    always_comb begin
        ramif.ramaddr = ccif.ramaddr;
        ramif.ramstore = ccif.ramstore;
        ramif.ramREN = ccif.ramREN;
        ramif.ramWEN = ccif.ramWEN;
        ccif.ramload = ramif.ramload;
        ccif.ramstate = ramif.ramstate;
    end

endmodule

program test(
    input logic CLK,
    output logic nRST,
    cache_control_if.cc ccif,
    output logic tbCTRL
);

    task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

    // cif0.tbCTRL = 1;
    cif0.daddr = 0;
    cif0.dWEN = 0;
    cif0.dREN = 0;

    memfd = $fopen(filename,"w");
    if (memfd)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      cif0.daddr = i << 2;
      cif0.dREN = 1;
      repeat (4) @(posedge CLK);
      if (cif0.dload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,cif0.dload};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      //cif0.tbCTRL = 0;
      cif0.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
    endtask

    initial begin
        @(posedge CLK);
        @(posedge CLK);
        cif0.iaddr = 32'd4;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        nRST = 1'b1;
        cif0.dWEN = 0;
        cif0.iREN = 1'b1;
        cif0.dREN = 1'b1;
        cif0.daddr = 32'h8;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dREN = 0;
        cif0.dWEN = 1;
        cif0.daddr = 32'h8;
        cif0.dstore = 32'h5678;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dWEN = 0;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dREN = 0;
        cif0.dWEN = 1;
        cif0.daddr = 32'd32;
        cif0.dstore = 32'h1234;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        cif0.dWEN = 0;
        cif0.dstore = '0;

        

        

        dump_memory();
    end
endprogram