nvc -a ../src/FIFO_xilinx.vhd

nvc -a FIFO_ASYNC_tb.vhd

nvc -e FIFO_Xilinx_ASYNC_tb

nvc -r FIFO_Xilinx_ASYNC_tb --stop-time=980us --wave=FIFO_Xilinx_ASYNC_tb.vcd --dump-arrays 