# Multicore-Processor-Design
Dual-Core RISC-V Implementation in Verilog

Design created for ECE 43700 (Purdue University)

This repository contains a dual-core RISC-V processor implemented in synthesizable Verilog. It is intended as a teaching / lab project for ECE 43700 and demonstrates a working multicore datapath, control, memory interface, and the verification scaffolding needed to simulate, test, and synthesize the design.



Some key elements implemented:

1, Single Cycle Datapath - Decode RISCV instructions and perform them accordingly, some major structure include ALU, PC, Control Unit, Request Unit, Register File

2, Pipelined Datapath - 5 stages pipeline design to increase throughput of the original Single Cycle Design

3, Caches - Implemented I-Cache and D-Cache to decrease long memory access time

4, Memory Control(Bus Controller) - For dual core design, implemented MSI protocol with the addition of memory control unit, also made changes in Dcache and datapath

Assembly files created mainly for testing design functionality, for dual core, wrote palgorithm.asm with locks to verify LR-SC implementation in dual core design


