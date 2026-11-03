nvc -a ../src/FIFO_SYNC.vhd

nvc -a FIFO_SYNC_tb.vhd

nvc -e FIFO_SYNC_tb

nvc -r FIFO_SYNC_tb --stop-time=980us --wave=FIFO_SYNC_tb.vcd --dump-arrays 