`include "cpu_types_pkg.vh"
`include "Forward_unit_def.vh"

module Forward_unit(
    Forward_unit_def.frwd fu
);

    // slide 104 for forwarding unit
    // slide 112 for hazard unit 
    always_comb begin :Forwarding
        fu.forward1 = 2'b00;
        fu.forward2 = 2'b00;
        
        if (fu.Reg_write_memory && fu.wsel_memory && (fu.wsel_memory == fu.rsel1)) begin
            fu.forward1 = 2'b10;
        end
        else if (fu.Reg_write_writeback && fu.wsel_writeback && (fu.wsel_writeback == fu.rsel1)) begin
            fu.forward1 = 2'b01;
        end


        if (fu.Reg_write_memory && fu.wsel_memory && (fu.wsel_memory == fu.rsel2)) begin
            fu.forward2 = 2'b10;
        end
        else if (fu.Reg_write_writeback && fu.wsel_writeback && (fu.wsel_writeback == fu.rsel2)) begin
            fu.forward2 = 2'b01;
        end
    end

endmodule