/*******************************************************************************
  FILE : apb_config.sv
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
  FILE : apb_config.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     23.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------
class apb_slave_config extends uvm_object;
  string name;
  rand uvm_active_passive_enum is_active = UVM_ACTIVE;
  rand int start_address;
  rand int end_address;
  rand int psel_index;

  constraint c_addr { start_address < end_address; }
  constraint c_psel { psel_index inside {[0:15]}; }

  `uvm_object_utils_begin(apb_slave_config)
    `uvm_field_string(name, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_field_int(start_address, UVM_DEFAULT)
    `uvm_field_int(end_address, UVM_DEFAULT)
    `uvm_field_int(psel_index, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "apb_slave_config");
    super.new(name);
  endfunction

  function bit check_address_range(int unsigned addr);
    return ((start_address <= addr) && (end_address >= addr));
  endfunction
endclass: apb_slave_config

class apb_master_config extends uvm_object;
  string name;
  rand uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  `uvm_object_utils_begin(apb_master_config)
    `uvm_field_string(name, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "apb_master_config");
    super.new(name);
  endfunction

endclass: apb_master_config

class apb_config extends uvm_object;
  apb_master_config master_config;
  apb_slave_config  slave_configs[$];
  int num_slaves;

  `uvm_object_utils_begin(apb_config)
    `uvm_field_object(master_config, UVM_DEFAULT)
    `uvm_field_queue_object(slave_configs, UVM_DEFAULT)
    `uvm_field_int(num_slaves, UVM_DEFAULT)
  `uvm_object_utils_end

  //Class methods
  extern virtual function void add_slave(string name, int start_address, int end_address,
                                          int psel_index, uvm_active_passive_enum is_active = UVM_ACTIVE);
  extern virtual function void add_master(string name, uvm_active_passive_enum is_active = UVM_ACTIVE);
  extern virtual function int get_slave_psel(int addr);
  extern virtual function string get_slave_name(int addr);
endclass: apb_config

function void apb_config::add_slave(string name, int start_address, int end_address, 
                        int psel_index, uvm_active_passive_enum is_active = UVM_ACIVE);
  apb_slave_config tmp;
  num_slaves++;
  tmp = apb_slave_config::type_id::create("slave_config", this);  //debug
  tmp.name = name;
  tmp.start_address = start_address;
  tmp.end_address = end_address;
  tmp.psel_index = psel_index;
  tmp.is_active = is_active;

  slave_configs.push_back(tmp);
endfunction: add_slave

function int apb_config::add_master(string name, uvm_active_passive_enum is_active = UVM_ACTIVE);
  master_config = apb_master_config::type_id::create("master_config", this);
  master_config.name = name;
  master_config.is_active = is_active;
endfunction: add_master

function int apb_config::get_slave_psel(int addr);
  for(int i = 0; i < slave_configs.size(); i++) begin
    if(slave_configs[i].check_address_range(addr)) begin
      return slave_configs[i].psel_index;
    end
  end
endfunction: get_slave_psel

function string apb_config::get_slave_name(int addr);
  for(int i = 0; i < slave_configs.size(); i++) begin
    if(slave_configs[i].check_address_range(addr)) begin
      return slave_configs[i].name;
    end
  end
endfunction: get_slave_name

//=================================================================
//DEFAULT APB Configuration - 1 master, 2 slaves
//=================================================================
class default_apb_config extends apb_config;
  `uvm_object_utils(default_apb_config)

  function new(string name = "default_apb_config");
    super.new(name);
    add_slave("slave0", 32'h0000_0000, 32'h1FFF_FFFF, 0, UVM_ACTIVE);
    add_slave("slave1", 32'h2000_0000, 32'h3FFF_FFFF, 1, UVM_ACTIVE);
    add_master("master", UVM_ACTIVE);
  endfunction
endclass: default_apb_config
