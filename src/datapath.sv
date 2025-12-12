/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
`include "Control_unit_def.vh"
`include "alu_def.vh"
`include "register_file_if.vh"
`include "fetch_datapath_if.vh"
`include "decode_datapath_if.vh"
`include "execute_datapath_if.vh"
`include "writeback_datapath_if.vh"

`include "pipeline_register_de_if.vh"
`include "pipeline_register_em_if.vh"
`include "pipeline_register_mw_if.vh"
`include "pipeline_register_fd_if.vh"

`include "Forward_unit_def.vh"
`include "hazard_unit_if.vh"

`include "caches_if.vh"
`include "cache_control_if.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;
  logic [4:0] n_rsel1, n_rsel2;
  word_t next_memaddr, final_memaddr, imm_memaddr, next_pc;
  logic [2:0] final_mux;
  word_t wdat, immediate, out_port;
  logic Branch, MemtoReg, Mem_Read, Mem_Write, ALU_src, Reg_write, funct3_enable;
  logic temp_halt, jalr, pc_cntrl;
  word_t u_type, rdat1, rdat2;
  logic u_active;
  logic [31:0] n2_out_port, n4_next_memaddr, n2_utype, n_dmemload;
  logic [2:0] n3_final_mux;
  logic n3_Reg_write;
  logic [31:0] n1_next_memaddr, n1_imemaddr, n1_imemload;
  logic [31:0] n1_out_port, n3_next_memaddr, n2_rdat2, n1_utype;
  logic [2:0] n2_final_mux;
  logic n2_Mem_Read, n2_Mem_Write, n2_Reg_write;
  logic [31:0] n2_next_memaddr, n2_imemaddr, n1_rdat1, n1_imm, n1_rdat2, utype_execute;
  logic [2:0] n1_final_mux, n1_branch_select, n1_funct3, branch_select;
  logic [6:0] n1_opcode, n1_funct7;
  logic n1_branch, n1_jump, n1_Mem_Read, n1_Mem_Write, n1_Reg_write, n1_ALU_src;
  logic [4:0] rsel1, rsel2, wsel;
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic pc_mux, jump, shift_pipeline;
  logic n1_halt, n2_halt, n3_halt;
  logic [4:0] n1_wsel, n2_wsel, n3_wsel;
  logic [1:0] forward1, forward2;

  // Fetch section of pipeline connected below 
  fetch_datapath_if  fif();
  fetch_datapath #(PC_INIT) c9(.CLK(CLK), .nRST(nRST), .fif(fif));

  always_comb begin 
    fif.pc_cntrl = emif.n_pc_cntrl;
    fif.ihit = shift_pipeline;
    fif.final_memaddr = emif.n_final_memaddr;
    next_memaddr = fif.next_memaddr;
    dpif.imemaddr = fif.imemaddr;
    fif.halt = dpif.halt;
    fif.halt_mem = n2_halt;
    fif.stall = huif.stall;
  end

  // Decode section of pipeline connected below 
  decode_datapath_if dif();
  decode_datapath c10(.CLK(CLK), .nRST(nRST), .dif(dif));

  always_comb begin
    dif.imemload = n1_imemload;
    dif.wdat = wdat;
    dif.wsel = n3_wsel;
    wsel = dif.out_wsel;
    Branch = dif.Branch;
    jump = dif.jump;
    temp_halt = dif.halt;
    Reg_write = dif.Reg_write;
    Mem_Read = dif.Mem_Read;
    Mem_Write = dif.Mem_Write;
    rdat1 = dif.rdat1;
    rdat2 = dif.rdat2;
    
    final_mux = dif.final_mux;
    branch_select = dif.branch_select;
    opcode = dif.opcode;
    funct3 = dif.funct3;
    funct7 = dif.funct7;
    u_type = dif.u_type;
    immediate = dif.immediate;
    dif.WEN = n3_Reg_write;
    dif.imemaddr = n1_imemaddr;
    u_active = dif.u_active;
    rsel1 = dif.rsel1;
    rsel2 = dif.rsel2;
  end
  
  // Execution section of pipeline connected below 
  // Logic inside comb block used for forward signals
  execute_datapath_if eif();
  execute_datapath c11(.eif(eif));
  word_t temp_dat2, temp_n1_rdat2;
  always_comb begin
    eif.immediate = n1_imm;
    eif.imemaddr = n2_imemaddr;
    eif.next_memaddr = n2_next_memaddr;
    eif.funct3 = n1_funct3;
    eif.branch_select = n1_branch_select;
    eif.opcode = n1_opcode;
    eif.funct7 = n1_funct7;
    eif.branch = n1_branch;
    eif.jump = n1_jump;
    eif.ihit = shift_pipeline;
    out_port = eif.out_port;
    final_memaddr = eif.final_memaddr;
    pc_cntrl = eif.pc_cntrl;
    n1_rdat2 = deif.n1_rdat2;
    temp_n1_rdat2 = deif.n1_rdat2;
    eif.rdat1 = n1_rdat1;
    temp_dat2 = temp_n1_rdat2;
    // MUX deciding rdat1
    if (forward1 == 2'b01) begin
      eif.rdat1 = wdat;
    end
    else if (forward1 == 2'b10 && (n2_final_mux[2] == 1'b1)) begin
      eif.rdat1 = n1_utype;
    end
    else if(forward1 == 2'b10) begin
      eif.rdat1 = n1_out_port;
    end
    // MUX deciding rdat2
    if (forward2 == 2'b01) begin
      temp_dat2 = wdat;
      n1_rdat2 = wdat;
    end
    else if (forward2 == 2'b10 && (n2_final_mux[2] == 1'b1)) begin
      temp_dat2 = n1_utype;
    end
    else if (forward2 == 2'b10) begin
      temp_dat2 = n1_out_port;
      n1_rdat2 = n1_out_port;
    end
  end
  //Immediate logic - deciding who to put into ALU port B
  always_comb begin // mux choosing dat2 
        eif.dat2 = temp_dat2;
        if (deif.n1_ALU_src) begin //ALU_Src and immediate should come from de register
            eif.dat2 = n1_imm;
        end
    end
  // Memory controller & dcache controller
  assign dpif.dmemstore = n2_rdat2;
  assign dpif.dmemaddr = n1_out_port;
  assign dpif.imemREN = 1;
  assign dpif.datomic = emif.n2_atomic;
  // New Logic covering issue with cache implementation that will allow us to move on when memory is being used 
  always_comb begin
    if (dpif.dmemREN || dpif.dmemWEN) begin
      if (dpif.ihit && dpif.dhit) begin
        shift_pipeline = 1;
      end
      else begin
        shift_pipeline = 0;
      end
    end
    else begin
      shift_pipeline = dpif.ihit;
    end
  end

  word_t temp_dmemload;
  always_ff@(posedge CLK, negedge nRST) begin
    if (~nRST) begin
      temp_dmemload <= '0;
    end
    else if (dpif.dhit) begin
      temp_dmemload <= dpif.dmemload;
    end
    else begin
      temp_dmemload <= temp_dmemload;
    end
  end


// Writeback section
  writeback_datapath_if wif();
  writeback_datapath c12(.CLK(CLK), .nRST(nRST), .wif(wif));

  always_comb begin
    wif.final_mux = n3_final_mux;
    wif.dmemload = n_dmemload;
    wif.out_port = n2_out_port;
    wif.next_memaddr = n4_next_memaddr;
    wif.u_type = n2_utype;
    wif.temp_halt = n3_halt;
    wdat = wif.wdat;
    dpif.halt = wif.halt;
  end


  // Forwarding Unit
  Forward_unit_def fu();
  Forward_unit c21(.fu(fu));
  
  always_comb begin
    fu.wsel_writeback = n3_wsel; //error: should take wsel from write back, not wdat
    fu.wsel_memory = n2_wsel;
    fu.Reg_write_writeback = n3_Reg_write;
    fu.Reg_write_memory = n2_Reg_write;
    fu.rsel1 = n_rsel1;
    fu.rsel2 = n_rsel2;
    forward1 = fu.forward1;
    forward2 = fu.forward2;
  end

  // Hazard Unit
  hazard_unit_if huif();
  hazard_unit hu1(.huif(huif));
  always_comb begin
    huif.pc_mux = emif.n_pc_mux;
    huif.wsel = n1_wsel;
    huif.MemRead = n1_Mem_Read;
    huif.rsel1 = dif.rsel1;
    huif.rsel2 = dif.rsel2;
    huif.halt = n2_halt;
    huif.datomic = deif.n1_atomic;
  end


  // Latch for fetch to decode sections
  pipeline_register_fd_if fdif();
  pipeline_register_fd r1(.CLK(CLK), .nRST(nRST), .fdif(fdif));
  always_comb begin  
    fdif.next_memaddr = next_memaddr;
    fdif.imemaddr = dpif.imemaddr;
    fdif.imemload = dpif.imemload;
    fdif.ihit = shift_pipeline;
    n1_next_memaddr = fdif.n1_next_memaddr;
    n1_imemaddr = fdif.n1_imemaddr;
    n1_imemload = fdif.n1_imemload;
    fdif.flush = huif.flush;
    fdif.stall = huif.stall;
  end

  word_t n2_imemload, n3_imemload, n4_imemload;

  // Latch for decode to execute sections
  pipeline_register_de_if deif();
  pipeline_register_de r2(.CLK(CLK), .nRST(nRST), .deif(deif));
  always_comb begin
    deif.imemload = n1_imemload; // delete when done
    deif.rsel1 = rsel1;
    deif.rsel2 = rsel2;  
    deif.halt = temp_halt;
    deif.wsel = wsel;
    deif.n1_next_memaddr = n1_next_memaddr;
    deif.n1_imemaddr = n1_imemaddr;
    deif.rdat1 = rdat1;
    deif.ALU_src = dif.ALU_src;
    deif.utype = u_type;
    deif.imm = immediate;
    deif.rdat2 = rdat2;
    deif.final_mux = final_mux;
    deif.branch_select = branch_select;
    deif.funct3 = funct3;
    deif.opcode = opcode;
    deif.funct7 = funct7;
    deif.ihit = shift_pipeline;
    deif.branch = Branch;
    deif.jump = jump;
    deif.Mem_Read = Mem_Read;
    deif.Mem_Write = Mem_Write;
    deif.Reg_write = Reg_write;
    deif.atomic = dif.atomic;
    utype_execute = deif.utype_execute;
    n2_next_memaddr = deif.n2_next_memaddr;
    n2_imemaddr = deif.n2_imemaddr;
    n1_rdat1 = deif.n1_rdat1;
    n2_imemload = deif.n_imemload; // delte when done
    n1_imm = deif.n1_imm;
    n1_final_mux = deif.n1_final_mux;
    n1_branch_select = deif.n1_branch_select;
    n1_funct3 = deif.n1_funct3;
    n1_opcode = deif.n1_opcode;
    n1_funct7 = deif.n1_funct7;
    n1_Reg_write = deif.n1_Reg_write;
    n1_halt = deif.n_halt;
    n1_wsel = deif.n_wsel;
    n1_Mem_Read = deif.n1_Mem_Read;
    n1_Mem_Write = deif.n1_Mem_Write;
    n1_branch = deif.n1_branch;
    n1_jump = deif.n1_jump;
    n_rsel1 = deif.n_rsel1;
    n_rsel2 = deif.n_rsel2;
    deif.flush = huif.flush;
    deif.stall = huif.stall;
  end

  // Latch for execute to memory sections
  pipeline_register_em_if emif();
  pipeline_register_em r3(.CLK(CLK), .nRST(nRST), .emif(emif));
  always_comb begin 
    //emif.mw_pc_mux = mwif.n_pc_mux; //? was commented out should it be?
    emif.pc_cntrl = pc_cntrl;
    emif.pc_mux = eif.pc_mux;
    emif.final_memaddr = eif.final_memaddr;
    emif.flush = huif.flush;
    emif.imemload = n2_imemload; // delte when done
    emif.halt = n1_halt;
    emif.out_port = out_port;
    emif.next_memaddr = n2_next_memaddr;
    emif.wsel = n1_wsel;
    emif.rdat2 = n1_rdat2;
    emif.utype = utype_execute;
    emif.final_mux = n1_final_mux;
    emif.ihit = dpif.ihit;
    emif.dhit = dpif.dhit;
    emif.Mem_Read = n1_Mem_Read;
    emif.Mem_Write = n1_Mem_Write;
    emif.Reg_write = n1_Reg_write;
    emif.n1_atomic = deif.n1_atomic;
    n1_out_port = emif.n_out_port;
    n3_next_memaddr = emif.n_next_memaddr;
    n2_rdat2 = emif.n_rdat2;
    n1_utype = emif.n_utype;
    n2_final_mux = emif.n_final_mux;
    n2_wsel = emif.n_wsel;
    dpif.dmemREN = emif.dmemREN;
    dpif.dmemWEN = emif.dmemWEN;
    n2_Reg_write = emif.n_Reg_write;
    n2_halt = emif.n_halt;
    n3_imemload = emif.n_imemload; // delte when done

  end

  // Latch for memory to writeback sections
  pipeline_register_mw_if mwif();
  pipeline_register_mw r4(.CLK(CLK), .nRST(nRST), .mwif(mwif));
  always_comb begin
    mwif.pc_mux = emif.n_pc_mux;
    mwif.imemload = n3_imemload; // delte when done
    mwif.halt = n2_halt;
    mwif.dhit = dpif.dhit;
    mwif.ihit = shift_pipeline;
    mwif.out_port = n1_out_port;
    mwif.next_memaddr = n3_next_memaddr;
    mwif.utype = n1_utype;
    // mwif.dmemload = temp_dmemload;
    mwif.dmemload = dpif.ihit && dpif.dhit ? dpif.dmemload : temp_dmemload;
    mwif.final_mux = n2_final_mux;
    mwif.wsel = n2_wsel;
    mwif.Reg_write = n2_Reg_write;
    n2_out_port = mwif.n_out_port;
    n3_wsel = mwif.n_wsel;
    n4_next_memaddr = mwif.n_next_memaddr;
    n2_utype = mwif.n_utype;
    n3_final_mux=  mwif.n_final_mux;
    n3_Reg_write = mwif.n_Reg_write;
    n_dmemload = mwif.n_dmemload;
    n3_halt = mwif.n_halt;
    n3_wsel = mwif.n_wsel;
    n4_imemload = mwif.n_imemload;
  end

endmodule