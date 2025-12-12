`include "cpu_types_pkg.vh"
`include "alu_def.vh"
import cpu_types_pkg::*;

module alu(
    alu_def.alu_ports alu_mod
);

always_comb begin
    alu_mod.overflow = 0;
    alu_mod.negative = 0;
    case(alu_mod.aluop)
        ALU_SLL:
            alu_mod.out_port = alu_mod.porta << alu_mod.portb[4:0];
        ALU_SRL:
            alu_mod.out_port = alu_mod.porta >> alu_mod.portb[4:0];
        ALU_SRA:
            alu_mod.out_port = $signed(alu_mod.porta) >>> alu_mod.portb[4:0];
        ALU_ADD: begin
            alu_mod.out_port = alu_mod.porta + alu_mod.portb;
            alu_mod.overflow = ((alu_mod.porta[31] == alu_mod.portb[31]) & (alu_mod.out_port[31] != alu_mod.porta[31])) ? 1'b1 : 1'b0;
            alu_mod.negative = (alu_mod.out_port[31]);
        end
        ALU_SUB: begin
            alu_mod.out_port = alu_mod.porta - alu_mod.portb;
            alu_mod.overflow = ((alu_mod.porta[31] != alu_mod.portb[31]) & (alu_mod.out_port[31] != alu_mod.porta[31])) ? 1'b1 : 1'b0;
            alu_mod.negative = (alu_mod.out_port[31]);
        end
        ALU_AND:
            alu_mod.out_port = alu_mod.porta & alu_mod.portb;
        ALU_OR:
            alu_mod.out_port = alu_mod.porta | alu_mod.portb;
        ALU_XOR:
            alu_mod.out_port = alu_mod.porta ^ alu_mod.portb;
        ALU_SLT:
            alu_mod.out_port = ($signed(alu_mod.porta) < $signed(alu_mod.portb));
        ALU_SLTU:
            alu_mod.out_port = (alu_mod.porta < alu_mod.portb);
        default: alu_mod.out_port = 32'd0;
    endcase
end


always_comb begin
    alu_mod.zero = 0;
    if (alu_mod.out_port == '0) begin
        alu_mod.zero = 1;
    end
end

endmodule