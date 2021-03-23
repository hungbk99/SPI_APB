/*******************************************************************************
  FILE : apb_master_sequencer.sv
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
  FILE : apb_master_sequencer.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     18.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_master_sequencer extends uvm_sequencer #(apb_transaction);
    //Virtual interfacei -> if needed by any sequences
    virtual apb_if    vif;
    
    //Pointer to configuration unit of the agent
    apb_config        cfg; 

    //UVM Utilities & automation macros => provide virtual methods: get_type_name, create
    `uvm_component_utils_begin(apb_master_sequencer)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(cfg == null) begin
            if(!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg))
                `uvm_error("[NOCONFIG]", {"apb_config has not been set for:", get_full_name()})
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(vif == null) begin
            if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
                `uvm_error("[NOVIF]", {"virtual interface must be set for: ", get_full_name(), ".vif"})
        end
    endfunction: connect_phase
endclass: apb_master_sequencer 
