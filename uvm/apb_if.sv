/*******************************************************************************
  FILE : apb_if.sv
*******************************************************************************/
//   Copyright 1999-2010 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

/*******************************************************************************
  FILE : apb_if.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     18.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

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
  //Assertion checks
  `include "./uvmlib/apb_assertion.sv"
endinterface: apb_if
