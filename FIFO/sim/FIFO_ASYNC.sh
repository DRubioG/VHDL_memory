nvc -a ../src/FIFO_ASYNC.vhd

nvc -a FIFO_ASYNC_tb.vhd

nvc -e FIFO_ASYNC_tb

nvc -r FIFO_ASYNC_tb --stop-time=980us --wave=FIFO_ASYNC_tb.vcd --dump-arrays 