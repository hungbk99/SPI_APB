//=================================================================
// Class Description: Collector for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     18.03.2021  hungbk99  First Creation  
//=================================================================

class apb_collector extends uvm_component;
  //Virtual interface
  virtual apb_if  vif;
  //Pointer to configuration class
  apb_config      cfg;

  //Property: Indicate number of transactions
  int num_transactions = 0;

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
    `uvm_field_object(cfg, UVM_DEFAULT, UVM_REFERENCE)
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
  extern virtual task peek(output apb_transaction);
  extern virtual function void report_phase(uvm_phase phase);
endclass: apb_collector

function void apb_collector::build_phase(uvm_phase phase);
  super.build_phase(uvm_phase);
  if(cfg == null) begin
    if(!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg);
      `uvm_error("[NOCONFIG]", "apb_config not set for: ", get_full_name())
  end
endfunction: build_phase
