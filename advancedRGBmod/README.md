# Advanced N64 RGB Digital-to-Analog Mod

This folder contains all you need for a complete DIY RGB mod.

Please don't ask me for selling a modding. I either sell some prototypes on some forums marketplaces (which is very unlikely) or I don't have any of the boards.
This is a complete DIY modding project. So everybody is on his own here.

**WARNING:** This is an advanced DIY project if you do everything on your own. You need decent soldering skills. The FPGA has 0.5mm fine pitch with 144pins and one exposed pad below the IC, which has to be soldered to the PCB. Next to it the video DAC has also 0.5mm pin pitch on the board there are some SMD1206 resistor and ferrit bead arrays.

## Features

- Supporting for different FPGAs [1] on a common PCB design:
  * (Cyclone IV EP4CE6E22)
  * Cyclone IV EP4CE10E22
  * (Cyclone 10 LP 10CL006YE144)
  * Cyclone 10 LP 10CL010YE144
- Video DAC ADV7125 (or ADV7123)
- Detection of 240p/288p vs. 480i/576i together with detection of NTSC vs. PAL mode
- Heuristic for de-blur function [2], De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- IGR features:
  * reset the console with the controller
  * full control on de-blur and 15bit mode with the controller
- Advanced features:
  * output of RGsB or YPBPr on demand
  * linedoubling of 240p/288p video to 480p/576p [3]
  * selectable scanline strength: 0% (i.e. sl off), 25%, 50% and 100% [4]
  * optional bob de-interlace of 480i/576i to 480p/576p [3]
  * VGA output [5]


The following shortly describes the main features of the firmware and how to use / control them.

#### Notes
##### [1]
For now, all FPGAs seems to be fine. However, it might be the case that the 6k LEs FPGAs (EP4CE6E22 and 10CL006YE144) are to small for an OSD menu implementation due to the small amount of block RAM.

##### [2]
Heuristic for de-blur function highly depends on the image content. So it might be the case that de-blur is switched on and off rapidly even on small content changes. In any case you can override the heuristic by forcing de-blur on or off.  
If you observe something like that or where do you think that de-blur is not correctly guessed, please take a note (PAL / NTSC N64, game, ROM, situation), where I can check that and can try to further improve the heuristic algorithm. Send me your observation vie email or open an issue here on GitHub.

##### [3]
can be switched off

##### [4]
no scanlines are available in this mode

##### [5]
Not available if the filter adddon is used as HSYNC and VSYNC are shared outputs with F1 and F2 (filter selection)

### In-Game Routines (IGR)

Three functunalities are implemented: toggle de-blur feature / override heuristic for de-blur and toggle the 15bit mode (see above) as well as resetting the console.

The button combination are as follows:

- reset the console: Z + Start + R + A + B
- (de)activate de-blur / override heuristic for de-blur: (see description above)
- (de)activate 15bit mode: (see description above)

_Modifiying the IGR Button Combinations_:  
It's difficult to make everybody happy with it. Third party controllers, which differ from the original ones by design, make it even more difficult. So it is possible to generate your own firmware with **your own** preferred **button combinations** implemented. Please refere to the document **IGR.README.md** located in the top folder of this repository for further information.

_Final remark on IGR_:  
However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incomming issue report to furhter improve this feature :)


### De-Blur

De-blur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis, 007 Goldeneye, and some others use these pixel for additional information rather than for bluring effects. In other words this means that these games uses full horizontal resolution even in 240p/288p output mode. Hence, the picture looks more blurry in this case if de-blur feature is activated.

- **By default heuristic is activated on every power cycle and on every reset!** However, as the heuristic guess might be not reliable, the guess can be overriden.
- Press Z + Start + R + C-le to deactivate de-blur (overrides the guess)
- Press Z + Start + R + C-ri to activate de-blur (overrides the guess)

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_


### Heuristic for De-Blur

As noted above, the N64 typically outputs a 320pixel wide picture in 240p/288p. As the pixel clock does not change compared to 480i/576i there outputted pixel wide is 640.
On the one hand, most games outputs a 320pixel wide picture in 240p/288p and use the remaining pixels to introduce a blur. This can be removed by simply blank these interpolated pixels.
On the other hand, a minor number of games outputs a 'full' 640pixel wide picture also in 240p/288p. In this case blanking out the suspected interpolated pixels causes a blurry picture.

The heuristic algorithm estimates whether a game uses the first or the second method. Depending on the result de-blur is active or not. However, as the estimation could be wrong, the user has the opportunity to override the estimation. (see section de-blur) At the moment it is not implemented that the heuristic can be switched on once overridden except with a reset or a new power cycle.


### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) downto 15bits (5bit for each color). Some very few games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

- By default the 15bit mode is *off*! The default is set on each power cycle but not on a reset.
- to deactivate 15bit mode press Z + Start + R + C-up.
- to (re)activate 15bit mode press Z + Start + R + C-dw.

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_


### Low Pass Filtering of the Video Output

The video DAC does not use any filtering. In general, this is also not needed. If you need DAC post-filtering though (receiver has a ADC build without any pre-filtering), you can install the filter addon (also provided in this repository).

The filter addon is based on a THS7368, where the video channels with selectable filter are used. As the filter is selected over the same pins as HSYNC and VSYNC, the addon is not compatible to VGA.


