//=================================================================
// File name:     SPI_TOP.sv
// Project name:  VG SoC 
// Author:        hungbk99
// Page:          VLSI Technology
//=================================================================

import SPI_package::*;
module SPI_TOP
(
// SPI APB interface
  output  apb_interfaces_out  apb_slave_out,
  input   apb_interfaces_in   apb_slave_in,
// SPI interface
  output                      mosi_somi,
                              ss_0,
                              ss_1,
                              ss_2,
                              ss_3,
  input                       miso_simo,
  inout                       sclk                            
);

//=================================================================
// Interface signals
// APB Slave
  logic   rst_n_sync,
//          preset_n,
          pclk;

  bus     wdata,
          rfifo_out;      
  
  sc2as   reg_out;            // outputs from status and control registers
  as2sd   data_req;           // FIFO - user control signals 
  as2sc   as2sc_wen;        // Control registers - user control signals 
// SPI Data
  fifo_interrupt                rfifo_interrupt,
                                tfifo_interrupt;
  logic [SPI_POINTER_WIDTH-1:0] rfifo_status,
                                tfifo_status;
  bus                           transfer_data,
                                receive_data;
  sc2sd                         sc2sd_control;
// SPI Control
  sc2scc                        sc2scc_control;
  logic                         transfer_start_ack,
                                transfer_complete,
                                transfer_complete_ack,
                                slave_ena,
                                talk_ena;
                              
  logic [1:0]                   slave_select;
// SPI Clock
  logic                         fclk,
                                s_clock,
                                shift_clock;
// SPI Shift
  logic                         mstr;

// Other signals

  
//=================================================================
// Sub-module
  SPI_APB_slave APBS_U
  (
    .control_req(as2sc_wen),
    .*
  );

  SPI_Data SPID_U
  (
    .clk(pclk),
    .rst_n(rst_n_sync),
  );
  
  SPI_Control SPIC_U
  (
    .cr_out(reg_out.cr_out),
    .br_out(reg_out.br_out),
    .inter_out(reg_out.inter_out),
    .sr_out(reg_out.sr_out),
    .rintr_out(reg_out.rintr_out),
    .intr_out(reg_out.intr_out),
    .pclk(pclk),
    .preset_n(rst_n_sync),
    .*
  );
  
  SPI_Clock SPICL_U
  (
    .pclk(pclk),
    .preset_n(rst_n_sync),
    .*
  );

  SPI_Shift SPIS_U
  (
    .pclk(pclk),
    .preset_n(rst_n_sync),
    .*
  );

//=================================================================
// Internal Connections
  assign pclk = apb_slave_in.pclk;
  assign mstr = sc2scc_control.mstr;
//  assign preset_n = apb_slave_in.preset_n;
//  assign control_req = as2sc_wen;



endmodule

  
