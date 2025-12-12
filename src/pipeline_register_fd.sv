`include "cpu_types_pkg.vh"
`include "pipeline_register_fd_if.vh"

module pipeline_register_fd (
  input logic CLK, nRST,
  pipeline_register_fd_if.rf fdif
);

    import cpu_types_pkg::*;
    always_ff @(posedge CLK, negedge nRST ) begin : pipeline_fd
        if(~nRST)begin
            fdif.n1_next_memaddr <= '0;
            fdif.n1_imemaddr <= '0;
            fdif.n1_imemload <= '0;
        end else if(fdif.ihit && fdif.flush)begin
            fdif.n1_next_memaddr <= '0;
            fdif.n1_imemaddr <= '0;
            fdif.n1_imemload <= '0;
        end 
        else if(fdif.stall && fdif.ihit) begin
            fdif.n1_next_memaddr <= fdif.n1_next_memaddr;
            fdif.n1_imemaddr <= fdif.n1_imemaddr;
            fdif.n1_imemload <= fdif.n1_imemload;
        end
        else if (fdif.ihit) begin
            fdif.n1_next_memaddr <= fdif.next_memaddr;
            fdif.n1_imemaddr <= fdif.imemaddr;
            fdif.n1_imemload <= fdif.imemload;
        end
    end

endmodule