// data path interface
`include "datapath_cache_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
`include "Request_unit_def.vh"


module Request_unit(
    input logic CLK, nRST, ihit, dhit, Mem_Read, Mem_Write,
    output logic dmemREN, dmemWEN, imemREN
);

    assign imemREN = 1;
    logic next_dmemWEN, next_dmemREN;

    always_ff @(posedge CLK, negedge nRST) begin
        if (nRST == 1'b0) begin
            dmemWEN <= 0;
            dmemREN <= 0;
        end
        else begin
            dmemWEN <= next_dmemWEN;
            dmemREN <= next_dmemREN;
        end
    end

    always_comb begin
        next_dmemREN = dmemREN;
        next_dmemWEN = dmemWEN;
        if (ihit && Mem_Read) begin
            next_dmemREN = 1;
        end
        else if(ihit && Mem_Write) begin 
            next_dmemWEN = 1;
        end
        else if(dhit) begin // ask about this shit 
            next_dmemREN = 0;
            next_dmemWEN = 0;
        end
    end

endmodule