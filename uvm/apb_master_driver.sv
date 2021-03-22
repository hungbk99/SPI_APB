//=================================================================
// Class Description: Master Driver for APB UVC
// Project Name:	    renas mcu
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     18.03.2021  hungbk99  First Creation  
//=================================================================

class apb_master_driver extends uvm_driver #(apb_transaction);
    //Virtual interface
    virtual apb_if    vif;
    //Pointer to configuration class
    apb_config        cfg;        

    //UVM Utilities & automation macros => provide virtual methods: get_type_name, create
    `uvm_component_utils_begin(apb_master_driver)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Class methods
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task get_and_drive();
    extern virtual protected task reset();
    extern virtual protected task drive_transfer(apb_transaction trans);
    extern virtual protected task drive_address_phase(apb_transaction trans);
    extern virtual protected task drive_data_phase(apb_transaction trans);
endclass: apb_master_driver

virtual function void apb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(cfg == null)
        if(!uvm_config_db#(apb_transaction)::get(this, "", "cfg", cfg))
            `uvm_error("[NOCONFIG]", {"apb_config has not been set for:", get_full_name()})
endfunction: build_phase

virtual function void apb_master_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(vif == null) begin
        if(!uvm_con fig_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_error("[NOVIF]", {"virtual interface must be set for: ", get_full_name(), ".vif"})
    end
endfunction: connect_phase

virtual task apb_master_driver::run_phase(uvm_phase phase);
    reset();
    get_and_drive();
endtask

virtual protected task apb_master_driver::get_and_drive();
    @(negedge vif.preset)
    `uvm_info("[APB_MASTER_DRIVER]", "get_and_drive: Reset dropped", UVM_MEDIUM) 
    forever begin
        fork
            begin
                @(negedge vif.preset)
                //`uvm_info("[APB_MASTER_DRIVER]", "get_and_drive: Reset dropped", UVM_MEDIUM) 
                reset();
            end

            begin
                forever begin
                    @(posedge vif.pclk iff (vif.preset))
                    seq_item_port.get_next_item(req);
                    driver_transfer(req);
                    seq_item_port.item_done();
                end
            end
        join_any
        disable fork;
        //End the Transfer(Incase: transfer has not completed -> reset) & Reset Clean up
        if(req.is_active()) end_tr(req); 
    end
endtask: get_and_drive

virtual protected task apb_master_driver::reset();
    wait(!vif.preset)
    `uvm_info("[APB_MASTER_DRIVER]", "[Reset....]", UVM_MEDIUM)
    vif.paddr     <= '0;
    vif.pwdata    <= '0; 
    vif.psel      <= '0;
    vif.penable   <= '0;
    vif.pwrite    <= '0;
    vif.pstrb     <= '0;
    vif.pprot     <= '0;
endtask: reset

virtual protected task apb_master_driver::drive_transfer(apb_transaction trans);
    begin_tr(trans, "[APB_MASTER_DRIVER]", "UVM_DEBUG", "Start driving transation");
    if(trans.transmit_delay > 0) begin
        repeat(trans.transmit_delay) @(posedge vif.pclk);
    end
    drive_address_phase(trans);
    drive_data_phase(trans);
    `uvm_info("[APB_MASTER_DRIVER]", $sformatf("Finish driving transaction"))
    end_tr(trans);
endtask: drive_transfer

virtual protected task apb_master_driver::drive_address_phase(apb_transaction trans);
    int slave_index;
    slave_index = cfg.get_slave_psel(trans.paddr);
    vif.paddr   <= trans.paddr;
    vif.psel    <= (1<<slave_index);
    vif.penable <= 0;
    vif.pwrite  <= trans.pwrite;
    vif.pstrb   <= trans.pstrb;
    vif.pprot   <= trans.pprot;
    if(trans.pwrite == APB_WRITE)
        vif.pwdata <= trans.pdata;
endtask: drive_address_phase

virtual protected task apb_master_driver::drive_data_phase(apb_transaction trans);
    vif.penable <= 1;
    @(posedge vif.pclk iff (vif.pready));
    if(trans.pwrite == APB_READ) begin
        trans.data = vif.prdata;
    trans.pslverr = vif.pslverr;
    @(posedge vif.pclk);
    vif.penable <= 0;
    vif.psel <= 0;
endtask: drive_data_phase

