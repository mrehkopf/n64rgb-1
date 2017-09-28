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
create_clock -name {nCLK2} -period 240.000 -waveform { 0.000 120.000 } [get_registers {n64igr:igr|nCLK2}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {nCLK2}] -rise_to [get_clocks {nCLK2}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK2}] -fall_to [get_clocks {nCLK2}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK2}] -rise_to [get_clocks {nCLK}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nCLK2}] -fall_to [get_clocks {nCLK}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nCLK2}] -rise_to [get_clocks {nCLK2}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK2}] -fall_to [get_clocks {nCLK2}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK2}] -rise_to [get_clocks {nCLK}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nCLK2}] -fall_to [get_clocks {nCLK}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -rise_to [get_clocks {nCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {nCLK}] -fall_to [get_clocks {nCLK}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



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

