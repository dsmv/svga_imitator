cp ../../litex/build/litex_soc_m1/gateware/*.init .
xvlog -sv --incr --relax  -f systemverilog.f  -d COVERAGE -i ../../../../common
xvlog     --incr --relax  -f verilog.f  
