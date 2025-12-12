`include "cpu_types_pkg.vh"


module fetch_datapath(
    input logic CLK, nRST, 
    fetch_datapath_if.fetch fif
    
    // pc_cntrl, ihit,
    // input logic [31:0] final_memaddr,
    // output logic [31:0] next_memaddr, imemaddr
);
    parameter PC_INIT = 0;
    import cpu_types_pkg::*;
    // PC block setting the PC counter to the next value based on instructions.
    // fix final memaddr based on pc cntrl signal 

    word_t next_pc;
    assign next_pc = fif.pc_cntrl ? fif.final_memaddr : fif.next_memaddr;

    always_ff @(posedge CLK, negedge nRST) begin
        if (nRST == 1'b0) begin
            fif.imemaddr <= PC_INIT;
        end 
        else if (fif.halt_mem && fif.ihit) begin
            fif.imemaddr <= '0;
        end
        else if (fif.stall && fif.ihit) begin
            fif.imemaddr <= fif.imemaddr;
        end
        else if (fif.ihit) begin
            fif.imemaddr <= next_pc;
        end
    end

    // incrementing the value of PC by 4
    always_comb begin
        fif.next_memaddr = fif.imemaddr;
        if (fif.ihit && (fif.halt == 1'b0)) begin
            fif.next_memaddr = fif.imemaddr + 4;
        end
    end

endmodule