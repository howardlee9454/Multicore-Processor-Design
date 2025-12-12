`include "cpu_types_pkg.vh"
`include "alu_def.vh"
`include "execute_datapath_if.vh"

module execute_datapath(
    execute_datapath_if.execute eif
    // input logic [31:0] rdat1, dat2, immediate, imemaddr,
    // input logic [2:0] funct3, branch_select, 
    // input logic [6:0] opcode, funct7,
    // input logic branch, jump, ihit,
    // output logic [31:0] out_port, final_memaddr,
    // output logic pc_cntrl,
);
    import cpu_types_pkg::*;
    logic zero, branch_out, jalr;
    aluop_t aluop;
    word_t imm_memaddr;

    always_comb begin // alu controller -----------------------------------------------------------------
        jalr = 0;
        aluop = ALU_ADD;
        if (eif.opcode == 7'b0110011) begin // r type instruction
            if (eif.funct3 == 3'b000) begin
                if (eif.funct7 == 7'h00) begin
                    aluop = ALU_ADD;
                end
                else if(eif.funct7 == 7'h20) begin
                    aluop = ALU_SUB;
                end
            end
            else if (eif.funct3 == 3'b001) begin
                aluop = ALU_SLL;
            end
            else if(eif.funct3 == 3'b010) begin
                aluop = ALU_SLT;
            end
            else if(eif.funct3 == 3'b011) begin
                aluop = ALU_SLTU;
            end
            else if(eif.funct3 == 3'b100) begin
                aluop = ALU_XOR;
            end
            else if(eif.funct3 == 3'b101) begin
            if (eif.funct7 == 7'h00) begin
                aluop = ALU_SRL;
            end
            else if (eif.funct7 == 7'h20) begin
                aluop = ALU_SRA;
            end
            end
            else if(eif.funct3 == 3'b110) begin
                aluop = ALU_OR;
            end
            else if(eif.funct3 == 3'b111) begin
                aluop = ALU_AND;
            end
        end
        if(eif.opcode == 7'b0000011) begin // i type instruction (load word only)
            if(eif.funct3 == 3'b010) begin
                aluop = ALU_ADD;
            end
        end
        else if(eif.opcode == 7'b0010011) begin // Other i type instructions
            if (eif.funct3 == 3'b000) begin
                aluop = ALU_ADD;
            end
        else if(eif.funct3 == 3'b001) begin
            aluop = ALU_SLL;
        end
        else if(eif.funct3 == 3'b010) begin
            aluop = ALU_SLT;
        end
        else if(eif.funct3 == 3'b011) begin
            aluop = ALU_SLTU;
        end
        else if(eif.funct3 == 3'b100) begin
            aluop = ALU_XOR;
        end
        else if(eif.funct3 == 3'b101) begin
            if (eif.funct7 == 7'h00) begin
                aluop = ALU_SRL;
            end
            else if(eif.funct7 == 7'h20) begin
                aluop = ALU_SRA;
            end
        end
        else if(eif.funct3 == 3'b110) begin
            aluop = ALU_OR;
        end
        else if(eif.funct3 == 3'b111) begin
            aluop = ALU_AND;
        end
        end
        else if(eif.opcode == 7'b0100011) begin // sw instruction
            aluop = ALU_ADD;
        end
        else if(eif.opcode == 7'b1100011) begin // sb instruction 
        if (eif.funct3 == 3'b00) begin
            aluop = ALU_SUB;
        end
        else if(eif.funct3 == 3'b001) begin
            aluop = ALU_SUB;
        end
        else if(eif.funct3 == 3'b100 || eif.funct3 ==3'b101) begin
            aluop = ALU_SLT;
        end
        else begin
            aluop = ALU_SLTU;
        end
        end
        else if(eif.opcode == 7'b1100111) begin // jal instruction
            aluop = ALU_ADD; // this value does not matter
            jalr = 1;
        end
        // else if(eif.opcode == 7'b0101111) begin
            
        // end
    end

    alu_def alu_mod();
    alu c1(.alu_mod(alu_mod));

    always_comb begin
        alu_mod.aluop = aluop;
        alu_mod.porta = eif.rdat1;
        alu_mod.portb = eif.dat2;
        eif.out_port = alu_mod.out_port;
        zero = alu_mod.zero;
    end    

    always_comb begin // mux deciding branch output -----------------------------------------------------------------
        branch_out = 0;
        if (eif.branch_select == 3'b000) begin
            if (eif.branch && zero) begin
                branch_out = 1;
            end
        end
        if (eif.branch_select == 3'b001) begin
            if (eif.branch && !(zero)) begin
                branch_out = 1;
            end
        end
        if (eif.branch_select == 3'b100) begin
            if (eif.branch && (eif.out_port == 32'd1)) begin
                branch_out = 1;
            end
        end
        if (eif.branch_select == 3'b101) begin
            if (eif.branch && (eif.out_port == 32'd0)) begin
                branch_out = 1;
            end
        end
        if (eif.branch_select == 3'b110) begin
            if (eif.branch && (eif.out_port == 32'd1)) begin
                branch_out = 1;
            end
        end
        if (eif.branch_select == 3'b111) begin
            if (eif.branch && (eif.out_port == 32'd0)) begin
                branch_out = 1;
            end
        end
    end

    // Deciding final PC address returning to PC -----------------------------------------------------------------
    assign eif.pc_mux = (branch_out || eif.jump);

    // Add block adding together immediate and the current PC value (imemaddr) -----------------------------------------------------------------
    assign imm_memaddr = eif.imemaddr + eif.immediate;

    always_comb begin // mux controlling final pc value -----------------------------------------------------------------
    eif.final_memaddr = eif.next_memaddr;
    eif.pc_cntrl = 0;
    if ((jalr == 1'b1) && eif.ihit) begin
      eif.final_memaddr = eif.out_port;
      eif.pc_cntrl = 1;
    end
    else if ((eif.pc_mux == 1'b1) && eif.ihit) begin
      eif.final_memaddr = imm_memaddr;
      eif.pc_cntrl = 1;
    end
  end

endmodule