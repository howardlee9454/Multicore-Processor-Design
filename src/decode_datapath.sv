`include "cpu_types_pkg.vh"
`include "Control_unit_def.vh"
`include "register_file_if.vh"
`include "decode_datapath_if.vh"

module decode_datapath(

    input logic CLK, nRST, 
    decode_datapath_if.decode dif
    // WEN,
    // input logic [31:0] imemload, wdat
    // input logic [4:0] wsel,
    // output logic Branch, halt, jump, Mem_Read, Mem_Write, Reg_write, u_active,
    // output logic [2:0] branch_select, funct3, final_mux,
    // output logic [31:0] rdat1, rdat2, dat2, u_type, immediate,
    // output logic [6:0] opcode, funct7
);
    import cpu_types_pkg::*;

    logic [4:0] wsel, rsel1, rsel2;
    logic [2:0] funct3_enable;
    word_t immediate;
    logic MemtoReg;
    

    always_comb begin // instruction decoder (decode stage)
        dif.opcode = dif.imemload[6:0];
        dif.funct3 = dif.imemload[14:12];
        dif.out_wsel = dif.imemload[11:7];
        rsel1 = dif.imemload[19:15];
        rsel2 = dif.imemload[24:20];
        dif.funct7 = dif.imemload[31:25];
    end

    assign dif.rsel1 = rsel1;
    assign dif.rsel2 = rsel2;

    always_comb begin // Immediate generator and extender (decode section)
        dif.immediate = '0;
        dif.u_active = 0;
        dif.u_type = '0;
        // if (dif.opcode == 7'b0110011) begin // r type instruction
        //     dif.immediate = '0;
        // end
        if(dif.opcode == 7'b0000011 || dif.opcode == 7'b0010011 || dif.opcode == 7'b1100111) begin // i type instruction
            dif.immediate = {{20{dif.imemload[31]}}, dif.imemload[31:20]};
        end
        else if(dif.opcode == 7'b0100011) begin // sw instruction
            dif.immediate = {{20{dif.imemload[31]}}, dif.imemload[31:25], dif.imemload[11:7]};
        end
        else if(dif.opcode == 7'b1100011) begin // sb instruction 
            dif.immediate = {{20{dif.imemload[31]}}, dif.imemload[7], dif.imemload[30:25], dif.imemload[11:8], 1'b0};
        end
        else if(dif.opcode == 7'b1101111) begin // jal instruction
            dif.immediate = {{12{dif.imemload[31]}}, dif.imemload[19:12], dif.imemload[20], dif.imemload[30:21], 1'b0};
        end
        else if(dif.opcode == 7'b0010111) begin
            dif.immediate = {dif.imemload[31:12], 12'd0};
            dif.u_type = dif.immediate + dif.imemaddr;
            dif.u_active = 1;
        end
        else if(dif.opcode == 7'b0110111) begin
            dif.immediate = {dif.imemload[31:12], 12'd0};
            dif.u_type = dif.immediate;
            dif.u_active = 1;
        end
    end


    register_file_if rfif();
    register_file c3(.CLK(CLK), .nRST(nRST), .rfif(rfif));
    // word_t rdat1, rdat2;
    always_comb begin
        rfif.WEN = dif.WEN;
        rfif.rsel1 = rsel1;
        rfif.rsel2 = rsel2;
        rfif.wsel = dif.wsel; // This needs to be passed in as wsel -> n3_wsel
        rfif.wdat = dif.wdat;// Update the write value to this when ready
        dif.rdat1 = rfif.rdat1;
        dif.rdat2 = rfif.rdat2;
    end


    Control_unit_def CU();
    Control_unit c2(.unit(CU));

    always_comb begin
        CU.opcode = dif.opcode;
        CU.funct5 = dif.imemload[31:27];
        dif.Branch = CU.Branch;
        dif.halt = CU.halt;
        MemtoReg = CU.MemtoReg;
        dif.Mem_Read = CU.Mem_Read;
        dif.Mem_Write = CU.Mem_Write;
        dif.ALU_src = CU.ALU_src;
        dif.Reg_write = CU.Reg_write;
        funct3_enable = CU.funct3_enable;
        dif.jump = CU.jump;
        dif.atomic = CU.atomic;
    end

    always_comb begin // funct3 unit for branching
        dif.branch_select = 3'b011; // setting to unused value
        if (funct3_enable) begin
            dif.branch_select = dif.funct3;
        end
    end

    // always_comb begin // mux choosing dat2 
    //     dif.dat2 = dif.rdat2;
    //     if (ALU_src) begin
    //         dif.dat2 = dif.immediate;
    //     end
    // end

    assign dif.final_mux = {dif.u_active, dif.jump, MemtoReg};

endmodule