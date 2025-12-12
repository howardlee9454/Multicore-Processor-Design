/*
  Eric Villasenor
  evillase@gmail.com
  Jimmy Jin
  mingze.jin01@gmail.com

  register file fpga wrapper
*/

// interface
`include "register_file_if.vh"

module register_file_fpga (
  input logic CLK_100MHZ,
  input logic [3:0] BTN,
  input logic [15:0] SW,
  output logic [15:0] LED
);

  // interface
  register_file_if rfif();
  // rf
  register_file RF(CLK_100MHZ, ~BTN[2], rfif);

  assign rfif.wsel = SW[3:0];
  assign rfif.rsel1 = SW[7:4];
  assign rfif.rsel2 = SW[11:8];
  assign rfif.wdat = {28'b0,SW[15:12]};
  
  assign rfif.WEN = BTN[3];
  assign LED[8:5] = rfif.rdat1[3:0];
  assign LED[13:10] = rfif.rdat2[3:0];

endmodule
