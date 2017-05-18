# General N64 RGB Digital-to-Analog Mod

This folder contains all you need for a complete DIY RGB mod.

Please don't ask me for selling a modding. I either sell some prototypes on some forums marketplaces (which is very unlikely) or I don't have any of the boards.
This is a complete DIY modding project. So everybody is on his own here.
If you are looking for a ready to install kit, just look on your own for a seller. Preferably you should invest your money into a [kit made by viletim](http://etim.net.au/shop/shop.php?crn=209). I also provide similar firmware files for his board in this GitHub repository, too.

**WARNING:** This is an advanced DIY project if you do everything on your own. You need decent soldering skills. The CPLD has 0.5mm fine pitch with 100pins. Next to it the video amp has a 0.65mm pin pitch on the board there are some SMD1206 resistor and ferrit bead arrays.

## Featrues

- Supporting for different CPLDs on a common PCB design:
  * MaxII EPM240T100C5
  * MaxII EPM570T100C5
  * MaxV 5M240ZT100C4 (a 5M240ZT100C5 does not met timing requirements [1])
  * MaxV 5M570ZT100C4 (a 5M570ZT100C5 does not met timing requirements [1])
- Video amplifier THS7374 or THS7373
- Detection of 240p/288p
- Detection of PAL and NTSC mode
- Heuristic for de-blur function [2]
- De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- IGR features:
  * reset the console with the controller
  * full control on de-blur and 15bit mode with the controller
- Slow Slew Rate
- for possibly future implementation: switch LPF of the video amplifier on and off (may only fit into CPLDs with 570LE)


The following shortly describes the main features of the firmware and how to use / control them.

#### Notes
##### [1]
Clocks are defined in the SDC-files place in the firmware folder.
The 5M240ZT100C5 and 5M570ZT100C5 does not met the timing requirements checked during the Timing Analysis. However, the default model is the so called *slow model*. If one uses the *fast model* for analysis, the timings are met without any problems.
So one could also give a try with the 5M240ZT100C5 or the 5M570ZT100C5, which should also works with 95% of all units produced in 'common' environments (e.g. living room temperature environment). Nevertheless, I won't garantee that.


##### [2]
Heuristic for de-blur function highly depends on the image content. So it might be the case that de-blur is switched on and off rapidly even on small content changes. In any case you can override the heuristic by forcing de-blur on or off.  
If you observe something like that or where do you think that de-blur is not correctly guessed, please take a note (PAL / NTSC N64, game, ROM, situation), where I can check that and can try to further improve the heuristic algorithm. Send me your observation vie email or open an issue here on GitHub.

### De-Blur

De-blur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis use these pixel for additional information rather than for bluring effects. In other words this means that these games uses full horizontal resolution even in 240p/288p output mode. Hence, the picture looks more blurry in this case if de-blur feature is activated.

- **By default heuristic is activated on every power cycle and on every reset!** However, as the heuristic guess might be not reliable, the guess can be override. Also, the heuristic algorithm can be switched off permanently by setting pin 2 of the CPLD to GND (short pin 1 and 2)
- Press D-Pad le + L + R + C-le to deactivate de-blur (overrides the guess)
- Press D-Pad ri + L + R + C-ri to activate de-blur (overrides the guess)
- If heuristic estimation is switched off, the de-blur setting has a default value. This default is set on each power cycle but not on a reset. Default is de-blur *on*! If you want to have it *off* by default, short pin 91 and 90 at the CPLD!


### Heuristic for De-Blur

As noted above, the N64 typically outputs a 320pixel wide picture in 240p/288p. As the pixel clock does not change compared to 480i/576i there outputted pixel wide is 640.
On the one hand, most games outputs a 320pixel wide picture in 240p/288p and use the remaining pixels to introduce a blur. This can be removed by simply blank these interpolated pixels.
On the other hand, a minor number of games outputs a 'full' 640pixel wide picture also in 240p/288p. In this case blanking out the suspected interpolated pixels causes a blurry picture.

The heuristic algorithm estimates whether a game uses the first or the second method. Depending on the result de-blur is active or not. However, as the estimation could be wrong, the user has the opportunity to override the estimation. (see section de-blur) At the moment it is not implemented that the heuristic can be switched on once overridden except with a reset or a new power cycle.


### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) downto 15bits (5bit for each color). Some very few games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

- By default the 15bit mode is *off*! The default is set on each power cycle but not on a reset. If you want to have it *on* by default, short pin 36 and 37 at the CPLD!
- to deactivate 15bit mode press D-Pad up + L + R + C-up.
- to (re)activate 15bit mode press D-Pad dw + L + R + C-dw.


### 'Hidden' Jumpers - Altering Defaults

There are three 'hidden' jumpers on the modding board. The jumpers are nothing else then neighbouring pins. These pins are marked with an arrow. If you short a pair of pins you can change the default of the above noted features.

- pin 1 and 2 -> deactivate the de-blur heuristic.
- pin 36 and 37 -> deactivates de-blur by default (only applied if de-blur heuristic is off by default)
- pin 90 and 91 -> activates the 15bit color mode by default


### Slow Slew Rate

This feature reduces the rising and falling time of the outputs. This reduces artefacts due to fast rising/falling edges at the outputs and the resulting over-/undershoots. The drawback is that the edges are not as sharp as with fast slew rates (at least in theory), which is not noticeable.


### In-Game Routines (IGR)

Three functunalities are implemented: toggle de-blur feature / override heuristic for de-blur and toggle the 15bit mode (see above) as well as resetting the console.

The button combination are as follows:

- reset the console: A + B + D-Pad dw + D-Pad ri + L + R
- (de)activate de-blur / override heuristic for de-blur: (see description above)
- (de)activate 15bit mode: (see description above)

_Final remark on IGR_:
However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incomming issue report to furhter improve this feature :)


