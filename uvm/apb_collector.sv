/*******************************************************************************
  FILE : apb_collector.sv
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
  FILE : apb_collector.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     22.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

//=============================================================================

class apb_collector extends uvm_component;
  //Virtual interface
  virtual apb_if  vif;
  //Pointer to configuration class
  apb_config      cfg;

  //Property: Indicate number of transactions
  protected int unsigned num_transactions = 0;

  //Property: Control -> checker & coverage
  bit check_enable = 1;
  bit coverage_enable = 1;

  //TLM port: transactions collected for Monitor & other components
  uvm_analysis_port #(apb_transaction) item_collected_port;

  //TLM port: allow sequencer access to transaction during address phase
  uvm_blocking_peek_imp #(apb_transaction, apb_collector) addr_trans_export;
  
  //Address phase event
  event addr_trans_event;
  
  //Current captured transaction
  apb_transaction trans_collected;

  //UVM Utilities & automation macros
  `uvm_component_utils_begin(apb_collector)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_field_int(num_transaction, UVM_DEFAULT)
    `uvm_field_int(check_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  //Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = apb_transaction::type_id::create("trans_collected");
    item_collected_port = new("item_collected_port", this);
    addr_trans_port = new("addr_trans_port", this);
  endfunction: new

  //Class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task collect_transaction();
  extern virtual task peek(output apb_transaction trans);
  extern virtual function void report_phase(uvm_phase phase);
endclass: apb_collector

//FUNCTION: build_phase()
function void apb_collector::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(cfg == null) begin
    if(!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg));
      `uvm_error("[NOCONFIG]", {"apb_config not set for: ", get_full_name(), ".cfg"})
  end
endfunction: build_phase

//FUNCTION: connect_phase()
function void apb_collector::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(vif == null) begin
    if(!uvm_config_db#(apb_config)::get(this, "", "vif", vif))
      `uvm_error("[NOVIF]", {"virtual interface must be set for: ", get_full_name(), ".vif"})
  end
endfunction: connect_phase

//TASK: run_phase()
task apb_collector::run_phase(uvm_phase phase);
  @(posedge vif.preset_n)
  `uvm_info("[APB_COLLECTOR]", "Detect reset dropped", UVM_LOW)
  collect_transaction();
endtask: run_phase

//TASK: collect_transaction()
task apb_collector::collect_transaction();
  forever begin
    @(posedge vif.pclk iff (vif.preset_n));
    begin_tr(trans_collected, "[apb_collector]", "UVM DEBUG", "transaction inside collect_transaction task");
    trans_collected.paddr = vif.paddr;
    trans_collected.master = cfg.master_config.name;
    trans_collected.slave = cfg.get_slave_name(trans_collected.paddr);
    trans_collected.pwrite = vif.pwrite;
    trans_collected.pprot = vif.pprot;
    trans_collected.pstrb = vif.pstrb;
    
    @(posedge vif.pclk)
    if(trans_collected.pwrite == APB_READ)
      trans_collected.pdata = vif.prdata;
    else if(trans_collected.pwrite == APB_WRITE)
      trans_collected.pdata = vif.pwdata;
    -> addr_trans_event;
    
    @(posedge vif.pclk)
    if(trans_collected.pwrite == APB_READ) begin
      while(vif.pready == 0) 
        @(posedge vif.pclk);
      trans_collected.pdata = vif.prdata;
    end

    end_tr(trans_collected);
    item_collected_port.write(trans_collected);
    `uvm_info("[COLLECTOR]", $sformatf("Transfer collected: \n%s",
                              trans_collected.sprint()), UVM_MEDIUM);
    num_transactions++;
  end
endtask: collect_transaction

//TASK: peek() - collector::monitor
task apb_collector::peek(output apb_transaction trans);
  @addr_trans_event;
  trans = trans_collected;
endtask: peek

function apb_collector::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("[REPORT_APB_COLLECTOR]", $sformatf("apb_collector collects %0d transactions", num_transactions), UVM_LOW)
endfunction: report_phase

