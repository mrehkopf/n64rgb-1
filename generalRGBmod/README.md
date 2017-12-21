# General N64 RGB Digital-to-Analog Mod

This folder contains all you need for a complete DIY RGB mod.

Please don't ask me for selling a modding. I either sell some prototypes on some forums marketplaces (which is very unlikely) or I don't have any of the boards.
This is a complete DIY modding project. So everybody is on his own here.
If you are looking for a ready to install kit, just look on your own for a seller. Preferably you should invest your money into a [kit made by viletim](http://etim.net.au/shop/shop.php?crn=209). I also provide similar firmware files for his board in this GitHub repository, too.

**WARNING:** This is an advanced DIY project if you do everything on your own. You need decent soldering skills. The CPLD has 0.5mm fine pitch with 100pins. Next to it the video amp has a 0.65mm pin pitch on the board there are some SMD1206 resistor and ferrit bead arrays.

## Features

- Supporting for different CPLDs on a common PCB design:
  * MaxII EPM240T100C5
  * MaxII EPM570T100C5
  * MaxV 5M240ZT100C4 (a 5M240ZT100C5 does not met timing requirements [1])
  * MaxV 5M570ZT100C4 (a 5M570ZT100C5 does not met timing requirements [1])
- Video DAC:
  * V1: R2R ladder with video amplifier THS7374 or THS7373
  * V2: Video DAC ADV7125
- Detection of 240p/288p vs. 480i/576i together with detection of NTSC vs. PAL mode
- Heuristic for de-blur function [2], De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- IGR features:
  * reset the console with the controller
  * full control on de-blur and 15bit mode with the controller
- Installation type: user decides whether he want to use IGR features or dedicated mechanical switches
- Slow Slew Rate
- for possibly future implementation: switch LPF of the video amplifier on and off (may only fit into CPLDs with 570LE)


The following shortly describes the main features of the firmware and how to use / control them.

#### Notes
##### [1]
Clocks are defined in the SDC-files place in the firmware folder.
The 5M240ZT100C5 and 5M570ZT100C5 does not met the timing requirements checked during the Timing Analysis. However, the default model is the so called *slow model*. If one uses the *fast model* for analysis, the timings are met without any problems.
So one could also give a try with the 5M240ZT100C5 or the 5M570ZT100C5, which should also works with 95% of all units produced in 'common' environments (e.g. living room temperature environment). Nevertheless, I won't garantee that.

Update: If you are looking for a 5M240ZT100C4 and 5M570ZT100C4, you propably realize that they are not in stock (e.g. at Mouser or Digikey). Then you can also use the 5M240ZT100I5 and 5M570ZT100I5, which are actually the same CPLDs.


##### [2]
Heuristic for de-blur function highly depends on the image content. So it might be the case that de-blur is switched on and off rapidly even on small content changes. In any case you can override the heuristic by forcing de-blur on or off.  
If you observe something like that or where do you think that de-blur is not correctly guessed, please take a note (PAL / NTSC N64, game, ROM, situation), where I can check that and can try to further improve the heuristic algorithm. Send me your observation vie email or open an issue here on GitHub.


### In-Game Routines (IGR) (default installation type)

Three functunalities are implemented: toggle de-blur feature / override heuristic for de-blur and toggle the 15bit mode (see above) as well as resetting the console.

The button combination are as follows:

- reset the console: Z + Start + R + A + B
- (de)activate de-blur / override heuristic for de-blur: (see description below)
- (de)activate 15bit mode: (see description below)

_Modifiying the IGR Button Combinations_:  
It's difficult to make everybody happy with it. Third party controllers, which differ from the original ones by design, make it even more difficult. So it is possible to generate your own firmware with **your own** preferred **button combinations** implemented. Please refere to the document **IGR.README.md** located in the top folder of this repository for further information.

_Final remark on IGR_:  
However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incomming issue report to furhter improve this feature :)


### De-Blur

De-blur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis, 007 Goldeneye, and some others use these pixel for additional information rather than for bluring effects. In other words this means that these games uses full horizontal resolution even in 240p/288p output mode. Hence, the picture looks more blurry in this case if de-blur feature is activated.

- **By default heuristic is activated on every power cycle and on every reset!** However, as the heuristic guess might be not reliable, the guess can be override. Also, the heuristic algorithm can be switched off permanently by setting pin 2 of the CPLD to GND (short pin 1 and 2)
- Press Z + Start + R + C-le to deactivate de-blur (overrides the guess)
- Press Z + Start + R + C-ri to activate de-blur (overrides the guess)
- If heuristic estimation is switched off, the de-blur setting has a default value. This default is set on each power cycle but not on a reset. Default is de-blur *on*! If you want to have it *off* by default, short pin 91 and 90 at the CPLD!

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_


### Heuristic for De-Blur

As noted above, the N64 typically outputs a 320pixel wide picture in 240p/288p. As the pixel clock does not change compared to 480i/576i there outputted pixel wide is 640.
On the one hand, most games outputs a 320pixel wide picture in 240p/288p and use the remaining pixels to introduce a blur. This can be removed by simply blank these interpolated pixels.
On the other hand, a minor number of games outputs a 'full' 640pixel wide picture also in 240p/288p. In this case blanking out the suspected interpolated pixels causes a blurry picture.

