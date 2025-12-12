`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`timescale 1 ns / 1 ns
//Questions list:
// ccsnoopaddr need to latch or not?
typedef enum logic [3:0] {
    IDLE1,
    FETCH_1,
    FETCH_2,
    UPDATE_1,
    UPDATE_2,
    CHECK_DIRTY,
    FLUSH_1,
    FLUSH_2,
    FLUSHED,
    SNOOP_DCACHE,
    SNOOP_WORD1,
    SNOOP_WORD2
} state_d;

module dcache(
    input logic CLK, nRST,
    datapath_cache_if.cache dcif,
    caches_if.cache cif
);
  // type import
  import cpu_types_pkg::*;

state_d state, next_state;
logic n_dREN, n_dWEN;
word_t n_dstore, n_daddr;
logic TAG_check, Dirty_check;
logic Valid1, Valid2, TAG_check1, TAG_check2, Dirty1, Dirty2;
logic dirty_halt;
logic [25:0] Compare_tag1, Compare_tag2;
logic [3:0]counter, n_counter, f2_counter;
logic [7:0]lru, n_lru; // 0 indicate hashmap1 is lru, 1 indicate hashmap2 is lru
dcachef_t dc_addr, n_dc_addr, snoop_addr; //dcache 32 bits instruction
logic TAG_check3, TAG_check4;
logic fetch1_edge_case;
dcache_frame hashmap1 [7:0], n_hashmap1 [7:0], hashmap2 [7:0], n_hashmap2 [7:0]; //dcache hashmap
// LRSC based commands 
logic [30:0] res_set, n_res_set; // [29:4] is tag, [3:1] is idx, [0] is valid
logic successful_sc, sc_hit, sc_dmemload;
logic snoopway, next_snoopway;


always_ff @(posedge CLK, negedge nRST) begin
    if (~nRST) begin
        state <= IDLE1;
        for (int i = 0; i < 16; i++) begin
        hashmap1[i] <= '0;
        hashmap2[i] <= '0;
        end
        lru <= '0;
        counter <= '0;
        cif.dstore <= '0;
        cif.dREN <= 0;
        cif.dWEN <= 0;
        f2_counter <= 0;
        cif.dstore <= n_dstore;
        cif.daddr <= '0;
        res_set <= '0;
        snoopway <= 0;
       // snoop_addr <= '0;
    end
    else begin
        state <= next_state;
        hashmap1 <= n_hashmap1;
        hashmap2 <= n_hashmap2;
        lru <= n_lru;
        counter <= n_counter;
        f2_counter <= counter;
        cif.dREN <= n_dREN;
        cif.dWEN <= n_dWEN;
        cif.dstore <= n_dstore;
        cif.daddr <= n_daddr;
        res_set <= n_res_set;
        snoopway <= next_snoopway;
        //snoop_addr <= cif.ccsnoopaddr;
    
      
    end
end
assign fetch1_edge_case = ((TAG_check3|| TAG_check4) && ~(TAG_check1 || TAG_check2)) && dcif.dmemWEN;
assign snoop_addr = cif.ccsnoopaddr;
assign Compare_tag1 = hashmap1[dc_addr.idx].tag;
assign Compare_tag2 = hashmap2[dc_addr.idx].tag;
assign Valid1 = hashmap1[dc_addr.idx].valid;
assign Valid2 = hashmap2[dc_addr.idx].valid;
assign Dirty1 = hashmap1[dc_addr.idx].dirty;
assign Dirty2 = hashmap2[dc_addr.idx].dirty;

assign TAG_check1 = ((Compare_tag1 == dc_addr.tag) && Valid1 && Dirty1); // && dirty1
assign TAG_check2 = ((Compare_tag2 == dc_addr.tag) && Valid2 && Dirty2); // && dirty2
assign TAG_check3 = ((Compare_tag1 == dc_addr.tag) && Valid1);
assign TAG_check4 = ((Compare_tag2 == dc_addr.tag) && Valid2);
assign dcif.dhit = ((TAG_check1 || TAG_check2) && state == IDLE1 && dcif.dmemWEN)
                 || ((TAG_check3 || TAG_check4) && state == IDLE1 && dcif.dmemREN) || (sc_hit && dcif.dmemWEN && dcif.datomic);

