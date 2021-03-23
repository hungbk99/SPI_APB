//=================================================================
// Class Description: Virtual interface for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     18.03.2021  hungbk99  First Creation  
//================================================================

interface apb_if(input pclk, input preset_n);
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter SLAVE_NUM = 8;

  //APB signals
  logic [ADDR_WIDTH-1:0]  paddr;
  logic [DATA_WIDTH-1:0]  pwdata,
                          prdata;
  
  logic                   pwrite,
                          penable,
                          pslverr,
                          pready;
  
  logic [3:0]             pstrb;
  logic [2:0]             pprot;
  logic [SLAVE_NUM-1:0]   psel;

  //Control fields
  bit                     check_enable = 1;
  bit                     coverage_enable = 1;
endinterface: apb_if
