/*******************************************************************************
  FILE : apb_slave_driver.sv
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
  FILE : apb_slave_driver.sv
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     18.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_slave_driver extends uvm_driver #(apb_transaction);
    //Virtual interface
    virtual apb_if    vif;

    //UVM Utilities & Automation macros => provide virtual methods: get_type_name, create
    `uvm_component_utils(apb_slave_driver)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Class methods
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task get_and_drive();
    extern virtual protected task reset();
    extern virtual protected task respond(apb_transaction resp);
endclass: apb_slave_driver

virtual function void apb_slave_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif);
        `uvm_error("[NOVIF]", {"virtual interface must be set for: ", get_full_name(), ".vif"})
endfunction: connect_phase

virtual task apb_slave_driver::run_phase(uvm_phase phase);
    super.connect_phase(phase);
    reset();
    get_and_drive();
endtask: run_phase

virtual protected task apb_slave_driver::get_and_drive();
    @(negedge vif.preset_n)
    `uvm_info("[APB_MASTER_DRIVER]", "get_and_drive: Reset dropped", UVM_MEDIUM) 
    forever begin
        fork
            begin
                @(negedge vif.preset_n)
                //`uvm_info("[APB_MASTER_DRIVER]", "get_and_drive: Reset dropped", UVM_MEDIUM) 
                reset();
            end

            begin
                forever begin
                    seq_item_port.get_next_item(req);
                    get_and_drive(req);
                    seq_item_port.item_done();
                end
            end
        join_any
        disable fork;
        //End the Transfer(Incase: transfer has not completed -> reset) & Reset Clean up
        //if(req.is_active()) end_tr(req); 
    end
endtask: get_and_drive

virtual protected task apb_slave_driver::reset();
    wait(!vif.preset_n);
    `uvm_info("[APB_SLAVE_DRIVER]", "[Reset...]", UVM_MEDIUM) 
    vif.prdata  <= 'z;
    vif.pready  <= 0;
    vif.pslverr <= 0;
endtask: reset

virtual protected task apb_slave_driver::respond(apb_transaction resp);
    //Debug
    begin
        vif.pready <= 1;
        if((resp.pready == 0) && (trans.pready_delay > 0)) begin
            resp.pready <= 0;
            repeat(trans.pready_delay) @(posedge vif.pclk);
        end
        vif.pready <= 1;
        vif.pslverr <= resp.pslverr;
        if(resp.pwrite == APB_READ) vif.prdata <= resp.data;
        @(posedge vif.pclk)
            vif.prdata <= 'z;
    end
endtask: respond
