/*******************************************************************************
  FILE : apb_transaction.sv
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
  FILE : apb_transaction.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     18.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_transaction extends uvm_sequence_item;
  rand bit [31:0]         paddr;
  rand bit [31:0]         pdata;
  rand bit [2:0]          pprot;
  rand bit [3:0]          pstrb;
  rand bit                pready;
  rand apb_direction_enum pwrite;
  bit                     pslverr;
  string                  slave;
  string                  master;

  //Control Fields
  rand int unsigned       transmit_delay;
  rand int unsigned       pready_delay;    
 
  //Constraints
  constraint c_addr  { paddr[1:0] == 2'b00; }
  constraint c_pstrb { pstrb dist {15:= 9, [0;14]:/1}; }
  constraint c_pready { pready dist {1:= 9, 0:=1}; }
  constraint c_pready_delay { pready_delay dist {0:=8, 1:=1, 2:=1}; }

  //UVM utilities & automation macros for data items
  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(paddr, UVM_DEFAULT)
    `uvm_field_int(pwdata, UVM_DEFAULT)
    `uvm_field_int(pprot, UVM_DEFAULT)
    `uvm_field_int(pstrb, UVM_DEFAULT)
    `uvm_field_int(pslverr, UVM_DEFAULT)
    `uvm_field_int(pready, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
    `uvm_field_enum(apb_direction_enum, pwrite, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
    `uvm_field_int(transmit_delay, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
    `uvm_field_int(pready_delay, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
    `uvm_field_string(slave, UVM_DEFAULT | UVM_NOCOMPARE);
    `uvm_field_string(master, UVM_DEFAULT | UVM_NOCOMPARE);
  `uvm_object_utils_end

  //Constructor
  function new(string name = "apb_transaction");
    super.new(name);
  endfunction: new

  virtual task print_apb_seq();
    if(pwrite == APB_READ)
      `uvm_info("[APB_SEQ]", $sformatf("[READ TRANSFER]::prdata = %0h, paddr = %0h", 
                                        pdata, paddr);
    else
      `uvm_info("[APB_SEQ]", $sformatf("[WRITE TRANSFER]::pwdata = %0h, paddr = %0h", 
                                        pdata, paddr);
  endtask: print_apb_seq
endfunction: apb_transaction
