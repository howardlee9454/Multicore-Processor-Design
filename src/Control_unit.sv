// data path interface
`include "datapath_cache_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
`include "Control_unit_def.vh"

typedef enum logic [1:0]
{  
    LOAD_RESERVE,
    SET_CONDITIONAL,
    NO_LOCK_USE
} lock_types;

module Control_unit (
  Control_unit_def.CU unit
);

    import cpu_types_pkg::*;

    // Functionality for determing if a lock command is used and which one
    lock_types lock_op;
    always_comb begin
        lock_op = NO_LOCK_USE;
        unit.atomic = 0;
        if (unit.opcode == 7'b0101111) begin
            if (unit.funct5 == 5'h02) begin
                lock_op = LOAD_RESERVE;
                unit.atomic = 1;
            end
            else if (unit.funct5 == 5'h03) begin
                lock_op = SET_CONDITIONAL;
                unit.atomic = 1;
            end
        end
    

         // funct3 enable
        unit.funct3_enable = 0;
        unit.Branch = 0;
        if (unit.opcode == 7'b1100011) begin
            unit.funct3_enable = 1;
            unit.Branch = 1;
        end
    
        unit.Reg_write = 0;
        if (unit.opcode == 7'b0110011 || unit.opcode == 7'b0000011 || unit.opcode == 7'b0010011 || unit.opcode == 7'b1100111
        || unit.opcode == 7'b0110111 || unit.opcode == 7'b1101111 || unit.opcode == 7'b0010111 || unit.opcode == 7'b0101111) begin
            unit.Reg_write = 1;
        end
   
        unit.ALU_src = 0;
        if (unit.opcode == 7'b0010011 || unit.opcode == 7'b0000011 || unit.opcode == 7'b0100011 || unit.opcode == 7'b0101111) begin
            unit.ALU_src = 1;
        end
   
        unit.Mem_Write = 0;
        if (unit.opcode == 7'b0100011 || lock_op == SET_CONDITIONAL) begin
            unit.Mem_Write = 1;
        end
    
        unit.Mem_Read = 0;
        if (unit.opcode == 7'b0000011 || lock_op == LOAD_RESERVE) begin
            unit.Mem_Read = 1;
        end
   
        unit.MemtoReg = 0;
        if (unit.opcode == 7'b0000011 || unit.opcode == 7'b0101111) begin
            unit.MemtoReg = 1;
        end

        unit.halt = 0; 
        if (unit.opcode == 7'b1111111) begin
            unit.halt = 1;
        end

     // jump opcode detection
        unit.jump = 0;
        if (unit.opcode == 7'b1100111 || unit.opcode == 7'b1101111) begin
            unit.jump = 1;
        end
    end

endmodule