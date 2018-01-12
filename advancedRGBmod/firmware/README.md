## Important Note

**At the momement just the FPGAs with 10kLEs are supported!**


# How to ...


## ... Build the HDL Firmware

- Download Quartus Prime
- Open Quartus Project File (\*.qpf) with Quartus Prime
- Select your FPGA in list of revision
- Open system.qsys with Platform Designer (_Tools_ -> _Platform Designer_; formerly _QSYS_)
  - click _Generate HDL..._ and then on _Generate_ in the popped up window code
  - click on _Finish_ to close Platform Designer
- Click in _Compile Design_ to build your firmware
  - output will be generated in _project\_folder_/output_files/_revision_/
  - Update needs an USB Blaster
    - Use the *.sof file to temporarely run your firmware on the FPGA (lasts one power cycle)
	- Use the *.pof file for program flash memory off the board using AS
	- Use the *.jic file to get the firmware into flash using the FPGA  
	(File needs to be generated using Convert Programming File tool (_File_ -> _Convert Programming Files..._; conversion setup in main folder))


## ... Build the Software for the NIOS II Core

- All tools needed comes with the Quartus Prime installation


### Initial Setup of Eclipse Workspace

- open Eclipse with _Tools_->_NIOS II Build Tools for Eclipse_
- select a Workspace, preferably in subfolder _software_
- Create Board Support Package project
  - click on _File_ -> _New... -> _NIOS II Board Support Package_
  - setup:
    - _Project name:_ **controller\_bsp**
	- _SOPC Information File name:_ **_project\_folder_/system.sopcinfo**  
	  (located in _project\_folder_/)
	- Location: **_project\_folder_/software/controller\_bsp**  
	  (should be default location)
  - click on _Finish_ to generate project  
    the project should now appear in your Project Explorer
- Create Application Project:
  - click on _File_->_New... -> _NIOS II Application_
  - setup:
    - _Project name:_ **controller\_app**
	- _BSP location:_ **_project\_folder_/software/controller\_bsp**  
	  (can be selected from project list)
	- Location: **_project\_folder_/software/controller\_app**  
	  (should be default location)
  - integrate sources into Makefile
    - mark all source-files 
	 (the should now appear in Project Explorer)
	- and right-click on them and select _Add to NIOS II Build_


### Build BSP

Everytime the HDL code has been compiled or the NIOS II core has been adapted, the BSP has to be generated.
- right click on the bsp project
- For the **first time** select _NIOS II_ -> _BSP Editor..._
  - check **_enable\_small\_c\_library_** and **_enable\_reduced\_device\_drivers_**
  - click on _Generate_ and _Exit_ 
- Every other time it is sufficient to select _NIOS II_ -> _Generate BSP_


### Build Software

Software build needs a current version of the BSP. If the BSP is outdated, the compiler will tell you this.

- right click on the application project
  - For the **first time** open _Properties_
    - select _NIOS II Application Properties_
	- change _Optimization level:_ to **_Size_**
	- _Apply_ and close (_OK_) the window
	- right click again on the application project
  - select _Build Project_ to build the *.elf file
    - the program can be downloaded to the NIOS II core during runtime
  - to build the **initiation hex file for the NIOS II** core select _Make Targets_ -> _Build..._
    - select **_mem\_init\_generate_** and click on _Build_
	- file _project\_folder_/software/controller\_app/mem\_init/system\_onchip\_memory2\_0.hex will be generated/updated


### Include Program to HDL

If you have to compile the HDL code make sure that the _project\_folder_/software/controller\_app/mem\_init/system\_onchip\_memory2\_0.hex exists!

If you still have a compiled version of your HDL code and just have updated the software click on _Processing_ -> _Update Memory Initialization File_. Afterwards just run the _Assembler (Generate programming files)_ to get your new files (\*.jic file has to be generated using conversion tool; see section  "How to Build the HDL Firmware")
