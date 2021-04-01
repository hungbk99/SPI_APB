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
// base sequence for apb master agent
//=============================================================================
class apb_master_base_seq extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_master_base_seq)    

  function new(string name = "apb_master_base_seq");
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
endclass: apb_master_base_seq

//=============================================================================
// Single Write
//=============================================================================
class write_seq extends apb_master_base_seq;
  
  `uvm_object_utils(write_seq)    

  function new(string name = "write_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    `uvm_do_with(req, {req.pwrite == APB_WRITE;})
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body
endclass: write_seq

//=============================================================================
// Single Read
//=============================================================================
class read_seq extends apb_master_base_seq;
  `uvm_object_utils(read_seq)
 
  function new(string name = "read_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    `uvm_do_with(req, {req.pwrite == APB_READ;})
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body
endclass: read_seq
   
//=============================================================================
// Read After Write
//=============================================================================
class read_after_write_seq extends apb_master_base_seq; 
  `uvm_object_utils(read_after_write_seq)  

  function new(string name = "read_after_write_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    `uvm_do_with(req, {req.pwrite == APB_WRITE;})
    `uvm_do_with(req, {req.pwrite == APB_READ;})
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body

endclass: read_after_write_seq

//=============================================================================
// Multiple Read After Write
//=============================================================================
class multiple_read_after_write_seq extends apb_master_base_seq; 
  `uvm_object_utils(multiple_read_after_write_seq) 
  
  read_after_write_seq raw_seq;
  int unsigned num_seq;
  
  constraint c_num_seq {num_seq inside {[5:10]};} 

  function new(string name = "multiple_read_after_write_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Starting ...", UVM_LOW)
    for(int i = 0; i < num_seq; i++)
      `uvm_info(get_type_name(), $sformatf("Execiting sequence #[%0d]", i), UVM_MEDIUM)
      `uvm_do(raw_seq)
    `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)  
  endtask: body

endclass: multiple_read_after_write_seq


