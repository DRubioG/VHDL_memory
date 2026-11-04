nvc -a ../src/SPRAM.vhd

nvc -a SPRAM_tb.vhd

nvc -e SRAM_tb

nvc -r SRAM_tb --stop-time=180us --wave=SRAM_tb.vcd  --dump-arrays