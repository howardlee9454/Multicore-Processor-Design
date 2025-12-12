/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns
typedef enum logic [3:0] {
    IDLE,
    D_UPDATE1,
    D_UPDATE2,
    I_FETCH,
    SNOOP_START,
    SNOOP_INITIALIZE,
    UPDATE1_RAM,
    UPDATE2_RAM,
    UPDATE_RAM_FETCH_CACHE_1,
    UPDATE_RAM_FETCH_CACHE_2
} state_b;

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;

  logic main, n_main;
  state_b state, n_state;
  // //modport cc (
  //         // cache inputs
  // input   iREN, dREN, dWEN, dstore, iaddr, daddr,
  //         // ram inputs
  //         ramload, ramstate,
  //         // coherence inputs from cache
  //         ccwrite, cctrans,
  //         // cache outputs
  // output  iwait, dwait, iload, dload,
  //         // ram outputs
  //         ramstore, ramaddr, ramWEN, ramREN,
  //         // coherence outputs to cache
  //         ccwait, ccinv, ccsnoopaddr
  //   );
// number of cpus for cc
  always_ff @(posedge CLK, negedge nRST) begin
      if (~nRST) begin
          state <= IDLE;
          main <= 0;
          
      end else begin
          state <= n_state;
          main <= n_main;
    
      end
  end
      
      always_comb begin : next_state_logic
          n_state = state;
          n_main = main;
          ccif.iwait = '1;
          ccif.dwait = '1;
          ccif.ramaddr = '0;
          ccif.ramREN = 0;
          ccif.ramWEN = 0;
          ccif.dload = '0;
          ccif.iload = '0;
          ccif.ramstore = 0;
          ccif.ccwait = 0;
          ccif.ccinv = 0;
          ccif.ccsnoopaddr = '0;
          
          case (state)
              IDLE: begin
                  //priority is DWEN, DREN, IREN
                  if(ccif.dWEN[main]) begin
                      n_state = D_UPDATE1;
                  end
                  else if(ccif.dWEN[~main]) begin
                      n_state = D_UPDATE1;
                      n_main = ~main;
                  end
                  else if(ccif.dREN[main])begin
                      n_state = SNOOP_START;
                  end 
                  else if(ccif.dREN[~main])begin
                      n_state = SNOOP_START;
                      n_main = ~main;
                  end
                  else if(ccif.iREN[main])begin
                      n_state = I_FETCH;
                  end
                  else if(ccif.iREN[~main])begin
                      n_state = I_FETCH;
                      n_main = ~main;
                  end 
                  
              end
              D_UPDATE1: begin
                  ccif.ramWEN = 1;
                      ccif.ramstore = ccif.dstore[main];
                      ccif.ramaddr = ccif.daddr[main];
                      ccif.dwait[main] = 1;
                  if(ccif.ramstate == ACCESS)begin
                      n_state = D_UPDATE2;
                      ccif.dwait[main] = 0;//(ccif.ramstate!=ACCESS);
                      ccif.dload[main] = ccif.ramload;
                  end 
                  // else begin
                  //     n_state = D_UPDATE1;
                  //     ccif.ramWEN = 1;
                  //     ccif.ramstore = ccif.dstore[main];
                  //     ccif.ramaddr = ccif.daddr[main];
                  //     ccif.dwait = 1;
                  // end
              end
              D_UPDATE2: begin
                  ccif.ramWEN = 1;
                      ccif.ramstore = ccif.dstore[main];
                      ccif.ramaddr = ccif.daddr[main];
                      ccif.dwait[main] = 1;//(ccif.ramstate != ACCESS);
                  if(ccif.ramstate == ACCESS)begin
                      n_state = IDLE;
                      n_main = ~main;
                        ccif.dwait[main] = 0;
                        ccif.dload[main] = ccif.ramload;
                  end
                  //  else begin
                  //     n_state = D_UPDATE2;
                  //     ccif.ramWEN = 1;
                  //     ccif.ramstore = ccif.dstore[main];
                  //     ccif.ramaddr = ccif.daddr[main];
                  //     ccif.dwait[main] = 1;//(ccif.ramstate != ACCESS);
                      
                  // end
              end
              I_FETCH: begin
                      ccif.ramaddr = ccif.iaddr[main];
                      ccif.ramREN = 1;
                      ccif.iwait[main] = 1'b1;
                  if(ccif.ramstate == ACCESS)begin
                      n_state = IDLE;
                      n_main = ~main;
                      ccif.iwait[main] = 1'b0;//(ccif.ramstate != ACCESS);
                      ccif.iload[main] = ccif.ramload;
                  end
                  // end else begin
                  //     n_state = I_FETCH;
                  //     ccif.ramaddr = ccif.iaddr[main];
                  //     ccif.ramREN = 1;
                  //     ccif.iwait[main] = 1'b1;
                  //     // ccif.iwait[main] = (ccif.ramstate != ACCESS);
                  //     // ccif.iload[main] = ccif.ramload;
              
              end
              SNOOP_START: begin
                  n_state = SNOOP_INITIALIZE;
                  ccif.ccwait[~main] = 1;
              end
              SNOOP_INITIALIZE: begin
                  ccif.ccsnoopaddr[~main] = ccif.daddr[main];
                  ccif.ccinv[~main] = ccif.ccwrite[main];

                  if(ccif.cctrans[~main])begin
                      n_state = UPDATE_RAM_FETCH_CACHE_1;
                  end else begin
                      n_state = UPDATE1_RAM;
                  end
              end
              // FETCH_RAM: begin
              //     if(ccif.ramstate == ACCESS)begin
              //         n_state = UPDATE1_RAM;

              //     end else begin
              //         n_state = FETCH_RAM;
              //         ccif.ramREN = 1;
              //         ccif.ramaddr = ccif.daddr[main];
              //         ccif.dwait = 1;
              //     end
              // end
              UPDATE1_RAM: begin
                  ccif.dwait[main] = 1;
                      ccif.ramREN = 1;
                      ccif.ramaddr = ccif.daddr[main];
                  if(ccif.ramstate == ACCESS)begin
                      n_state = UPDATE2_RAM;
                      ccif.dload[main] = ccif.ramload;
                      ccif.dwait[main] = 0;

                  end 
                  // else begin
                  //     n_state = UPDATE1_RAM;
                      
                  //     ccif.dwait[main] = 1;
                  //     ccif.ramREN = 1;
                  //     ccif.ramaddr = ccif.daddr[main];
        
                  // end
              end
              UPDATE2_RAM: begin
                  ccif.dwait[main] = 1;
                      ccif.ramREN = 1;
                      ccif.ramaddr = ccif.daddr[main];
                  if(ccif.ramstate == ACCESS)begin
                      n_state = IDLE;
                      n_main = ~main;
                      ccif.dload[main] = ccif.ramload;
                      ccif.dwait[main] = 0;

                  end 
                  // else begin
                  //     n_state = UPDATE2_RAM;
                  //     ccif.dwait[main] = 1;
                  //     ccif.ramREN = 1;
                  //     ccif.ramaddr = ccif.daddr[main];
        
                  // end
                  
              end
              UPDATE_RAM_FETCH_CACHE_1: begin
                  ccif.ccsnoopaddr[~main] = ccif.daddr[main];
                  ccif.dload[main] = ccif.dstore[~main];
                    //   ccif.dwait[main] = '0;
                      //ccif.dwait[~main] = 1;
                      ccif.ramWEN = 1;
                      ccif.ramstore = ccif.dstore[~main];
                      ccif.ramaddr = ccif.daddr[main];
                  if(ccif.ramstate == ACCESS)begin
                      n_state = UPDATE_RAM_FETCH_CACHE_2;
                      ccif.dwait = '0;
                  end
                  //  else begin
                  //     n_state = UPDATE_RAM_FETCH_CACHE_1;
                  //     ccif.dload[main] = ccif.dstore[~main];
                  //     ccif.dwait[main] = 0;
                  //     ccif.ramWEN = 1;
                  //     ccif.ramstore = ccif.dstore[~main];
                  //     ccif.ramaddr = ccif.daddr[main];
                  // end
              end
              UPDATE_RAM_FETCH_CACHE_2: begin
                  ccif.ccsnoopaddr[~main] = ccif.daddr[main];
                  ccif.dload[main] = ccif.dstore[~main];
                    //   ccif.dwait[main] = 0;
                    //   ccif.dwait[~main] = 1;
                      ccif.ramWEN = 1;
                      ccif.ramstore = ccif.dstore[~main];
                      ccif.ramaddr = ccif.daddr[main];
                  if(ccif.ramstate == ACCESS)begin
                      n_state = IDLE;
                      n_main = ~main;
                      ccif.dwait = '0;
                  end 
                  // else begin
                  //     n_state = UPDATE_RAM_FETCH_CACHE_2;
                  //     ccif.dload[main] = ccif.dstore[~main];
                  //     ccif.dwait[main] = 0;
                  //     ccif.ramWEN = 1;
                  //     ccif.ramstore = ccif.dstore[~main];
                  //     ccif.ramaddr = ccif.daddr[main];
                  // end
              end
          endcase
      end 
endmodule