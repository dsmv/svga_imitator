
# create svga_dpi.h from tb.sv

source /tools/Xilinx/Vivado/2023.2/settings64.sh 

xvlog -sv tb.sv

xelab   tb --dpiheader svga_dpi.h