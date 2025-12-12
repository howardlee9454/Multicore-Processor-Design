`include "cpu_types_pkg.vh"

`include "pipeline_register_mw_if.vh"
module pipeline_register_mw (
  input logic CLK, nRST, 
  pipeline_register_mw_if.rf mwif
);

    import cpu_types_pkg::*;
    always_ff @(posedge CLK, negedge nRST ) begin : pipeline_fd
        if(~nRST)begin
            mwif.n_imemload <= '0; // delete when done 
            mwif.n_out_port <= '0;
            mwif.n_next_memaddr <= '0; 
            mwif.n_final_mux <= '0;
            mwif.n_Reg_write <= 0;
            mwif.n_utype <= '0;
            mwif.n_dmemload <= '0;
            mwif.n_halt <= 0;
            mwif.n_wsel <= '0;
            mwif.n_pc_mux <= 0;
        end 
        else if (mwif.ihit) begin
            mwif.n_out_port <= mwif.out_port;
            mwif.n_next_memaddr <= mwif.next_memaddr;
            mwif.n_final_mux <= mwif.final_mux;
            mwif.n_Reg_write <= mwif.Reg_write;
            mwif.n_utype <= mwif.utype;
            mwif.n_dmemload <= mwif.dmemload;
            mwif.n_halt <= mwif.halt;
            mwif.n_wsel <= mwif.wsel;
            mwif.n_imemload <= mwif.imemload; // delete when done 
            mwif.n_pc_mux <= mwif.pc_mux;
        end
    end

endmodule