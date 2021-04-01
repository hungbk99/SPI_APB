/*******************************************************************************
  FILE : apb_master_seq_lib.sv
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
  FILE : apb_master_sequence_lib.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     23.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

//=============================================================================
// Base Response Sequence
//=============================================================================
class apb_slave_base_seq extends uvm_sequence #(apb_transaction); 
  `uvm_object_utils(apb_slave_base_seq)
  `uvm_declare_p_sequencer(apb_slave_sequencer)    //Hung_mod_30_3_2021

  function new(string name = "apb_slave_base_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    if(starting_phase != null)
      starting_phase.raise_objection(this, {"Running sequence ... [", get_full_name(), "]"});
  endtask: pre_body

  virtual task post_body();
    if(starting_phase != null)
      starting_phase.drop_objection(this, {"Completed sequence ... [", get_full_name(), "]"});
  endtask: post_body
endclass: apb_slave_base_seq

//=============================================================================
// Simple Response Sequence
//=============================================================================
class simple_response_seq extends apb_slave_base_seq;
  `uvm_object_utils(simple_response_seq)

  function new(string name = "simple_response_seq");
    super.new(name);
  endfunction: new

  apb_transaction util_transaction;

  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    forever begin
      //Hung_mod_30_3_2021 m_sequencer.addr_trans_port.peek(util_transaction);
      p_sequencer.addr_trans_port.peek(util_transaction);
      if((util_transaction.pwrite == APB_READ) &&
        //Hung_mod_30_3_2021 (m_sequencer.cfg.check_address_range(util_transaction.paddr) == 1)) begin
        (p_sequencer.cfg.check_address_range(util_transaction.paddr) == 1)) begin
        `uvm_info(get_type_name(), $sformatf("Address: %h range matching read", util_transaction.paddr), UVM_MEDIUM)
        `uvm_do_with(req, {req.pwrite == APB_READ;})
      end
    end
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body
endclass: simple_response_seq

//=============================================================================
// Memory Response Sequence
//=============================================================================
class mem_response_seq extends apb_slave_base_seq;
  `uvm_object_utils(mem_response_seq)

  function new(string name = "mem_response_seq");
    super.new(name);
  endfunction: new

  apb_transaction util_transaction;
 
  rand logic [31:0] mem_data;  
  //Mem Value
  logic [31:0] slave_mem [int];
  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    forever begin
      //Hung_mod_30_3_2021 m_sequencer.addr_trans_port.peek(util_transaction);
      p_sequencer.addr_trans_port.peek(util_transaction);
      if((util_transaction.pwrite == APB_READ) &&
        //Hung_mod_30_3_2021 (m_sequencer.cfg.check_address_range(util_transaction.paddr) == 1)) 
        (p_sequencer.cfg.check_address_range(util_transaction.paddr) == 1)) 
      begin
        `uvm_info(get_type_name(), $sformatf("Address: %h range matching read", util_transaction.paddr), UVM_MEDIUM)
        if(slave_mem.exists(util_transaction.paddr))
          `uvm_do_with(req, {req.pwrite == APB_READ;
                             req.paddr == util_transaction.paddr;
                             req.pdata == slave_mem[util_transaction.paddr];})
        else begin                   
          `uvm_do_with(req, {req.pwrite == APB_READ;
                             req.paddr == util_transaction.paddr;
                             req.pdata == mem_data;})
          mem_data++;
        end
      end
      //Hung_mod_30_3_2021 else if(m_sequencer.cfg.check_address_range(util_transaction.paddr) == 1) begin
      else if(p_sequencer.cfg.check_address_range(util_transaction.paddr) == 1) begin
          slave_mem[util_transaction.paddr] = util_transaction.pdata; 
          //DUMMY response information
          `uvm_do_with(req, {req.pwrite == APB_WRITE;
                           req.paddr == util_transaction.paddr;
                           req.pdata == util_transaction.pdata;})
      end
    end
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body
endclass: mem_response_seq