// Lock Logic -------------------------------------------------------------------------------------
//lr & sc
always_comb begin: SC
    sc_hit = 1;
    sc_dmemload = 1'b0;
    successful_sc = (res_set[0] && (res_set[30:1] == dcif.dmemaddr[31:2]));
    if(dcif.datomic && dcif.dmemWEN) begin
        // if(res_set[0] && (res_set[29:1] == dcif.dmemaddr[31:3] && state == FETCH_2 && ~cif.dwait))begin //sc
        //     successful_sc = 1;
        sc_hit = 0;
        // end
        // else 
        if(state == IDLE1) begin
            if (~(res_set[0] && res_set[30:1] == dcif.dmemaddr[31:2])) begin
                sc_dmemload = 1'b1;
                sc_hit = 1;
            end 
        end
    end
end

always_comb begin: LR_INVALIDATE
    n_res_set = res_set;
    if(dcif.dmemREN && dcif.datomic && state==IDLE1)begin //lr
        n_res_set[30:1] = dcif.dmemaddr[31:2];
        n_res_set[0] = 1;
    end 
    else if((dcif.dmemWEN && (res_set[30:1] == dcif.dmemaddr[31:2] && dcif.dhit))    // i overwrote it
             || (snoop_addr[31:2] == res_set[30:1] && cif.ccinv && state == SNOOP_DCACHE)) begin              // got snooped at res set
        n_res_set = '0;
    end
end



// Normal Dcache logic -------------------------------------------------------------------------------------


assign cif.ccwrite = dcif.dmemWEN;
always_comb begin : dmemload
    dcif.dmemload = '0;
    if(TAG_check)begin
        if(TAG_check3)begin
            dcif.dmemload = hashmap1[dc_addr.idx].data[dc_addr.blkoff];
        end
        if(TAG_check4)begin
            dcif.dmemload = hashmap2[dc_addr.idx].data[dc_addr.blkoff];
        end
    end
    if(sc_hit && dcif.dmemWEN && dcif.datomic)begin
        dcif.dmemload = sc_dmemload;
    end
end
//State transition signals
assign Dirty_check = lru[dc_addr.idx] ? Dirty2 : Dirty1;
assign TAG_check = dcif.dhit;//Indication for hit or miss


