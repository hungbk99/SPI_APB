/*******************************************************************************
  FILE : apb_top.sv
*******************************************************************************/
//   Copyright (C) 2021 Le Quang Hung
//   All Rights Reserved
//   Ho Chi Minh University of Technology
//   Email: quanghungbk1999@gmail.com
//   Version  Date        Author    Description
//   v0.0     24.03.2021  hungbk99  First Creation  
//----------------------------------------------------------------------

`include "uvmlib/apb_if.sv"
`include "uvmlib/apb_pkg.sv"

module apb_top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_pkg::*;
    `include "apb_test.sv"

    logic pclk;
    logic preset_n;

    apb_if    apb_if0(pclk, preset_n);

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "*.apb_env0*", "vif", apb_if0);
        run_test("apb_test");
    end

    initial begin
        preset_n <= 1'b0;
        pclk <= 1'b0;
    end

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars();
        $vcdpluson();
    end

    always #5 pclk = ~pclk;
endmodule
