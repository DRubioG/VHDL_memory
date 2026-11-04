nvc -a ../src/SDPRAM.vhd

nvc -a SDPRAM_tb.vhd

nvc -e SDPRAM_tb

nvc -r SDPRAM_tb --stop-time=180us --wave=SDPRAM.vcd  --dump-arrays