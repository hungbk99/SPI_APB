//============================================================================
// File name:     SPI_Clock.sv
// Project name:  VG_CPU
// Author:        hungbk99
// Page:          VLSI technology
//============================================================================


import SPI_package::*;
module SPI_Clock
(
//  SPI internal connect  
  input       pclk,
              fclk,
              preset_n,
              transfer_start,
              mclk_sel,
              cpol,
              cpha,
              mstr,
  input [4:0] data_len,
  input [7:0] baud_rate,

//  Slave connect
  input       s_clock,
  
  output      transfer_complete,
              shift_clock,
              slave_select
);

//============================================================================
// Internal signals
  wire  pre_clock, 
        transfer_req,
        req_buf,
        req_detect;


//============================================================================
// Clock select
  assign  pre_clock = mclk_sel ? fclk : pclk;
  assign  transfer_req = mclk_sel ? sync_req : transfer_start; 

// Synchronous logic
  always_ff @(posedge fclk, negedge preset_n) 
  begin
    if(!preset_n)
    begin
      req_buf <= 1'b0;
      sync_req <= 1'b0;
    end
    else 
    begin
      req_buf <= transfer_start;
      sync_req <= req_buf;
    end
  end

// Request detect
  always_ff @(posedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      req_detect <= 1'b0;
    else 
      req_detect <= transfer_req;
  end

// Clock generator   
  assign  shift_clock = mstr ? gen_clock : s_clock; 
