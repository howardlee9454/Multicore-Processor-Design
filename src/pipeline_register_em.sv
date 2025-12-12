`include "cpu_types_pkg.vh"

`include "pipeline_register_em_if.vh"
module pipeline_register_em (
  input logic CLK, nRST, 
  pipeline_register_em_if.rf emif
);

    import cpu_types_pkg::*;
    always_ff @(posedge CLK, negedge nRST ) begin : pipeline_fd
        if (~nRST) begin
            emif.n_imemload <= '0; // delete when done 
            emif.n_out_port <= '0;
            emif.n_next_memaddr <= '0;
            emif.n_utype <= '0;
            emif.n_rdat2 <= '0;
            emif.n_final_mux <= '0;
            emif.n_Reg_write <= 0;
            emif.dmemREN <= 0;
            emif.dmemWEN <= 0;
            emif.n_halt <= 0;
            emif.n_wsel <= '0;
            emif.n_pc_mux <= 0;
            emif.n_pc_cntrl <= 0;
            emif.n_final_memaddr <= '0;
            emif.n2_atomic <= 0;
        end else if(emif.flush && emif.ihit)begin
            emif.n_imemload <= '0; // delete when done 
            emif.n_out_port <= '0;
            emif.n_next_memaddr <= '0;
            emif.n_utype <= '0;
            emif.n_rdat2 <= '0;
            emif.n_final_mux <= '0;
            emif.n_Reg_write <= 0;
            emif.dmemREN <= 0;
            emif.dmemWEN <= 0;
            emif.n_halt <= 0;
            emif.n_wsel <= '0;
            emif.n_pc_mux <= 0;
            emif.n_pc_cntrl <= 0;
            emif.n_final_memaddr <= '0;
            emif.n2_atomic <= 0;
        end
        else if (emif.dhit && ~emif.ihit) begin
            emif.dmemREN <= 0;
            emif.dmemWEN <= 0;
            emif.n2_atomic <= 0; // Ask about this signal and how it is handled
            emif.n_imemload <= emif.n_imemload; // delete when done 
            emif.n_out_port <= emif.n_out_port;
            emif.n_next_memaddr <= emif.n_next_memaddr;
            emif.n_utype <= emif.n_utype;
            emif.n_rdat2 <= emif.n_rdat2;
            emif.n_final_mux <= emif.n_final_mux;
            emif.n_Reg_write <= emif.n_Reg_write;
            emif.n_halt <= emif.n_halt;
            emif.n_wsel <= emif.n_wsel;
            emif.n_pc_cntrl <= emif.n_pc_cntrl;
            emif.n_pc_mux <= emif.n_pc_mux;
            emif.n_final_memaddr <= emif.n_final_memaddr;
        end 
        else if (emif.ihit && (~(emif.dmemREN | emif.dmemWEN) | emif.dhit)) begin
            emif.n_out_port <= emif.out_port;
            emif.n_next_memaddr <= emif.next_memaddr;
            emif.n_utype <= emif.utype;
            emif.n_rdat2 <= emif.rdat2;
            emif.n_final_mux <= emif.final_mux;
            emif.dmemREN <= emif.Mem_Read;
            emif.dmemWEN <= emif.Mem_Write;
            emif.n_Reg_write <= emif.Reg_write;
            emif.n_halt <= emif.halt;
            emif.n_wsel <= emif.wsel;
            emif.n_imemload <= emif.imemload; // delete when done 
            emif.n_pc_cntrl <= emif.pc_cntrl;
            emif.n_pc_mux <= emif.pc_mux;
            emif.n_final_memaddr <= emif.final_memaddr;
            emif.n2_atomic <= emif.n1_atomic;
        end
    end

endmodule