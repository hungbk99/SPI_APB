//=================================================================
// Class Description: Data items for APB UVC
// Project Name:	    renas mcu
// Copyright (C) Le Quang Hung 
// Ho Chi Minh University of Technology
// Email: 			quanghungbk1999@gmail.com  
// Version  Date        Author    Description
// v0.0     18.03.2021  hungbk99  First Creation  
//=================================================================

typedef enum bit {APB_READ, APB_WRITE} apb_direction_enum;
class apb_transaction extends uvm_sequence_item;
  rand bit [31:0]         paddr;
  rand bit [31:0]         pdata;
  rand bit [2:0]          pprot;
  rand bit [3:0]          pstrb;
  rand apb_direction_enum pwrite;

  //Control Fields
  rand int unsigned       transmit_delay;
    
  //Constraints
  constraint c_addr { paddr[1:0] == 2'b00; }

  //UVM utilities & automation macros for data items
  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(paddr, UVM_DEFAULT)
    `uvm_field_int(pwdata, UVM_DEFAULT)
    `uvm_field_int(pprot, UVM_DEFAULT)
    `uvm_field_int(pstrb, UVM_DEFAULT)
    `uvm_field_enum(apb_direction_enum, pwrite, UVM_DEFAULT)
  `uvm_object_utils_end

  //Constructor
  function new(string name = "apb_transaction");
    super.new(name);
  endfunction: new

  virtual task print_apb_seq();
    if(pwrite == APB_READ)
      `uvm_info("[APB_SEQ]", $sformatf("[READ TRANSFER]::prdata = %0h, paddr = %0h", 
                                        pdata, paddr);
    else
      `uvm_info("[APB_SEQ]", $sformatf("[WRITE TRANSFER]::pwdata = %0h, paddr = %0h", 
                                        pdata, paddr);
  endtask: print_apb_seq
endfunction: apb_transaction
