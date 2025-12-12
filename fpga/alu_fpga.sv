`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module alu_fpga (
  input logic CLK_100MHZ,
  input logic [3:0] BTN,
  input logic [15:0] SW,
  output logic [15:0] LED,
  output logic [6:0] D0_SEG, D1_SEG,
  output logic [3:0] D0_AN, D1_AN
);

  alu_def alu_mod();

  alu FPGA(alu_mod);
  
  assign alu_mod.aluop = BTN[3:0];
  assign alu_mod.zero = LED[0];
  assign alu_mod.negative = LED[1];
  assign alu_mod.overflow = LED[2];

  logic [14:0] regB, next_regB;
  always_ff @(posedge CLK_100MHZ) begin
    if (SW[15]) begin
      regB <= next_regB;
    end
    else begin
      regB <= regB;
    end
  end
  assign next_regB = {SW[14], SW[13:0]};

  assign alu_mod.portb = {17'd0, regB};
  assign alu_mod.porta = {17'd0, next_regB};
  ////////////////////////////////////////////////////////////////////////////////////////////////
  logic [1:0] sel;
  logic [3:0] current_digit0, current_digit1;
  logic [6:0] ssdec0, ssdec1;

  word_t display_digits;
  ssdec DEC0(current_digit0, ssdec0);
  ssdec DEC1(current_digit1, ssdec1);

  assign display_digits = alu_mod.out_port;

  // counter for time-muxing ssdec
  logic CLK_DISP;
  clock_div #(.DIV(100000)) CLKDIV(CLK_100MHZ, CLK_DISP);
  always_ff @(posedge CLK_DISP) begin
    sel <= sel + 1;
  end

  // ssdec current digit and anode controller
  always_comb begin
    D0_AN = 4'b1111;
    D1_AN = 4'b1111;
    current_digit0 = display_digits[31 - sel*4 -: 4];
    current_digit1 = display_digits[15 - sel*4 -: 4];
    D0_AN[sel] = 1'b0;
    D1_AN[sel] = 1'b0;
  end
  
  // remaining assigns
  assign D0_SEG = ssdec0;
  assign D1_SEG = ssdec1;
  
endmodule

module ssdec (
  input logic [3:0] val,
  output logic [6:0] ssdec
);
  always_comb begin
    ssdec = 7'b1111111;
    unique casez (val)
      'h0: ssdec = 7'b1000000;
      'h1: ssdec = 7'b1111001;
      'h2: ssdec = 7'b0100100;
      'h3: ssdec = 7'b0110000;
      'h4: ssdec = 7'b0011001;
      'h5: ssdec = 7'b0010010;
      'h6: ssdec = 7'b0000010;
      'h7: ssdec = 7'b1111000;
      'h8: ssdec = 7'b0000000;
      'h9: ssdec = 7'b0010000;
      'ha: ssdec = 7'b0001000;
      'hb: ssdec = 7'b0000011;
      'hc: ssdec = 7'b0100111;
      'hd: ssdec = 7'b0100001;
      'he: ssdec = 7'b0000110;
      'hf: ssdec = 7'b0001110;
    endcase
  end
endmodule

module clock_div #(parameter DIV = 10) (
  input logic clk,
  output logic outclk
);
  logic [20:0] count;
  always_ff @(posedge clk) begin
    count <= count + 1;
    if (count == DIV/2 - 1) begin
      outclk = ~outclk;
      count <= 0;
    end
  end
endmodule