`include "cpu_types_pkg.vh"

`include "pipeline_register_de_if.vh"
module pipeline_register_de (
  input logic CLK, nRST,
  pipeline_register_de_if.rf deif
);

    import cpu_types_pkg::*;
    always_ff @(posedge CLK, negedge nRST ) begin : pipeline_fd
        if(~nRST)begin
            deif.n_imemload <= '0; // delete when done 
            deif.n2_next_memaddr <= '0;
            deif.n2_imemaddr <= '0;
            deif.n1_rdat1 <= '0;
            deif.n1_rdat2 <= '0;
            deif.n1_imm <= '0;
            deif.n1_ALU_src <= '0;
            deif.utype_execute <= '0;
            deif.n1_final_mux <= '0;
            deif.n1_branch_select <= '0;
            deif.n1_funct3 <= '0;
            deif.n1_opcode <= '0;
            deif.n1_funct7 <= '0;
            deif.n1_branch <= 0;
            deif.n1_jump <= 0;
            deif.n1_Mem_Read <= 0;
            deif.n1_Mem_Write <= 0;
            deif.n1_Reg_write <= 0;
            deif.n_rsel1 <= '0;
            deif.n_rsel2 <= '0;
            deif.n_halt <= 0;
            deif.n_wsel <= '0;
            deif.n1_atomic <= 0;
        end
        else if(deif.ihit && deif.flush)begin
            deif.n_imemload <= '0; // delete when done 
            deif.n2_next_memaddr <= '0;
            deif.n2_imemaddr <= '0;
            deif.n1_rdat1 <= '0;
            deif.n1_rdat2 <= '0;
            deif.n1_imm <= '0;
            deif.n1_ALU_src <= '0;
            deif.utype_execute <= '0;
            deif.n1_final_mux <= '0;
            deif.n1_branch_select <= '0;
            deif.n1_funct3 <= '0;
            deif.n1_opcode <= '0;
            deif.n1_funct7 <= '0;
            deif.n1_branch <= 0;
            deif.n1_jump <= 0;
            deif.n1_Mem_Read <= 0;
            deif.n1_Mem_Write <= 0;
            deif.n1_Reg_write <= 0;
            deif.n_rsel1 <= '0;
            deif.n_rsel2 <= '0;
            deif.n_halt <= 0;
            deif.n_wsel <= '0;
            deif.n1_atomic <= 0;
        end 
        else if (deif.ihit && deif.stall) begin
            deif.n_imemload <= '0; // delete when done 
            deif.n2_next_memaddr <= '0;
            deif.n2_imemaddr <= '0;
            deif.n1_rdat1 <= '0;
            deif.n1_rdat2 <= '0;
            deif.n1_imm <= '0;
            deif.n1_ALU_src <= '0;
            deif.utype_execute <= '0;
            deif.n1_final_mux <= '0;
            deif.n1_branch_select <= '0;
            deif.n1_funct3 <= '0;
            deif.n1_opcode <= '0;
            deif.n1_funct7 <= '0;
            deif.n1_branch <= 0;
            deif.n1_jump <= 0;
            deif.n1_Mem_Read <= 0;
            deif.n1_Mem_Write <= 0;
            deif.n1_Reg_write <= 0;
            deif.n_rsel1 <= '0;
            deif.n_rsel2 <= '0;
            deif.n_halt <= 0;
            deif.n_wsel <= '0;
            deif.n1_atomic <= 0;
        end 
        else if (deif.ihit) begin
            deif.n2_next_memaddr <= deif.n1_next_memaddr;
            deif.n2_imemaddr <= deif.n1_imemaddr;
            deif.n1_rdat1 <= deif.rdat1;
            deif.n1_rdat2 <= deif.rdat2;
            deif.n1_imm <= deif.imm;
            deif.n1_final_mux <= deif.final_mux;
            deif.n1_ALU_src <= deif.ALU_src;
            deif.utype_execute <= deif.utype;
            deif.n1_branch_select <= deif.branch_select;
            deif.n1_funct3 <= deif.funct3;
            deif.n1_opcode <= deif.opcode;
            deif.n1_funct7 <= deif.funct7;
            deif.n1_branch <= deif.branch;
            deif.n1_jump <= deif.jump;
            deif.n1_Mem_Read <= deif.Mem_Read;
            deif.n1_Mem_Write <= deif.Mem_Write;
            deif.n1_Reg_write <= deif.Reg_write;
            deif.n_rsel1 <= deif.rsel1;
            deif.n_rsel2 <= deif.rsel2;
            deif.n_halt <= deif.halt;
            deif.n_wsel <= deif.wsel;
            deif.n_imemload <= deif.imemload; // delete when done 
            deif.n1_atomic <= deif.atomic;
        end
    end

endmodule