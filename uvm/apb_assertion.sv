always @(posedge pclk) begin
    //Property: PADDR must not be X or Z when PSEL is asserted
    paddr_unknown: assert 
                    (!((psel == 0) || !$isunknown(paddr) || (check_enable == 0)))
                      $error("PADDR went to X or Z when PSEL is asserted");
    
    //Property: PWRITE must not be X or Z when PSEL is asserted
    pwrite_unknown: assert 

                    (!((psel == 0) || !$isunknown(pwrite) || (check_enable == 0)))
                      $error("PWRITE went to X or Z when PSEL is asserted");
    
    //Property: PWDATA must not be X or Z during a write transaction
    pwdata_unknown: assert 

                    (!((psel == 0) || (pwrite == 0) || !$isunknown(pwdata) || (check_enable == 0)))
                      $error("PWDATA went to X or Z during a write transaction");
    
    //Property: PRDATA must not be X or Z during a read transaction
    prdata_unknown: assert 

                    (!((psel == 0) || (pready == 0) || (pwrite == 1) || !$isunknown(prdata) || (check_enable == 0)))
                      $error("PRDATA went to X or Z during a read transaction");
    
    //Property: PENABLE must not be X or Z
    penable_unknown: assert 

                     (($isunknown(penable)) && (check_enable == 1))
                       $error("PENABLE went to X or Z");
    
    //Property: PSEL must not be X or Z
    psel_unknown: assert 

                    ($isunknown(psel) && (check_enable == 1))
                      $error("PSEL went to X or Z");
    
    //Property: PSLVERR must not be X or Z
    pslverr_unknow: assert 

                    (!((psel == 0) || (pready == 0) || !$isunknown(pslverr)))
                      $error("PSLVERR went to X or Z");
end 
