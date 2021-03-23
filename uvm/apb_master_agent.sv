//=================================================================
// Class Description: Agent for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     22.03.2021  hungbk99  First Creation  
//=================================================================

class apb_master_agent extends uvm_agent;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  //Pointer to configuration class
  apb_config cfg;

  //Agent components
  apb_collector         collector;
  apb_monitor           monitor;
  apb_master_sequencer  sequencer;
  apb_master_driver     driver;

  //Utilities & Automation macros
  `uvm_component_utils_begin(apb_master_agent)
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
  extern virtual function void update_config(apb_config cfg);
endclass: apb_master_agent

//FUNCTION: build_phase()
function apb_master_agent::build_phase(uvm_phase phase);
  if(cfg == null) begin
    if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg);
      `uvm_warning("[NOCONFIG]", {"apb_config is not set for: ", get_full_name(), "[using default config]"})
  end
  
  collector = apb_collector::type_id::create("collector", this);
  monitor = apb_monitor::type_id::create("monitor", this);
  if(is_active == UVM_ACTIVE) begin
    sequencer = apb_master_sequencer::type_id::create("sequencer", this);
    driver = apb_master_driver::type_id::create("driver", this);
  end
endfunction: build_phase

//FUNCTION: connect_phase()
function apb_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  collector.item_collected_port.connect(monitor.coll_mon_export); //write()
  monitor.addr_trans_port.connect(collector.addr_trans_export); //peek()
  if(is_active == UVM_ACTIVE) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);  //get_next_item() & item_done()
  end
endfunction: connect_phase

//FUNCTION: update_config()
function void apb_master_agent::update_config();
  if(is_active == UVM_ACTIVE) begin
    sequencer.cfg = cfg;
    driver.cfg = cfg;
  end
endfunction: update_config
