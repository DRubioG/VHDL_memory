nvc -a ../src/DPROM.vhd

nvc -a DPROM_tb.vhd

nvc -e DPROM_tb

nvc -r DPROM_tb --stop-time=180us --wave=DPROM.vcd  --dump-arrays