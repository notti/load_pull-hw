REM   ____  ____
REM  /   /\/   /
REM /___/  \  /
REM \   \   \/     Vendor: Xilinx
REM  \   \         Version : 1.7
REM  /   /         Application : GTX Transceiver Wizard
REM /___/   /\     Filename : simulate_isim.bat
REM \   \  /  \
REM  \___\/\___\
REM
REM
REM Script SIMULATE_ISIM.BAT
REM Generated by Xilinx GTX Transceiver Wizard


REM ***************************** Beginning of Script ***************************
        

REM Create and map work directory
mkdir work


REM MGT Wrapper
vhpcomp -work work  ..\..\..\gtx_tile.vhd
vhpcomp -work work  ..\..\..\gtx.vhd




REM Example Design modules
vhpcomp -work work  ..\..\example_design\frame_gen.vhd
vhpcomp -work work  ..\..\example_design\frame_check.vhd
vhpcomp -work work  ..\..\example_design\gtx_top.vhd
vhpcomp -work work  ..\demo_tb.vhd

REM Other modules
vhpcomp -work work ..\sim_reset_mgt_model.vhd

REM Load Design
fuse work.DEMO_TB -L unisim -L secureip -o demo_tb.exe

.\demo_tb.exe gui -tclbatch wave_isim.tcl -wdb wave_isim  

