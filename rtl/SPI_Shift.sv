//======================================================================
// File name:     SPI_Shift.sv
// Project name:  VG_SoC
// Author:        hungbk99
// Page:          VLSI technology
//======================================================================

import SPI_package::*;
module SPI_Shift
(
//  SPI interface
  output          mosi_somi,
                  ss_0,
                  ss_1,
                  ss_2,
                  ss_3,
  input           miso_simo,
  inout           sclk,
//  Control signals
  input           transfer_complete,
//                  cpha,
                  shift_clock,
                  slave_ena,
                  talk_ena,
                  mstr,
  input [1:0]     slave_select,
  output          s_clock,                
//  Data
  input bus       transfer_data,
  output  bus     receive_data,
//  System
  input           pclk,
                  preset_n
);

//======================================================================
//  Internal Signals
  logic           serial_in,
                  serial_out;

  bus             spi_shift_reg,
                  spi_receive_reg;
//======================================================================
//  SPI Shift Register
  always_ff @(posedge pclk, posedge transfer_complete)
  begin
      if (transfer_complete)
        spi_shift_reg <= transfer_data;      
      else   
        spi_shift_reg <= {spi_shift_reg[SPI_DATA_WIDTH-1:0] << 1, serial_in}; 
  end
  
  assign serial_out = spi_shift_reg[SPI_DATA_WIDTH-1];
//  SPI Receive Register
  always_ff @(posedge pclk, negedge preset_n)
  begin
    if(!preset_n)
        spi_receive_reg <= '0;
    else if(transfer_complete) 
        spi_receive_reg <= spi_shift_reg;
    else 
        spi_receive_reg <= spi_receive_reg;
  end
//  SPI Interface
  assign mosi_somi = talk_ena ? serial_out : 1'b0;
  assign serial_in = talk_ena ? miso_simo : 1'b0;
  assign s_clock = sclk;
  assign sclk = mstr ? shift_clock : 1'bz;
  assign receive_data = spi_receive_reg;
  
  always_comb begin
    ss_0 = 1'b0;
    ss_1 = 1'b0;
    ss_2 = 1'b0;
    ss_3 = 1'b0;
    unique case(slave_select)
    2'b00: ss_0 = slave_ena;
    2'b01: ss_1 = slave_ena;
    2'b10: ss_2 = slave_ena;
    2'b11: ss_3 = slave_ena;
    endcase    
  end

endmodule
                  

