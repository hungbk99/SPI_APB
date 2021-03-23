//Property: PADDR must not be X or Z when PSEL is asserted
paddr_unknown: assert property(
                @(posedge pclk)
                disable iff(!check_enable)    
                (psel == 0 or !$isunknown(paddr))
                else $error("PADDR went to X or Z when PSEL is asserted");
);

//Property: PWRITE must not be X or Z when PSEL is asserted
pwrite_unknown: assert property(
                @(posedge pclk)
                disable iff(!check_enable)
                (psel == 0 or !$isunknown(pwrite))
                else $error("PWRITE went to X or Z when PSEL is asserted");
);

//Property: PWDATA must not be X or Z during a write transaction
pwdata_unknown: assert property(
                @(posedge pclk)
                disable iff(!check_enable)
                (psel == 0 or pwrite == 0 or !$isunknown(pwdata))
                else $error("PWDATA went to X or Z during a write transaction");
);

//Property: PRDATA must not be X or Z during a read transaction
prdata_unknown: assert property(
                @(posedge pclk)
                disable iff(!check_enable)
                (psel == 0 or pready == 0 or pwrite == 1 or !$isunknown(prdata))
                else $error("PRDATA went to X or Z during a read transaction");
);

//Property: PENABLE must not be X or Z
penable_unknown: assert property(
                 @(posedge pclk)
                 disable iff(!check_enable)
                 ($isunknown(penable))
                 else $error("PENABLE went to X or Z");
);

//Property: PSEL must not be X or Z
psel_unknown: assert property(
                @(posedge pclk) 
                disable iff(!check_enable)
                (!$isunknown(psel))
                else $error("PSEL went to X or Z");
);

//Property: PSLVERR must not be X or Z
pslverr_unknow: assert property(
                @(posedge pclk)
                disable iff(!check_enable)
                (psel == 0 or pready == 0 or !$isunknown(pslverr))
                else $error("PSLVERR went to X or Z);
); 
