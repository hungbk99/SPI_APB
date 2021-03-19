//=================================================================
// Class Description: Master Sequencer for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     18.03.2021  hungbk99  First Creation  
//=================================================================

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
