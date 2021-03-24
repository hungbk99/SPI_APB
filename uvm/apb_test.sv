/*******************************************************************************
  FILE : apb_test.sv
*******************************************************************************/
//   Copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     24.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

class apb_test extends uvm_test;
    `uvm_component_utils(apb_test)

    apb_env                            apb_env0;

    write_seq                          master_seq0;
    read_seq                           master_seq1;
    read_after_write_seq               master_seq2;
    multiple_read_after_write_seq      master_seq3;
    
    simple_response_seq                slave_seq0;
    mem_response_seq                   slave_seq1;    

    function new(string name = "apb_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        master_seq0 = write_seq::type_id::create("master_seq0", this);
        slave_seq0 = simple_response_seq::type_id::create("slave_seq0", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        fork
            begin
                master_seq0.start(apb_env0.master.sequencer);
            end

            begin
                #100
                $display("==========================");
                 `uvm_warning("[APB_TEST]" "[TIME OUT]");
                $display("==========================");
            end
        join_any
        disable fork;
        phase.drop_objection(this);
    endtaskL run_phase
endclass: apb_test