### Low Pass Filter Bypass Mode of the THS7374

The bypass mode of the internal filters is controlled by the CPLD. At the moment the CPLD forwards just the setting one can input to the CPLD over pad *Fil*.

- To leave the internal filters enabled you can left the pad open
- To bypass the filter set this pad to GND.

## Firmware / Technical Information

Firmware programming file depends on the CPLD you use. Please keep that in mind and look for the POF-file with appropriate extension.

### How to build the project

- Use PCB files to order your own PCB or simply use the shared project on OSHPark
- Source the components you need, e.g. from Mouser
- Wait for everything to arrive
- Assemble your PCB
  * If you use a MaxII CPLD, you don't need U3 and optionally you can left out C31, C32 and C33. You simply have to close J1.
  * If you use a MaxV CPLD, you need U3 (a 1.8V voltage regulator). Don't touch J1 in this case; a short at J1 harms U1 and U3!
  * To keep it short: **NEVER** close J1 and assemble U3!
- Flash the firmware to the CPLD:
  * You need a Altera USB Blaster
  * The board needs to be powered; so you may consider to install the PCB into your N64 first and then use the N64 for powering the board
  * If you want to build an adapter, you may take a look onto [my DIY adapter](https://oshpark.com/shared_projects/mEwjoesz) at [my profile on OSHPark](https://oshpark.com/profiles/borti4938)
- Install the modding board:
  * Installation is similar to the [installation of viletims board](http://etim.net.au/n64rgb/). The minor differences / extra pads are as follows:
    * Pad *Fil*: controls the low pass filter mode (see above)
    * Pad *Rst#*: connect this pad to the PIF-NUS pin 27
    * Pad *Ctrl*: connect this pin to the middle pin of the controller port you want to use for the IGR functions (controller port 1 is probably connected to PIF-NUS pin 16; check that before soldering a wire)
  * You have to be aware of the pinout of your video-encoder build into your N64. Pads on the DIY modding board are labeled.
  * If you have a MAV-NUS in your N64, you may want to use either the DIY break out board provided with this project and on OSHPark or buy a [flex cable from viletims shop](http://etim.net.au/shop/shop.php?crn=209&rn=555&action=show_detail)

### Source the PCB
Choose the PCB service which suits you. Here are some:

- OSHPark: [Link to the Main PCB](https://oshpark.com/shared_projects/Qmn5GoX0) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- OSHPark: [Link to the MAV-NUS/AVDC-NUS Breakout PCB](https://oshpark.com/shared_projects/36EEl3hA) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- PCBWay.com: [Link](http://www.pcbway.com/), [Affiliate Link](http://www.pcbway.com/setinvite.aspx?inviteid=10658)

### Part List for the PCB

This part list a recommendation how the PCB is designed. If you are able to find pin-compatible devices / parts, you can use them.

The mouser ordering keys are just to help you to source appropriate components.

#### Components

**be aware of the additional comments below this table**

| Label | Device / Part | Package | Quantity | Mouser Ordering Key | Comment |
|:---:|---|---|:---:|:---|---|
| | | | | | | |
| **C1** | 100uF / 6.3V (20%)| SMD 1206 | 1 | 81-GRM31CR60J107ME9L | For strong supply voltage filtering |
| **L1** | 10uH (10%) / 300mA | SMD 1210 | 1 | 81-LQH32CN100K23L | For strong supply voltage filtering |
| **FB1** | Ferrite Bead 470 Ohms (25%) DCR 0.2ohm | SMD 0603 | 1 | 81-BLM18PG471SN1D | **Alternative** for **C1** and **L1** for weak supply voltage filtering |
| | | | | | | |
| **U1** | EPM240T100C5N [1] | TQFP100 | 1 | 989-EPM240T100C5N | Close J1; don't use U3|
| | EPM570T100C5N [1] | TQFP100 | 1 | 989-EPM570T100C5N | Close J1; don't use U3 |
| | 5M240ZT100C4N [1] | TQFP100 | 1 | 989-5M240ZT100C4N | Leave J1 open; use U3 |
| | 5M570ZT100C4N [1] | TQFP100 | 1 | 989-5M570ZT100C4N | Leave J1 open; use U3 |
| **C10--C19,C22** | 0.1uF / 50V (10%) | SMD 0603 | 10 | 80-C0603C104K9R | |  
| **FBN10--FBN13** | Ferrite Chip Bead Array 1206; 4x 220ohm (25%) DCR 0.35ohm | SMD 1206 | 4 | 81-BLA31BD221SN4D | |
| | Chip Resistor Array 1206; 100ohm (1%) Concave 4resistors | SMD 1206 | 4 | 652-CAT16-1000F4LF | **Alternative** for the Ferrit Beads |
| **RN1x0, RN1x2** | Chip Resistor Array 1206; 2kohm (1%) Concave 4resistors | SMD 1206 | 6 | 652-CAT16-2001F4LF | |
| **RN1x1, RN1x3** | Chip Resistor Array 1206; 1kohm (1%) Concave 4resistors | SMD 1206 | 6 | 652-CAT16-1001F4LF | |
| **R10--R12** | 270ohm (1%) | SMD 0603 | 3 | 71-CRCW0603270RFKEAH | |
| **R13** | 4.7kohm (1%) | SMD 0603 | 1 | 71-CRCW06034K70FKEAH | |
| **R14** | 475ohm (1%) | SMD 0603 | 1 | 71-CRCW0603-475-E3 | |
| **R15** | 330ohm (1%) | SMD 0603 | 1 | 71-CRCW0603330RFKEAH | [4] |
| | _bridge_ | SMD 0603 | 1 | | **Alternative** for R15 [4]|
| | | | | | | |
| **U2** | THS7374 | TSSOP-14 | 1 | 595-THS7374IPWR | |
| | THS7373 | TSSOP-14 | 1 | 595-THS7373IPWR | **Alternative** for the THS7374 [2] |
| **C21** |  22uF/6.3volts (10%) | SMD 1206 | 1 | 81-GRM31CR60J226KE19 | |
| **RN20** | Chip Resistor Array 1206; 75ohm (1%) Concave 4resistors | SMD 1206 | 1 | 652-CAT16-75R0F4LF | see [3] |
| | Chip Resistor Array 1206; 39ohm (1%) Concave 4resistors | SMD 1206 | 1 | 652-CAT16-39R0F4LF | **Alternative**, see [3] |
| **C23--C27** | 47pF / 25V (5%) | SMD 0603 | 5 | 77-VJ0603A470JXXPBC | |  
| | | | | | | |
| **U3** | TLV70018DDCR | SOT-23-5 | 1 | 595-TLV70018DDCR | only use this if you use a MaxV CPLD; leave J1 open in that case! |
| **C31** | 10uF / 6.3V (10%) | SMD 1206 | 1 | 81-GRM426X106K6.3L | Use with **U3** |
| **C32,C33** | 1uF / 6.3V (10%) | SMD 0603 | 2 | 80-C0603C105K9R | Use with **U3** |

#### Additional Comments

##### [1]
Only use one of them!
From the price factor:

- If you head for 240LE, which is enough for the current implementation, I would take a EPM240T100C5N. Here you don't need **U3** and **C31-C33**.
- If you go for 570LE, which ensures that furture features (what ever that means; but no linedoubling) have enough place to fit in. Here you need **U3** and **C31-C33** for generating the internal voltage of 1.8V.

#### [2]
THS7373 has one SD-video and three HD-video filters implemented in. The red, green and blue channel are passed through the HD-video filters. These filters can be bypassed on demand which has nearly no effect. The C-Sync is passed through the SD-video filter, which cannot be bypassed.
In contrast, the THS7374 has four SD-video filters, which can be all bypassed. Therefor **I recommend to use the THS7374**!

#### [3]
If you use a RGB-cable for a NTSC-SNES, you need the 75ohm resistors.
If you use a RGB-cable for a PAL-SNES, you need the 39ohm resistors.

#### [4]
If you have a cable with this resistor inside your cable on the sync line, you don't need to have it here on board.


### Firmware
The firmware is located in the folder firmware/. To build the firmware on your own you need Quartus Prime Lite (any version which supports MaxII and MaxV devices).

If you only want to flash the firmware, the configuration files are pre-compiled and located in firmware/output_files. You need the POF appropriate for the CPLD you have choosen (look for the *\_extension*).

For flashing you need:

- Altera USB Blaster
- Standalone Quartus Prime Programmer and Tools

#### Firmware Revision Numbering

Revision numbering goes along with the revision numbering I use for the alternative firmware for viletims N64RGB modding kit.

#### Road Map / New Ideas

- don't use quite dark / light pictures for the de-blur heuristic algorithm (possibly only for the CPLDs with 570LEs)
- Simple onscreen feedback for user controled changes (only for the CPLDs with 570LEs (for the 240LEs CPLDs instead of the heuristic?))
- dynamic de-blur: decide on demand wether a pixel is used for a blurry effect or not (possible for the N64 to decide on demand? (e.g. background gaming with blur, front text without blur))
- Linedoubling mode (needs an upgrade to Max10 FPGA; will be separated from this sub-folder, e.g. in folder advancedRGBmod)
- Color transformation to component (needs an upgrade to Max10 FPGA; will be separated from this sub-folder, e.g. in folder advancedRGBmod)
- HDMI?

Any other ideas: email me :)