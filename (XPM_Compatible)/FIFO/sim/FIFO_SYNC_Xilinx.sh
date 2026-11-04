nvc -a ../src/FIFO_xilinx.vhd

nvc -a FIFO_SYNC_Xilinx_tb.vhd

nvc -e FIFO_SYNC_Xilinx_tb

nvc -r FIFO_SYNC_Xilinx_tb --stop-time=980us --wave=FIFO_SYNC_Xilinx_tb.vcd --dump-arrays 