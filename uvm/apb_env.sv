/*******************************************************************************
  FILE : apb_env.sv
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
  FILE : apb_env.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     24.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_env extends uvm_env;
    //Virtual Interface Set: Masters/Slaves use the same interface
    virtual apb_if    vif;

    //Environment Configuration Object
    apb_config        cfg;

    //Control Properties: 
    //    Check    - Interface
    //    Coverage - Monitor   
    bit check_enable = 1;
    bit coverage_enable = 1;

    //Components
    apb_monitor       bus_monitor;
    apb_collector     bus_collector;
    apb_master_agent  master;
    apb_slave_agent   slaves[];

    //Utilities & Automaction Macros
    `uvm_component_utils_begin(apb_env)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
        `uvm_field_int(check_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end 

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //Class methods
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void update_config(apb_config cfg);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task update_vif_control();
endclass: apb_env

function void apb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(cfg == null) begin
        if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info("[NO_CONFIG]", {"Using default apb_config", get_full_name()}, UVM_MEDIUM)
            $cast(cfg, factory.create_object_by_name("default_apb_config", "cfg"));
        end
    end
    //Set the master config
    uvm_config_object::set(this, "*", "cfg", cfg);
    //Set the slave configs
    foreach(cfg.slave_configs[i]) begin
        string slave_name;
        slave_name = $sformatf("slaves[%0d]", i);
        uvm_config_object::set(this, slave_name, "cfg.slave_config", cfg.slave_configs[i]);
    end
    
    bus_monitor = apb_monitor::type_id::create("bus_monitor", this);
    bus_collector = apb_collector::type_id::create("bus_collector", this);
    master = apb_master_agent::type_id::create("master", this);
    slaves = new[cfg.slave_configs.size()];
    foreach(slaves[i]) begin
        slaves[i] = apb_slave_agent::tye_id::create($sformatf("slaves[%0d]", i), this);
    end

endfunction: build_phase

function void apb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(vif == null) begin
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) 
            `uvm_info("[NOVIF]", "virtual interface is not set for: ", get_full_name(), ".vif"})
    end
    
    bus_collector.item_collected_port.connect(bus_monitor.coll_mon_port);
    bus_monitor.addr_trans_port.connect(bus_collector.addr_trans_export);

    //Set Verbosity Level
    master.mobitor.set_report_verbosity_level(UVM_NONE);
    master.collector.set_report_verbosity_level(UVM_NONE);
    
    foreach(slaves[i]) begin
        slaves[i].monitor.set_report_verbosity_level(UVM_NONE);
        slaves[i].collector.set_report_verbosity_level(UVM_NONE);
        if(slaves[i].is_active == UVM_ACTIVE)
            slaves[i].sequencer.addr_trans_port.connect(bus_monitor.addr_trans_export);
    end
endfunction: connect_phase

function void apb_env::start_of_simulation_phase(uvm_phase phase);
    set_report_id_action_hier("[NOCONFIG]", UVM_DISPLAY);
    set_report_id_action_hier("[NOVIF]", UVM_DISPLAY);
    check_config_usage();
endfunction: start_of_simulation_phase

function void apb_env::update_config(apb_config cfg);
    bus_monitor.cfg = cfg;
    bus_collector.cfg = cfg;
    master.update_config(cfg);
    foreach(slaves[i]) 
        slaves[i].updata_config(cfg);
endfunction: update_config

function void apb_env::update_vif_control();
    forever begin
        vif.check_enable = check_enable;
        vif.coverage_enable = coverage_enable;
    end
endfunction: update_vif_control

task apb_env::run_phase(uvm_phase phase);
    fork
        update_vif_control();
    join
endtask: run_phase    
