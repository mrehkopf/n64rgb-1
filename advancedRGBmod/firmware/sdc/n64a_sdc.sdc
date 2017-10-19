## Generated SDC file "n64advanced.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.1 Build 598 06/07/2017 SJ Lite Edition"

## DATE    "Tue Jul 04 21:09:02 2017"

##
## DEVICE  "10M02SCE144C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {nCLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { nCLK }]
create_clock -name {SYS_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { SYS_CLK }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]} -source [get_pins {vid_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {nCLK} [get_pins {vid_pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]} -source [get_pins {igr|sys_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -divide_by 25 -master_clock {SYS_CLK} [get_pins {igr|sys_pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]} -source [get_pins {igr|sys_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 3125 -master_clock {SYS_CLK} [get_pins {igr|sys_pll|altpll_component|auto_generated|pll1|clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll_0:vid_pll|altpll:altpll_component|altpll_0_altpll1:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {nCLK}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {nCLK}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {n64_igr:igr|altpll_1:sys_pll|altpll:altpll_component|altpll_1_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

