/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "hazard_unit_if.vh"

// memory types
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

module hazard_unit(
  hazard_unit_if.rf huif
);
  // type import
  import cpu_types_pkg::*;
    always_comb begin : ld_use
        huif.flush = 0;
        huif.stall = 0;
        if(huif.pc_mux || huif.halt)begin
            huif.flush = 1;
        end 
        else if((huif.MemRead || huif.datomic) && ((huif.wsel == huif.rsel1) || huif.wsel == huif.rsel2))begin
            huif.stall = 1;
        end
    end
    
endmodule