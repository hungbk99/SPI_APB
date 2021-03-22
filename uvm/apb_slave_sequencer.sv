//=================================================================
// Class Description: Slave sequencer for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     22.03.2021  hungbk99  First Creation  
//=================================================================

class apb_slave_sequencer extends uvm_sequencer #(apb_transaction);
  //Peek port connect to collector
  uvm_blocking_peek_port#(apb_transaction) addr_trans_port;
  
  //Pointer to configuration class
  apb_config cfg;

  //Utilities & automatic macros
  `uvm_component_utils_begin(apb_slave_sequencer)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end

  //Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    addr_trans_port = new("addr_trans_port", this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

endclass: apb_slave_sequencer



