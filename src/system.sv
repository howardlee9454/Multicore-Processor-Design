/*
  Eric Villasenor
  evillase@gmail.com
  Jimmy Jin
  mingze.jin01@gmail.com

  system top block wraps processor(datapath+cache)
  and memory (ram).
*/

// system interface
`include "system_if.vh"

// types
`include "cpu_types_pkg.vh"

module system (
  input logic CLK, nRST,
  system_if.sys syif,

  // dbg passthrough for bram
  input  logic [13:0]               dbg_addr,
  output logic [31:0]               dbg_data_out
);
// TODO: TODO: TODO: 
// 1. Note this is the top level module that will call different processors (single-cycle, multi-cycle, etc.). 
// 2. Make sure you instantantiate all the processors with CPUCLK instead of CLK
  // stopped running
  logic halt; // instruction to stop running the current assembly file

  // clock division
  logic CPUCLK;

  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST)
      CPUCLK <= 1'b0;
    else
      CPUCLK <= ~CPUCLK;
  end

  // interface
  cpu_ram_if                            prif ();

  // processor
  //singlecycle #(.PC0('h0))              CPU (CPUCLK, nRST, halt, prif);
  //pipeline    #(.PC0('h0))              CPU (CPUCLK, nRST, halt, prif);
   multicore   #(.PC0('h0), .PC1('h200)) CPU (CPUCLK, nRST, halt, prif);

  // memory
  ram RAM (
    .CLK(CLK),
    .nRST(nRST),
    .halt(halt),
    .ramif(prif),
    .dbg_addr (dbg_addr),
    .dbg_data_out(dbg_data_out)
  );  

  // interface connections
  assign syif.halt = halt;
  assign syif.load = prif.ramload;

  // who has ram control
  assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
  assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
  assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
  assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule
