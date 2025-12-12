`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`timescale 1 ns / 1 ns

typedef enum logic {
    IDLE_I,
    FETCH_MEM

} state_s;

module icache(
    input logic CLK, nRST,
    datapath_cache_if.cache dcif,
    caches_if.cache cif
);
  // type import
  import cpu_types_pkg::*;
logic n_iREN;
word_t n_iaddr;
state_s state, next_state;
logic TAG_check;
icachef_t ic_addr, n_ic_addr; //icache 32 bits instruction

// typedef struct packed {
//     logic [ITAG_W-1:0]  tag;  ITAG_W = 26
    
//     logic [IIDX_W-1:0]  idx; IIDX_W = 4
//     logic [IBYT_W-1:0]  bytoff; IBYT_W = 2
//   } icachef_t;
icache_frame [15:0] hashmap , n_hashmap; //icache hashmap
//  typedef struct packed {
// 	logic valid; 
// 	logic [ITAG_W - 1:0] tag;
// 	word_t data;
//   } icache_frame;


always_ff @(posedge CLK, negedge nRST) begin
    if (~nRST) begin
        state <= IDLE_I;
        // ic_addr <= '0; // changed reset value because all zeros created accidental hit
       
            hashmap <= '0;
     
        cif.iREN <= 0;
        cif.iaddr <= '0;
    end
    else begin
        // ic_addr <= n_ic_addr;
        state <= next_state;
        hashmap <= n_hashmap;
        cif.iaddr <= n_iaddr;
        cif.iREN <= n_iREN;
    end
end

assign TAG_check = (hashmap[ic_addr.idx].tag == ic_addr.tag); //Compare tag logic
assign dcif.ihit = (hashmap[ic_addr.idx].valid && TAG_check); // AND gate for ihit
// Logic for MUX based on byte offset
// always_comb begin : mux_imemload
//     case (ic_addr.bytoff)
//         2'd0: dcif.imemload = hashmap[ic_addr.idx].data;
//         2'd1: dcif.imemload = {8'b0, hashmap[ic_addr.idx].data[31:8]};
//         2'd2: dcif.imemload = {16'b0, hashmap[ic_addr.idx].data[31:16]};
//         2'd3: dcif.imemload = {24'b0, hashmap[ic_addr.idx].data[31:24]};
//     endcase
// end
assign dcif.imemload = hashmap[ic_addr.idx].data;

//Hashmap - Fill in data when miss
always_comb begin :Hashmap
    n_hashmap = hashmap;
    if(~cif.iwait && state == FETCH_MEM)begin //maybe can delete state == FETCH_MEM?? Not sure if it will cause timing issue
        n_hashmap[ic_addr.idx].valid = 1;
        n_hashmap[ic_addr.idx].tag = ic_addr.tag;
        n_hashmap[ic_addr.idx].data = cif.iload;
    end
end

//Address decoder
always_comb begin : addr_decode
    // n_ic_addr = ic_a dcif.imemload = hcaddr;
   
        ic_addr = dcif.imemaddr;
    end




//next state logic
always_comb begin
    n_iREN = cif.iREN;
    n_iaddr = cif.iaddr;
    case(state)
        IDLE_I: begin
            if(~dcif.ihit) begin
                next_state = FETCH_MEM;
                n_iREN = 1;
                n_iaddr = dcif.imemaddr;
            end
            else begin
                n_iREN = 0;
                n_iaddr = '0;
                next_state =  IDLE_I;
            end
        end
        FETCH_MEM: begin
            if(~cif.iwait) begin
                next_state = IDLE_I;
                n_iaddr = '0;
                n_iREN = 0;
            end
            else begin
                next_state =  FETCH_MEM;
                n_iaddr = cif.iaddr;
                n_iREN = 1;
            end
        end
        default: begin
            n_iREN = 0;
            
            next_state = state;
        end
    endcase
end


    
endmodule