## Firmware / Technical Information

Firmware programming file depends on the FPGA you use. Please keep that in mind and select the programming file you need..

### Jumpers

There are some jumpers spreaded over the PCB, namely _J1_, _J2_, _J3_, _J4_, _J5_ and _J6_. _J1 - J4_ have to parts, let's say _.1_ and _.2_, where _.1_ is marked with the _dot_ on the PCB.

#### J1 (Filter AddOn)
##### J1.1 
- opened: output HSYNC and VSYNC for possible VGA output
- closed: use filter addon

##### J1.2
- currently unused

#### J2 (RGB, RGsB, YPbPr)
##### J2.1
- opened: RGB output
- closed: RGsB output (sync on green)

##### J2.2
- opened: RGB / RGsB output
- closed: YPbPr output (beats J2.1)


#### J3 (Scanline)
##### J3.1/J3.2
- opened / opened: 0%
- opened / closed: 25%
- closed / opened: 50%
- closed / closed: 100%

#### J4 (Linemode)
##### J4.1
- opened: linedoubling of 240p/288p to 480p/576p
- closed: no-linedoubling (beats J4.2)

##### J4.2
- opened: no bob de-interlace of 480i/576i
- closed: bob de-interlace of 480i/576i to 480p/576p (J4.1 must be opened)

#### J5
_J5_ is the JTAG connector.

#### J6 (Power supply of analog outputs)
The analog part can be power with **either** 3.3V **or** 5V. If you want to power this part of the PCB with 3.3V, close J5 and leave pad . If you want to power this part with 5V, leave _J6_ opened and connect pad _5V_ to +5V power rail of the N64. **NEVER connect 5V and close J5.**

### How to build the project

- Use PCB files to order your own PCB or simply use the shared project(s) on OSHPark
- Source the components you need, e.g. from Mouser or Digikey
- Wait for everything to arrive
- Assemble your PCB
- Set all jumpers
- Flash the firmware to the serial flash device
  * You need a Altera USB Blaster
  * Use the JIC programming file if you want to program the serial flash over the FPGA or the SOF file if you have a AS programming adapter for the serial flash
  * The serial flash / board needs to be powered; so you may consider to install the PCB into your N64 first and then use the N64 for powering the board
  * If you want to build an adapter, you may take a look onto [my DIY adapter](https://oshpark.com/shared_projects/mEwjoesz) at [my profile on OSHPark](https://oshpark.com/profiles/borti4938)
- Install the modding board:
  * Installation is similar to the [installation of viletims board](http://etim.net.au/n64rgb/). The minor differences / extra pads are as follows:
    * decide on you own whether you want to use the analog part with 5V (connect 5V to the appropriate pad) or with 3.3V (short jumper _J6_). **Don't connect 5V and close J5.**
	* Pad *C*: currently unused. Leave it unconnected
    * Pad *Rst#*: connect this pad to the PIF-NUS pin 27
    * Pad *Ctrl*: connect this pin to the middle pin of the controller port you want to use for the IGR functions (controller port 1 is probably connected to PIF-NUS pin 16; check that before soldering a wire)
  * You have to be aware of the pinout of your video-encoder build into your N64. Pads on the DIY modding board are labeled.
  * If you have a MAV-NUS in your N64, you may want to use either the DIY break out board provided with this project and on OSHPark or buy a [flex cable from viletims shop](http://etim.net.au/shop/shop.php?crn=209&rn=555&action=show_detail)

### Source the PCB

Choose the PCB service which suits you. Here are some:

- OSHPark: [Link to the Main PCB](https://oshpark.com/shared_projects/YLmjGvSn) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- OSHPark: [Link to the Filter AddOn PCB](https://oshpark.com/shared_projects/BTvi9bfX) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938)) -- get this PCB with 0.8mm (or less) substrate thickness
- PCBWay.com: [Link](http://www.pcbway.com/), [Affiliate Link](http://www.pcbway.com/setinvite.aspx?inviteid=10658)

### Part List for the PCB

This part list a recommendation how the PCB is designed. If you are able to find pin-compatible devices / parts, you can use them.

#### Components

Components are listed in advancedRGBmod/Main-PCB/BOM_n64advanced.xlsx


### Firmware
The firmware is located in the folder firmware/. To build the firmware on your own you need Quartus Prime Lite (any version which supports MaxII and MaxV devices).

If you only want to flash the firmware, the configuration files are pre-compiled and located in firmware/output_files. You need the POF appropriate for the CPLD you have choosen (look for the *\_extension*).

For flashing you need:

- Altera USB Blaster
- Standalone Quartus Prime Programmer and Tools

#### Firmware Revision Numbering

- 1.0: initially commited version

#### Road Map / New Ideas

- Gamma boost
- On Screen Display menu to get rid of the jumpers
- improve de-blur heuristic, e.g. by
  * de-blur estimation in the Y-domain
  * dynamic de-blur: decide on demand wether a pixel is used for a blurry effect or not (possible for the N64 to decide on demand? (e.g. background gaming with blur, front text without blur))
  * don't use quite dark / light pictures for the de-blur heuristic algorithm
- HDMI


Any other ideas: email me :)