/*******************************************************************************
  FILE : apb_pkg.sv"
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
  FILE : apb_pkg.sv"
*******************************************************************************/
//   Modifications copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     24.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

package apb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "./uvmlib/apb_types.sv"
    //`include "./uvmlib/apb_if.sv"
    `include "./uvmlib/apb_config.sv"
    `include "./uvmlib/apb_transaction.sv"
    
    `include "./uvmlib/apb_collector.sv"
    `include "./uvmlib/apb_monitor.sv"
    
    `include "./uvmlib/apb_master_driver.sv"
    `include "./uvmlib/apb_master_sequencer.sv"
    `include "./uvmlib/apb_master_agent.sv"
    
    `include "./uvmlib/apb_slave_driver.sv"
    `include "./uvmlib/apb_slave_sequencer.sv"
    `include "./uvmlib/apb_slave_agent.sv"

    `include "./uvmlib/apb_master_sequence_lib.sv"
    `include "./uvmlib/apb_slave_sequence_lib.sv"
    
    `include "./apb_env.sv"
endpackage: apb_pkg
