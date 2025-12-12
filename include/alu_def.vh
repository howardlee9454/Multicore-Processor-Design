`ifndef ALU_DEF_VH
`define ALU_DEF_VH

`include "cpu_types_pkg.vh"

interface alu_def;
    // import types
  import cpu_types_pkg::*;
  
  logic zero, overflow, negative;
  aluop_t aluop;
  word_t porta, portb, out_port;

  modport alu_ports(
    input porta, portb, aluop,
    output negative, out_port, overflow, zero
  );   

  modport alu_tb(
    input negative, out_port, overflow, zero,
    output porta, portb, aluop
  );

  endinterface

  `endif