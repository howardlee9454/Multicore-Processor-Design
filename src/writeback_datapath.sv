`include "cpu_types_pkg.vh"

module writeback_datapath(
    input logic CLK, nRST,
    writeback_datapath_if.writeback wif

    // input logic [2:0] final_mux,
    // input logic [31:0] dmemload, out_port, next_memaddr, u_type,
    // input logic temp_halt,
    // output logic [31:0] wdat,
    // output logic halt
);
   

    always_ff @(posedge CLK, negedge nRST) begin
        if (nRST == 1'b0) begin
            wif.halt <= 0;
        end
        else begin
            wif.halt <= wif.temp_halt ? 1 : wif.halt;
        end
    end

    always_comb begin // final mux determing the end output for wdat
        wif.wdat = wif.out_port;
        if (wif.final_mux[2] == 1'b1) begin
            wif.wdat = wif.u_type;
        end
        else if(wif.final_mux[1] == 1'b1) begin
            wif.wdat = wif.next_memaddr;
        end
        else if(wif.final_mux[0] == 1'b1) begin
            wif.wdat = wif.dmemload;
        end
    end

endmodule