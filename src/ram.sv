/*
  Eric Villasenor
  evillase@gmail.com
  Jimmy Jin
  mingze.jin01@gmail.com

  ram with variable latency and debug port
*/

// interface
`include "cpu_ram_if.vh"
// types
`include "cpu_types_pkg.vh"

module ram (
    input logic CLK,
    input logic nRST,
    input logic halt,
    cpu_ram_if.ram ramif,
    // vio debug ports
    input  logic [13:0]               dbg_addr,
    output logic [31:0]               dbg_data_out
);
  // import types
  import cpu_types_pkg::*;

  parameter BAD = 32'hBAD1BAD1, LAT = 0;

  logic [3:0]   count;
  ramstate_t    rstate;
  word_t        q, addr;
  logic         wren;
  logic [1:0]   en;


`ifdef USE_VIVADO
  localparam BRAM_DEPTH = 16384;
  localparam BRAM_ADDR_BITS = 14;
  logic [31:0] mem [0:BRAM_DEPTH-1]; // BRAM

  // cpu
  logic [BRAM_ADDR_BITS-1:0] sel_a;
  assign sel_a = ramif.ramaddr[BRAM_ADDR_BITS+1:2];

  always_ff @(posedge CLK) begin
    if (wren) begin
      mem[sel_a] <= ramif.ramstore;
    end
    q <= mem[sel_a];
  end

  // bram

  logic [31:0] dbg_data_out_reg;
  always_ff @(posedge CLK) begin
    dbg_data_out_reg <= mem[dbg_addr];
  end
  assign dbg_data_out = dbg_data_out_reg;

  initial begin
    $readmemh("meminit.mem", mem);
  end

`else
  altsyncram altsyncram_component (
        .address_a (ramif.ramaddr[15:2]),
        .clock0 (CLK),
        .data_a (ramif.ramstore),
        .wren_a (wren),
        .q_a (q),
        .aclr0 (1'b0),
        .aclr1 (1'b0),
        .address_b (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a (1'b1),
        .byteena_b (1'b1),
        .clock1 (1'b1),
        .clocken0 (1'b1),
        .clocken1 (1'b1),
        .clocken2 (1'b1),
        .clocken3 (1'b1),
        .data_b (1'b1),
        .eccstatus (),
        .q_b (),
        .rden_a (1'b1),
        .rden_b (1'b1),
        .wren_b (1'b0));
  defparam
    altsyncram_component.clock_enable_input_a = "BYPASS",
    altsyncram_component.clock_enable_output_a = "BYPASS",
    altsyncram_component.init_file = "meminit.hex",
    altsyncram_component.intended_device_family = "Cyclone II",
    altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=RAM",
    altsyncram_component.lpm_type = "altsyncram",
    altsyncram_component.numwords_a = 16384,
    altsyncram_component.operation_mode = "SINGLE_PORT",
    altsyncram_component.outdata_aclr_a = "NONE",
    altsyncram_component.outdata_reg_a = "UNREGISTERED",
    altsyncram_component.power_up_uninitialized = "FALSE",
    altsyncram_component.widthad_a = 14,
    altsyncram_component.width_a = 32,
    altsyncram_component.width_byteena_a = 1;
`endif

  assign ramif.ramload = (rstate == ACCESS) ? q : BAD;
  assign wren = (rstate == ACCESS) ? ramif.ramWEN : 0;
  assign ramif.ramstate = rstate;

  always_ff @(posedge CLK, negedge nRST)
  begin
    if (!nRST)
    begin
      count <= 0;
      addr <= 0;
      en <= 3;
    end
    else if (
      !(ramif.ramREN || ramif.ramWEN) ||
      ramif.ramaddr != addr ||
      en != {ramif.ramREN, ramif.ramWEN}
    )
    begin
      en  <= {ramif.ramREN, ramif.ramWEN};
      count <= 0;
      addr <= ramif.ramaddr;
    end
    else if ((ramif.ramREN || ramif.ramWEN) && count < LAT)
    begin
      count <= count + 1;
    end
  end

  always_comb
  begin
    casez({ramif.ramWEN,ramif.ramREN,nRST})
      3'b00z:   rstate = FREE;
      3'b011,
      3'b101:   rstate = BUSY;
      default:  rstate = ERROR;
    endcase
    if (!nRST || ((addr == ramif.ramaddr) && ((ramif.ramREN || ramif.ramWEN) && (count >= LAT))))
    begin
      rstate = ACCESS;
    end
  end

endmodule
