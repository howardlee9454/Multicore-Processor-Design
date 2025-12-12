`include "cpu_types_pkg.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module register_file(

    input logic CLK, nRST,
    register_file_if.rf rfif
);

word_t [31:0] regs, next_regs;
int i;

always_ff @(negedge CLK, negedge nRST) begin
if (nRST == 1'b0) begin
        regs <= '0;
end
else begin
        regs <= next_regs;
end
end


// Logic for write enable
always_comb begin
    next_regs = regs;
    if (rfif.WEN && (rfif.wsel != '0)) begin
        next_regs[rfif.wsel] = rfif.wdat;
    end
end

// Logic for read select (outputing data)
always_comb begin
    rfif.rdat1 = regs[rfif.rsel1];
    rfif.rdat2 = regs[rfif.rsel2];
end

endmodule