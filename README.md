# Multicore-Processor-Design
Dual-Core RISC-V Implementation in Verilog

Design created for ECE 43700 (Purdue University)

This repository contains a dual-core RISC-V processor implemented in synthesizable Verilog. It is intended as a teaching / lab project for ECE 43700 and demonstrates a working multicore datapath, control, memory interface, and the verification scaffolding needed to simulate, test, and synthesize the design.

Single Cycle Structure:
System
----------CPU1-----
|                  |
|                  |------datapath------|------register file
                                        |------control unit
                                        |------request unit
                                        |------alu
                                        |------pc
|                  |------caches------
|                  |------memory control------
|                  |------datapath
|
|
----------RAM
