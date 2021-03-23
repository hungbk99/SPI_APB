/*******************************************************************************
  FILE : apb_slave_agent.sv
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
  FILE : apb_slave_agent.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     22.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_slave_agent extends uvm_agent;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  virtual apb_if vif;

  //Pointer to configuration class
  apb_slave_config  cfg;

  //Agent component
  collector           collector;
  monitor             monitor;
  apb_slave_sequencer sequencer;
  apb_slave_driver    sequencer;

  //Utilities & automation macros
  `uvm_component_utils_begin(apb_slave_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end

  //Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new  
  
  //Class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass: apb_master_agent

//FUNCTION: build_phase()
function apb_master_agent::build_phase(uvm_phase phase);
  if(cfg == null) begin
    if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg);
      `uvm_warning("[NOCONFIG]", {"apb_config is not set for: ", get_full_name(), "[using default config]"})
  end

  monitor = apb_monitor::type_id::create("monitor", this);
  collector = apb_collector::type_id::create("collector", this);
  if(is_active == UVM_ACTIVE) begin
    sequencer = apb_slave_sequencer::type_id::create("sequencer", this);
    driver = apb_slave_driver::type_id::create("driver", this);
  end
endfunction: build_phase

//FUNCTION: connect_phase()
function apb_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  monitor.item_collected_port.connect(collector.item_collected_export); //write()
  collector.addr_trans_port.connect(monitor.addr_trans_export); //peek()
  if(is_active == UVM_ACTIVE) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
endfunction: connect_phase
