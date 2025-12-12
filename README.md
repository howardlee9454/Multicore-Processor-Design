# Multicore-Processor-Design
Dual-Core RISC-V Implementation in Verilog

Design created for ECE 43700 (Purdue University)

This repository contains a dual-core RISC-V processor implemented in synthesizable Verilog. It is intended as a teaching / lab project for ECE 43700 and demonstrates a working multicore datapath, control, memory interface, and the verification scaffolding needed to simulate, test, and synthesize the design.

+---------------------------------------------------------------+
|                       System Top Level                        |
|                                                               |
|   +-------------------+       +-------------------+            |
|   |    CPU Core 0     |       |    CPU Core 1     |            |
|   |  (5-stage RV32I)  |       |  (5-stage RV32I)  |            |
|   +---------+---------+       +---------+---------+            |
|             |                           |                      |
|     +-------+----+               +------+-------+              |
|     |   L1 I/D   |               |   L1 I/D     |              |
|     |   Caches   |               |   Caches     |              |
|     +-------+----+               +------+-------+              |
|             |                           |                      |
|            +------------ Shared Interconnect ----------------+ |
|            |                 & Memory Arbiter                | |
|            +----------------------+---------------------------+ |
|                                   |                             |
|                    +--------------+---------------+             |
|                    |     Memory Controller         |            |
|                    +--------------+---------------+             |
|                                   |                             |
|                             +-----+-----+                       |
|                             |    RAM    |                       |
|                             +-----------+                       |
+-----------------------------------------------------------------+




