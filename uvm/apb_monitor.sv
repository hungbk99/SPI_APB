/*******************************************************************************
  FILE : apb_monitor.sv
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
  FILE : apb_monitor.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     22.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_monitor extends uvm_monitor;
  //Virtual interface
  virtual apb_if  vif;

  //Pointer to configuration class
  apb_config cfg;

  //Property: Indicate number of transactions
  protected int unsigned num_transactions = 0;

  //Property: Control -> checker + coverage
  bit check_enable = 1;
  bit coverage_enable = 1;

  //TLM port: transactions send to Scoreboard, Register Database, etc
  uvm_analysis_port #(apb_transaction) item_collected_port;

  //TLM port: connect to collector: -> look at address information
  uvm_blocking_peek_port #(apb_transaction) addr_trans_port;

  //TLM port: connect to collector: -> loot at apb_transaction -> write()
  uvm_analysis_imp #(apb_transaction, apb_monitor) coll_mon_export;

  //TLM port: connect to sequencer: -> allow sequencer look for response
  uvm_blocking_peek_imp #(apb_transaction, apb_monitor) addr_trans_export;

  //Address phase event
  event addr_trans_event;

  //Current transaction
  apb_transaction trans_collected;

  //Utilities & Automation macros
  `uvm_component_utils_begin(apb_monitor)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_field_int(num_transactions, UVM_DEFAULT)
    `uvm_field_int(check_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  //Coverage
  covergroup apb_trans_cg;
    option.per_instance = 1;
    TRANS_ADDR: coverpoint trans_collected.paddr {
      bins ZERO = {0};
      bins NON_ZERO = {[1:32'hFFFF_FFFE]};
      bins ALL_ONE = {[1:32'hFFFF_FFFE]};
    }

    TRANS_DIRECTION: coverpoint trans_collected.pwrite {
      bins READ = {APB_READ};
      bins WRITE = {APB_WRITE};
    }

    TRANS_DATA: coverpoint trans_collected.pdata {
      bins ZERO = {0};
      bins NON_ZERO = {[1:32'hFFFF_FFFE]};
      bins ALL_ONE = {[1:32'hFFFF_FFFE]};
    }
 
    TRANS_PSTROB: coverpoint trans_collected.pstrb {
      bins ZERO = {0};
      bins ALL_ONE = {15};
      bins NON_ZERO = {[1:14]};
    }

    ADDR_X_DIRECTION: cross TRANS_ADDR, TRANS_DIRECTION;  
  endgroup

  //Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = apb_transaction::type_id::create("trans_collected", this);
    item_collected_port = new("item_collected_port", this);
    addr_trans_port = new("addr_trans_port", this);
    coll_mon_export = new("coll_mon_export", this);
    //Hung_debug_31_3_2021 addr_trans_export = new("addr_trans_port", this);
    addr_trans_export = new("addr_trans_export", this);
  endfunction: new

  //Class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  //Receive transaction from collector  
  extern virtual function void write(apb_transaction trans);
  //Provide data to sequencer
  extern virtual task peek(output apb_transaction trans);
  extern virtual function void perform_check();
  extern virtual function void perform_coverage();
  extern virtual function void report_phase(uvm_phase phase);
endclass: apb_monitor

//FUNCTION: build_phase()
function void apb_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(cfg == null) begin
    if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg))
      `uvm_error("[NOCONFIG]", {"apb_config is not set for: ", get_full_name(), ".cfg"})
  end
endfunction: build_phase

//TASK: run_phase()
task apb_monitor::run_phase(uvm_phase phase);
  forever begin
    addr_trans_port.peek(trans_collected); //address phase
    `uvm_info(get_type_name(), $sformatf("Address phase completed: %0h, [%s]", trans_collected.paddr, trans_collected.pwrite), UVM_HIGH)
    -> addr_trans_event;
  end
endtask: run_phase

//TASK: peek() - [slave agent]sequencer::monitor
task apb_monitor::peek(output apb_transaction trans);
  @addr_trans_event;
  trans = trans_collected;
endtask: peek

//FUNCTION: write() - receive completed transaction from collected
function void apb_monitor::write(apb_transaction trans);
  $cast(trans_collected, trans.clone()); //data phase
  num_transactions++; 
  `uvm_info(get_type_name(), {"Transaction completed:\n", trans_collected.sprint()}, UVM_HIGH)
  if(check_enable) perform_check();
  if(coverage_enable) perform_coverage();
  //Broadcast transaction to other components
  item_collected_port.write(trans_collected);
endfunction: write

//FUNCTION: perform_check() - protocol check
function void apb_monitor::perform_check();
  //Checkers
endfunction: perform_check

//FUNCTION: perform_coverage() 
function void apb_monitor::perform_coverage();
  apb_trans_cg.sample();
endfunction: perform_coverage

//FUNCTION: report_phase()
function void apb_monitor::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("[REPORT_APB_MONITOR]", $sformatf("apb_monitor collects %0d transactions", num_transactions), UVM_LOW)
endfunction: report_phase