The heuristic algorithm estimates whether a game uses the first or the second method. Depending on the result de-blur is active or not. However, as the estimation could be wrong, the user has the opportunity to override the estimation. (see section de-blur) At the moment it is not implemented that the heuristic can be switched on once overridden except with a reset or a new power cycle.


### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) downto 15bits (5bit for each color). Some very few games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

- By default the 15bit mode is *off*! The default is set on each power cycle but not on a reset. If you want to have it *on* by default, short pin 36 and 37 at the CPLD!
- to deactivate 15bit mode press Z + Start + R + C-up.
- to (re)activate 15bit mode press Z + Start + R + C-dw.

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_

### Jumpers - Altering Defaults and Installation Type

There are three jumpers jumpers on the modding board - one double solder jumper and one 'hidden' jumper - to set up deblur (IGR installation) and 15bit mode.  
The hidden jumper are nothing else then neighbouring pins. This pin is marked with an arrow. If you short a pair of pins you can change the default of the above noted features.  

- J11.1 -> deactivates de-blur by default (only applied if de-blur heuristic is off by default) **[1]**
- J11.2 -> deactivate the de-blur heuristic. **[1]**
- pin 36 and 37 (hidden jumper on v1) / J12.1 -> activates the 15bit color mode by default
- J12 (v1) / J12.2 (v2) -> Altering installation type **[2]** 

**Notes**:  

**[1]**  
Board Version September 2017 and later have a dedicated double solder jumper for de-blur heuristic and de-blur default. The jumper is labeled with _J11_ (left pad is _marked with a dot_). The middle pad is GND, the right pad is de-blur heuristic on (open) or off (short to middle) and the left pad is de-blur on (open) or off (short to middle), respectively.  
On older revisions _J11.1_ (pin 90 and 91) and _J11.2_ (pin 1 and 2) are hidden jumpers.  

**[2]**  
To use switches for de-blur (similar to viletims board) on can set the jumper _J12_ on the board. This deactivates the IGR functionalities and the user can use the in-/ouputs for controller and reset for switches.  
These switches are used as on viletims commercial board: **A**uto and **M**anual. The corresponding inputs are _Ctrl_ and _Rst#_, respectively. On newer boards (September 2017 and later) these pads are relabeled with _Ctrl/ A_ and _Rst#/ M_.

- If pad _Ctrl/ A_ is shorted to GND via a switch, the de-blur heuristic is used to switch de-blur on and off.
- If pad _Rst#/ M_ is shorted to GND via a switch, the de-blur is forced to be on (beats heuristic).

_J12_ is connected to pin 66 of the CPLD. Next to it is pin 65 which is connected to GND. If you have an older version of the board (August 2017 and earlier) running with the current firmware (September 2017 and later) you can short pin 65 and 66 to activate the alternative installation type.


### Slow Slew Rate

This feature reduces the rising and falling time of the outputs. This reduces artefacts due to fast rising/falling edges at the outputs and the resulting over-/undershoots. The drawback is that the edges are not as sharp as with fast slew rates (at least in theory), which is not noticeable.


### Low Pass Filter Bypass Mode of the THS7374 (v1 only)

The bypass mode of the internal filters is controlled by the CPLD. At the moment the CPLD forwards just the setting one can input to the CPLD over pad *Fil*.

- To leave the internal filters enabled you can left the pad open
- To bypass the filter set this pad to GND.

## Technical Information

A complete installation and setup guide to this modding kit is provided in the main folder of the repository. Here are some additional short notes.

### Checklist: How to build the project

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
  * Installation description is part of the guide located in the top folder.
  * However an installation guide of a simalar product made by viletim is provided [here](http://etim.net.au/n64rgb/). The minor differences / extra pads are as follows:
    * Pad *Fil*: controls the low pass filter mode (v1 only, see above)
    * Pad *Rst#*: connect this pad to the PIF-NUS pin 27
    * Pad *Ctrl*: connect this pin to the middle pin of the controller port you want to use for the IGR functions (controller port 1 is probably connected to PIF-NUS pin 16; check that before soldering a wire)
  * You have to be aware of the pinout of your video-encoder build into your N64. Pads on the DIY modding board are labeled.
  * If you have a MAV-NUS in your N64, you may want to use either the DIY break out board provided with this project and on OSHPark or buy a [flex cable from viletims shop](http://etim.net.au/shop/shop.php?crn=209&rn=555&action=show_detail)

### Source the PCB
Choose the PCB service which suits you. Here are some:

- OSHPark: [Link to the Main PCB v1](https://oshpark.com/shared_projects/0wcOS9Yw) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- OSHPark: [Link to the Main PCB v2](https://oshpark.com/shared_projects/hLhwaglc) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- PCBWay.com: [Link](http://www.pcbway.com/), [Affiliate Link](http://www.pcbway.com/setinvite.aspx?inviteid=10658)

### BOM / Part List for the PCB
This part list a recommendation how the PCB is designed. If you are able to find pin-compatible devices / parts, you can use them.

The manufacturer's part numbers (MPNs) are just to help you to source appropriate components.

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
- HDMI?

Any other ideas: email me :)