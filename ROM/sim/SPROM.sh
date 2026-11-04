nvc -a ../src/SPROM.vhd

nvc -a SPROM_tb.vhd

nvc -e SPROM_tb

nvc -r SPROM_tb --stop-time=180us --wave=SPROM.vcd  --dump-arrays