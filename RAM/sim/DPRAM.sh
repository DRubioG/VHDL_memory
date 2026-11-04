nvc -a ../src/DPRAM.vhd

nvc -a DPRAM_tb.vhd

nvc -e DPRAM_tb

nvc -r DPRAM_tb --stop-time=180us --wave=DPRAM.vcd  --dump-arrays