//Hashmap - Fill in data when miss - not done
always_comb begin :Hashmap
    n_hashmap1 = hashmap1;
    n_hashmap2 = hashmap2;

    if(state == FETCH_2 && ~cif.dwait)begin
        if(lru[dc_addr.idx] == 0)begin
            n_hashmap1[dc_addr.idx].valid = 1;
            n_hashmap1[dc_addr.idx].tag = dc_addr.tag;
            n_hashmap1[dc_addr.idx].data[~dc_addr.blkoff] = cif.dload;
            if(dcif.dmemWEN)begin
                n_hashmap1[dc_addr.idx].dirty = 1;
            end
        end else begin
            n_hashmap2[dc_addr.idx].valid = 1;
            n_hashmap2[dc_addr.idx].tag = dc_addr.tag;
            n_hashmap2[dc_addr.idx].data[~dc_addr.blkoff] = cif.dload;
            if(dcif.dmemWEN)begin
                n_hashmap2[dc_addr.idx].dirty = 1;
            end
        end
    end
    if(state == FETCH_1 && ~cif.dwait)begin
        if(lru[dc_addr.idx] == 0)begin
            n_hashmap1[dc_addr.idx].data[dc_addr.blkoff] = cif.dload;
        end else begin
            n_hashmap2[dc_addr.idx].data[dc_addr.blkoff] = cif.dload;
        end
    end

    if(state == UPDATE_2 && ~cif.dwait)begin
        if(lru[dc_addr.idx] == 0)begin
            n_hashmap1[dc_addr.idx].dirty = 0;
            
        end else begin
            n_hashmap2[dc_addr.idx].dirty = 0;
        end
        
    end
    if(((successful_sc & dcif.datomic & dcif.dmemWEN)|| (dcif.dmemWEN && ~dcif.datomic)) && TAG_check && state == IDLE1)begin // SW and hit
     
        if(TAG_check1 == 1)begin
            n_hashmap1[dc_addr.idx].dirty = 1;
            n_hashmap1[dc_addr.idx].data[dc_addr.blkoff] = dcif.dmemstore;
            
        end else begin
            n_hashmap2[dc_addr.idx].dirty = 1;
            n_hashmap2[dc_addr.idx].data[dc_addr.blkoff] = dcif.dmemstore;

        end
    end
    // invalidate and set dirty bit after examining through each frame
    if(state == CHECK_DIRTY)begin
        if(counter <= 4'd7)begin
            if(hashmap1[counter].valid == 1 && !dirty_halt)begin
                n_hashmap1[counter[2:0]].valid = 0;
            end
        end else begin
            if(hashmap2[counter-8].valid == 1 && !dirty_halt)begin
                n_hashmap2[counter[2:0]].valid = 0;
            end
        end
    end
    if(state == FLUSH_2 && ~cif.dwait)begin
        if(counter <= 4'd7)begin
            n_hashmap1[counter[2:0]].dirty = 0;
            n_hashmap1[counter[2:0]].valid = 0;
            
        end else begin
            n_hashmap2[counter[2:0]].dirty = 0;
            n_hashmap2[counter[2:0]].valid = 0;
        end
        end
    if (state == SNOOP_DCACHE) begin
        if(hashmap1[snoop_addr.idx].valid && (hashmap1[snoop_addr.idx].tag == snoop_addr.tag))begin
            n_hashmap1[snoop_addr.idx].valid = ~cif.ccinv;
            n_hashmap1[snoop_addr.idx].dirty = 0;
        end
        else if(hashmap2[snoop_addr.idx].valid && (hashmap2[snoop_addr.idx].tag == snoop_addr.tag))begin
            n_hashmap2[snoop_addr.idx].valid = ~cif.ccinv;
            n_hashmap2[snoop_addr.idx].dirty = 0;
        end
    end
    end
        
always_comb begin : addr_decode
    dc_addr = '0;
    if(dcif.dmemREN || dcif.dmemWEN)begin
        dc_addr = dcif.dmemaddr;
    end
end

//LRU logic to decide who to fill
//For coherence, have to consider valid bit in lru logic - FIX LATER
always_comb begin: lru_logic
    n_lru = lru;
    if (dcif.dhit) begin
        if((Compare_tag1 == dc_addr.tag) && Valid1 && state == IDLE1)begin
            n_lru[dc_addr.idx] = 1;
        end
        else if((Compare_tag2 == dc_addr.tag) && Valid2 && state == IDLE1)begin
            n_lru[dc_addr.idx] = 0;
        end
    end else if (fetch1_edge_case) begin
        n_lru[dc_addr.idx] = TAG_check4;
    end
end

// ADDRESS BYTE OFFSET ----------------------------------------------------------------------------------------------------


//dirty halt logic
always_comb begin
    if(counter <= 4'd7)begin
        dirty_halt = hashmap1[counter[2:0]].dirty && hashmap1[counter[2:0]].valid;
    end else begin
        dirty_halt = hashmap2[counter[2:0]].dirty && hashmap2[counter[2:0]].dirty;
    end
end


always_comb begin
    n_daddr = cif.daddr;
    n_dstore = cif.dstore;
    n_dWEN = cif.dWEN;
    n_dREN = cif.dREN;
    dcif.flushed = 0;
    cif.cctrans = 0;

    n_counter = counter;
    next_state = state;
    next_snoopway = snoopway;
    case(state)
        IDLE1: begin

            if(cif.ccwait) begin
                next_state = SNOOP_DCACHE;
            end else if(dcif.halt) begin
                n_daddr = '0;
                next_state = CHECK_DIRTY;
                n_dstore = '0;
                n_dWEN = 0;
                n_dREN = 0;
            end
            else if((~(((Compare_tag1 == dc_addr.tag) && Valid1) || ((Compare_tag2 == dc_addr.tag) && Valid2))&& ~Dirty_check && 
                    (dcif.dmemREN || (~sc_hit || (dcif.dmemWEN && ~dcif.datomic)))) || fetch1_edge_case) begin
                n_daddr = dcif.dmemaddr;
                next_state = FETCH_1;
                n_dstore = '0;
                n_dWEN = 0;
                n_dREN = 1;
            end
            else if(~(((Compare_tag1 == dc_addr.tag) && Valid1) || ((Compare_tag2 == dc_addr.tag) && Valid2)) && Dirty_check && (dcif.dmemREN || dcif.dmemWEN)) begin
                n_dstore = lru[dc_addr.idx] == 0 ? hashmap1[dc_addr.idx].data[0]: hashmap2[dc_addr.idx].data[0];
                if(~lru[dc_addr.idx])begin
                    n_daddr = {hashmap1[dc_addr.idx].tag, dc_addr.idx, 1'b0,2'b0};
                end else begin
                    n_daddr = {hashmap2[dc_addr.idx].tag, dc_addr.idx, 1'b0,2'b0};
                end
                next_state = UPDATE_1;
                n_dWEN = 1;
                n_dREN = 0;
            end
            else begin
                n_daddr = '0;
                n_dstore = '0;
                n_dWEN = 0;
                n_dREN = 0;
                next_state = IDLE1;
            end
        end
        FETCH_1: begin
            if(cif.ccwait)begin
                next_state = SNOOP_DCACHE;
            end
            else if(~cif.dwait) begin
                n_daddr = {dcif.dmemaddr[31:3],~dcif.dmemaddr[2], 2'b0};
                next_state = FETCH_2;
                n_dREN = 1;
               
            end
            else begin
                n_dREN = cif.dREN;
                n_daddr = cif.daddr;
                next_state =  FETCH_1;
            end
        end
        FETCH_2: begin
            if(cif.ccwait)begin
                next_state = SNOOP_DCACHE;
            end
            else if(~cif.dwait) begin
                n_dREN = 0;
                n_daddr = '0;
                next_state = IDLE1;
            end
            else begin
                n_daddr = cif.daddr;
                n_dREN = cif.dREN;
                next_state =  FETCH_2;
            end
        end
        UPDATE_1: begin
            if(cif.ccwait)begin
                next_state = SNOOP_DCACHE;
            end
            else if(~cif.dwait) begin
                n_dWEN = 1;
                n_dstore = lru[dc_addr.idx] == 0 ? hashmap1[dc_addr.idx].data[1]: hashmap2[dc_addr.idx].data[1];
                if(~lru[dc_addr.idx])begin
                    n_daddr = {hashmap1[dc_addr.idx].tag, dc_addr.idx, 1'b1,2'b0};
                end else begin
                    n_daddr = {hashmap2[dc_addr.idx].tag, dc_addr.idx, 1'b1,2'b0};
                end
                next_state = UPDATE_2;
            end
            else begin
                n_dWEN = cif.dWEN;
                n_dstore = cif.dstore;
                n_daddr = cif.daddr;
                next_state =  UPDATE_1;
            end
        end
        UPDATE_2: begin
            if(cif.ccwait)begin
                next_state = SNOOP_DCACHE;
            end
            else if(~cif.dwait) begin
                n_dREN = 1;
                n_dWEN = 0;
                next_state = FETCH_1;
                n_daddr = dcif.dmemaddr;
            end
            else begin
                n_daddr = cif.daddr;
                n_dWEN = cif.dWEN;
                next_state =  UPDATE_2;
            end
        end
        CHECK_DIRTY: begin
            if(cif.ccwait) begin
                next_state = SNOOP_DCACHE;
            end else if(counter == 4'b1111 && ~dirty_halt)begin
                next_state = FLUSHED;
                n_dWEN = 0;
                n_dREN = 0;
                n_dstore = '0;
                n_daddr = '0;
                
           
            end
            else if(dirty_halt) begin
                // n_daddr = //dcif.dmemaddr;
                next_state = FLUSH_1;
                n_dWEN = 1;
                n_counter = counter;
                if(counter <= 4'd7)begin
                    n_daddr = {hashmap1[counter[2:0]].tag, counter[2:0], 1'b0, 2'b0};
                    n_dstore = hashmap1[counter[2:0]].data[0]; 
                end else begin
                    n_daddr = {hashmap2[counter[2:0]].tag, counter[2:0], 1'b0, 2'b0};
                    n_dstore = hashmap2[counter[2:0]].data[0];
               end
                
            end
            else begin
                // n_daddr = '0;
                n_dWEN = 0;
                next_state =  CHECK_DIRTY;
                n_dstore = '0;
                n_counter = counter + 1;
            end
        end
        FLUSH_1: begin
            if(cif.ccwait) begin
                next_state = SNOOP_DCACHE;
            end else if(~cif.dwait) begin
                next_state = FLUSH_2;
                n_dWEN = 1;
                if(counter <= 4'd7)begin
                    n_daddr = {hashmap1[counter[2:0]].tag, counter[2:0], 1'b1, 2'b0};
                    n_dstore = hashmap1[counter[2:0]].data[1]; 
                end else begin
                    n_daddr = {hashmap2[counter[2:0]].tag, counter[2:0], 1'b1, 2'b0};
                    n_dstore = hashmap2[counter[2:0]].data[1]; 
               end
            end
            else begin
                n_daddr = cif.daddr;
                n_dWEN = cif.dWEN;
                next_state =  FLUSH_1;
                n_dstore = cif.dstore;
            end
        end
        FLUSH_2: begin
            if(~cif.dwait && (counter == 4'b1111))begin
               next_state = FLUSHED;
                n_dWEN = 0;
                n_dREN = 0;
                n_dstore = '0;
                n_daddr = '0;
            end 
            else if(~cif.dwait) begin
                next_state = CHECK_DIRTY;
                n_counter = counter + 1;
                n_dWEN = 0;
                n_dstore = '0;
                n_daddr = '0;
            end
            else begin
                n_daddr = cif.daddr;
                n_dWEN = cif.dWEN;
                n_dstore = cif.dstore;
                next_state = FLUSH_2;
            end
        end
        
        FLUSHED: begin
            dcif.flushed = 1;
            next_state = state;
        end
        SNOOP_DCACHE: begin
            if(hashmap1[snoop_addr.idx].valid && (hashmap1[snoop_addr.idx].tag == snoop_addr.tag))begin
                // n_hashmap1[snoop_addr.idx].valid = ~cif.ccinv; // Need to remove logic here
                // n_hasmap1 is set in another logic block and this one (not allowed)
                // Would suggest moving logic into other logic block
                cif.cctrans = 1;
                next_state = SNOOP_WORD1;
                n_daddr = cif.ccsnoopaddr;
                n_dstore = hashmap1[snoop_addr.idx].data[snoop_addr.blkoff];
                next_snoopway = 0;
            end
            else if(hashmap2[snoop_addr.idx].valid && (hashmap2[snoop_addr.idx].tag == snoop_addr.tag))begin
                // n_hashmap2[snoop_addr.idx].valid = ~cif.ccinv; // Same issue as line above
                cif.cctrans = 1;
                next_state = SNOOP_WORD1;
                n_daddr = cif.ccsnoopaddr;
                n_dstore = hashmap2[snoop_addr.idx].data[snoop_addr.blkoff];
                next_snoopway = 1;
            end else begin
                next_state = IDLE1;
            end 
            
        end
        SNOOP_WORD1: begin
            if(~cif.dwait)begin
                next_state = SNOOP_WORD2;
                if(~snoopway)begin
                    n_dstore = hashmap1[snoop_addr.idx].data[~snoop_addr.blkoff];
                end else begin
                    n_dstore = hashmap2[snoop_addr.idx].data[~snoop_addr.blkoff];
                end
                n_daddr = {snoop_addr.tag,snoop_addr.idx,~snoop_addr.blkoff, 2'b0};
            end else begin
                next_state = state;
                n_dstore = cif.dstore;
                n_daddr = cif.daddr;
            end

        end

        SNOOP_WORD2: begin
            if(~cif.dwait)begin
                next_state = IDLE1;
               
            end else begin
                next_state = state;
                n_dstore = cif.dstore;
                n_daddr = cif.daddr;
            end

        end
        // default: begin
        //     next_state = state;
        // end
    endcase
end


    
endmodule