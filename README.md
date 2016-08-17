# N64 RGB Firmware
An alternative firmware for viletims commercial N64 RGB mod


## Description of the Firmware Version

I uploaded three different firmware versions as well as a template. These are the features:
- Detection of 240p/288p
- Detection of PAL and NTSC mode (no output of that information at the moment as it is only internally used)
- De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- Slow Slew Rate (separate programming file)
- toogle de-blur and 15bit color mode using the controller (separate programming file; NO slow slew rates)

Some games uses full horizontal resolution even in 240p/288p output mode. In this case the de-blur introduces a blurry picture. This can be deactivated by setting an appropriate pin (see below)


### De-Blur

De-blur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis use these pixel for additional information rather than for bluring effects. Hence, the picture looks more blurry in this case if de-blur feature is activated.

By default this feature is on.
- 'firmware without IGR': To deactivate it pin 100 of the MaxII CPLD has to be set to GND.
- 'firmware with IGR': To deactivate / reactivate press D-Pad ri + L + R C-ri. The default is set on each power cycle.

### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) downto 15bits (5bit for each color). Most games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

By default this feature is off.
- 'firmware without IGR': To activate it set pin 99 of the CPLD to GND.
- 'firmware with IGR': To deactivate / reactivate press D-Pad le + L + R C-le. The default is set on each power cycle. 

### Slow Slew Rate

This feature reduces the rising and falling time of the outputs. This could help if you have artefacts due to fast rising/falling edges at the outputs and the resulting over-/undershoots. The drawback is that the edges are not as sharp as with fast slew rates. (at least in theory)

This feature is only provided over an addition programming file. Choose n64rgb.pof for fast changing outputs and n64rgb_ssr.pof for slow changing outputs, respectively. Just have a look on both and choose your preferred one.

### IGR (In Game Routines)

To use this firmware (and therefore the IGRs) pin 100 of the CPLD (pad *A*) has to be connected to the communication wire of controller 1. On the controller port this is the middle pin, which is connected to pin 16 of the PIF-NUS (PIFP-NUS) on most consoles. Check this before solderinga wire to the PIF-NUS.  

Three functunalities are implemented: toggle de-blur feature and the 15bit mode (see above) as well as resetting the console. To use the reset functionality please connect pin 1 OR pin 99 of the CPLD (pad *M*) to the PIF-NUS pin 27. The reset is initiated by pressing A + B + D-Pad down + D-Pad right + L + R together.  

However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incomming issue report to furhter improve this feature :)   

### Template for Heuristic Guess

I uploaded a template for the heuristic guess, which should provide the information if the N64 uses full horizontal resolution of 640 pixels in 240p/288p or not with a certain probability. I don't know how good the template is neither I know if it is possible with the current CPLD used. Feel free to implement your own tries. There is no IGR implemented here.

In this template no 15bit color mode exists at the moment. At the MaxII, pin 100 is used for activation the *Auto* mode (i.e. de-blur only in 240p/288p and if the heuristic guess says that only half of the horizontal resolution is used) and pin 99 is used to activate the *Manual* mode (i.e. de-blur in 240p/288p in every case). Both defaults are off; for on pins has to be set to GND.

## Technical Information

The firmware is suiteable for all version of the N64RGB modding kits designed by viletim.
- On V1.0 and V1.1 boards, CPLD pin 100, pin 99 and pin 1 are not connected to anything. You have to connect loose wires here.
- On V1.2 boards (and later versions?), CPLD pin 100 is connected to pad *A* and pin 99 to pad *M*.


Lastly, the information how to update can be grabbed incl. some more technical information here: [URL to viletims official website](http://etim.net.au/n64rgb/tech/). The use of the presented firmware is up on everybodies own risk. However, a fallback to the initial firmware is provided on viletim webpage. 