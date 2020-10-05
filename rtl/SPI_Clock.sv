//============================================================================
// File name:     SPI_Clock.sv
// Project name:  VG_SoC
// Author:        hungbk99
// Page:          VLSI technology
//============================================================================


import SPI_package::*;
module SPI_Clock
(
//  SPI internal connect  
  input sc2scc  sc2scc_control, 
  output        transfer_complete,
  input         fclk,
                pclk,
                preset_n,
                transfer_complete_ack,
//  Slave connect
  input         s_clock,
  
  output        shift_clock
//              slave_select
);

//============================================================================
// Internal signals
  logic pre_clock, 
        transfer_req,
        req_buf,
        req_detect,
        transfer_done,
        sync_req,
        pre_gen_clock,
        clock_enable,
        gen_clock,
        single_pulse_done,
        transfer_done_h,
        transfer_done_l,
        pulse_count_h,
        pulse_count_l;
 
  logic [7:0] invert_count;
  logic [4:0] count;
  
  enum logic [1:0]
  {
    IDLE,
    TRANS,
    DONE_ACK
  } current_state, next_state;

//============================================================================
// Clock select
  assign  pre_clock = sc2scc_control.mclk_sel ? fclk : pclk;
  assign  transfer_req = sc2scc_control.mclk_sel ? sync_req : sc2scc_control.transfer_start; 

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
      req_buf <= sc2scc_control.transfer_start;
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
  assign  shift_clock = sc2scc_control.mstr ? gen_clock : s_clock;
  assign  gen_clock = (sc2scc_control.cpol ^ sc2scc_control.cpha) ? pre_gen_clock : ~pre_gen_clock; 
// FSM    
  always_comb begin
    clock_enable = 1'b0;
    transfer_complete = 1'b0;
    unique case (current_state)
    IDLE:
    begin
      if(req_detect == 1'b1)   
        next_state = TRANS;
      else
        next_state = current_state;
    end
    TRANS:
    begin
      clock_enable = 1'b1;
      if(transfer_done == 1'b1)
        next_state = DONE_ACK;
      else
        next_state = current_state;
    end
    DONE_ACK:
    begin
      transfer_complete = 1'b1;
      if(transfer_complete_ack)
        next_state = IDLE;
      else 
        next_state = current_state;
    end
    default: next_state = current_state;
    endcase
  end

  always_ff @(posedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      current_state <= IDLE;
    else 
      current_state <= next_state;
  end
// Master clock  
  always_ff @(posedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      invert_count <= sc2scc_control.spi_br;
    else if(clock_enable == 1'b1)
    begin
      if(single_pulse_done == 1'b1)
        invert_count <= '0;
      else        
        invert_count <= invert_count + 1; 
    end
    else
      invert_count <= sc2scc_control.spi_br;
  end
  
  always_ff @(posedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      pre_gen_clock <= 1'b0;
    else if(current_state == TRANS)
    begin
      if(single_pulse_done)
        pre_gen_clock <= ~pre_gen_clock;
      else 
        pre_gen_clock <= pre_gen_clock;
    end
    else 
      pre_gen_clock <= sc2scc_control.cpol;
  end

//  precede generated clock
  always_ff @(posedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      pulse_count_h <= '0;
    else if(clock_enable)
      pulse_count_h <= pulse_count_h + 1;
    else if(transfer_done_h)
      pulse_count_h <= '0;
  end
 
//  following generated clock    
  always_ff @(negedge pre_clock, negedge preset_n)
  begin
    if(!preset_n)
      pulse_count_l <= '0;
    else if(current_state == TRANS)
      pulse_count_l <= pulse_count_l + 1;
    else if(transfer_done_l)
      pulse_count_l <= '0;
  end

  assign single_pulse_done = (invert_count == sc2scc_control.spi_br) ? 1'b1 : 1'b0;
  assign transfer_done_h = (pulse_count_h == sc2scc_control.datalen) ? 1'b1 : 1'b0;
  assign transfer_done_l = (pulse_count_l == sc2scc_control.datalen) ? 1'b1 : 1'b0;
  assign transfer_done = (sc2scc_control.cpol == 1'b1) ? transfer_done_h : transfer_done_l;

endmodule
