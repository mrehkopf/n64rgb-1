# N64 RGB Firmware
An alternative firmware for viletims commercial N64 RGB mod


## Description of the Firmware Version

I uploaded two different firmware versions. These are the common features:
- Detection of 240p/288p
- Detection of PAL and NTSC mode (no output of that information at the moment as it is only internally used)
- Heuristic for de-blur function
- De-Blur in 240p/288p (horizontal resolution decreased from 640 to 320 pixels)
- 15bit color mode
- Slow Slew Rate

The two versions of the firmware now differs in the way how de-blur and 15bit color mode is accessed:
- With mechanical switches
- with in-game routine (IGR)

The following shortly describes the main features of the firmware and how to use / control them.


### De-Blur

De-blur of the picture information is only be done in 240p/288p. This is be done by simply blanking every second pixel. Normally, the blanked pixels are used to introduce blur by the N64 in 240p/288p mode. However, some games like Mario Tennis use these pixel for additional information rather than for bluring effects. In other words this means that these games uses full horizontal resolution even in 240p/288p output mode. Hence, the picture looks more blurry in this case if de-blur feature is activated.

By default this feature is on.
- 'firmware without IGR':
  * By setting pin 100 of the MaxII CPLD (pad *A*) to GND, the heuristic is activated. The firmware tries to estimate whether de-blur can be applied in 240p/288p or not.
  * By setting pin 99 of the MaxII CPLD (pad *M*) to GND, de-blur is applied in 240p/288p in any case. This overrides the heuristic.
  * By default (pin 100 and 99 / pad *A* and *M* left open) the de-blur feature is switched *off*!
- 'firmware with IGR':
  * **By default heuristic is activated on every power cycle and on every reset!** However, as the heuristic guess might be not reliable, the guess can be override. Also, the heuristic algorithm can be switched off permanently by setting pin 61 of the MaxII CPLD to GND (short pin 61 and 60)
  * Press D-Pad le + L + R + C-le to deactivate de-blur (overrides the guess)
  * Press D-Pad ri + L + R + C-ri to activate de-blur (overrides the guess)
  * If heuristic estimation is switched off, the de-blur setting has a default value. This default is set on each power cycle. Default is de-blur *on*! If you want to have it *off* by default, short pin 91 and 90 at the MaxII CPLD!

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_

### Heuristic for De-Blur

As noted above, the N64 typically outputs a 320pixel wide picture in 240p/288p. As the pixel clock does not change compared to 480i/576i there outputted pixel wide is 640.
On the one hand, most games outputs a 320pixel wide picture in 240p/288p and use the remaining pixels to introduce a blur. This can be removed by simply blank these interpolated pixels.
On the other hand, a minor number of games outputs a 'full' 640pixel wide picture also in 240p/288p. In this case blanking out the suspected interpolated pixels causes a blurry picture.

The heuristic algorithm estimates whether a game uses the first or the second method. Depending on the result de-blur is active or not. However, as the estimation could be wrong, the user has the opportunity to override the estimation. (see section de-blur)


### 15bit Color Mode

The 15bit color mode reduces the color depth from 21bit (7bit for each color) downto 15bits (5bit for each color). Some very few games just use the five MSBs of the color information and the two LSBs for some kind of gamma dither. The 15bit color mode simply sets the two LSBs to '0'.

By default this feature is off.
- 'firmware without IGR': To activate it set pin 36 of the CPLD to GND (short pin 36 and 37). This feature is *off* by default.
- 'firmware with IGR':
  * to deactivate 15bit mode press D-Pad up + L + R + C-up.
  * to (re)activate 15bit mode press D-Pad dw + L + R + C-dw.
  * the default is set on each power cycle. Default for 15bit color mode is *off*! If you want to have it *on* by default, short pin 36 and 37 at the MaxII CPLD!

_(Button combinations can be modified according to your needs - see note below @ **In-Game Routines (IGR)**)_

### Slow Slew Rate

This feature reduces the rising and falling time of the outputs. This reduces artefacts due to fast rising/falling edges at the outputs and the resulting over-/undershoots. The drawback is that the edges are not as sharp as with fast slew rates (at least in theory), which is not noticeable.


### In-Game Routines (IGR)

To use this firmware (and therefore the IGRs) pin 100 of the CPLD (pad *A*) has to be connected to the communication wire of controller 1. On the controller port this is the middle pin, which is connected to pin 16 of the PIF-NUS (PIFP-NUS) on most consoles. Check this before soldering a wire to the PIF-NUS.

Three functunalities are implemented: toggle de-blur feature / override heuristic for de-blur and toggle the 15bit mode (see above) as well as resetting the console. To use the reset functionality please connect pin 1 OR pin 99 of the CPLD (pad *M*) to the PIF-NUS pin 27. This is optional and can be left out if not needed.

The button combination are as follows:

- reset the console: A + B + D-Pad dw + D-Pad ri + L + R
- (de)activate de-blur / override heuristic for de-blur: (see description above)
- (de)activate 15bit mode: (see description above)

_Modifiying the IGR Button Combinations_:  
It's difficult to make everybody happy with it. Third party controllers, which differ from the original ones by design, make it even more difficult. So it is possible to generate your own firmware with **your own** preferred **button combinations** implemented. Please refere to the document **IGR.README.md** located in the top folder of this repository for further information.

_Final remark on IGR_:  
However, as the communication between N64 and the controller goes over a single wire, sniffing the input is not an easy task (and probably my solution is not the best one). This together with the lack of an exhaustive testing (many many games out there as well my limited time), I'm looking forward to any incomming issue report to furhter improve this feature :)


## Technical Information

The firmware is suiteable for all version of the N64RGB modding kits designed by viletim.
- On V1.0 and V1.1 boards, CPLD pin 100, pin 99 and pin 1 are not connected to anything. You have to connect loose wires here.
- On V1.2 boards (and later versions?), CPLD pin 100 is connected to pad *A* and pin 99 to pad *M*.


Lastly, the information how to update can be grabbed incl. some more technical information here: [URL to viletims official website](http://etim.net.au/n64rgb/tech/). The use of the presented firmware is up on everybodies own risk. However, a fallback to the initial firmware is provided on viletims webpage.


### Firmware Revision Numbering

Before 19.04.2017:
- The revisions were number with 1, 2, 3,...
- All revisions with a number below 4 has no IGRs implemented; revisions with 5 and later has the IGRs implemented.

After 19.04.2017:
- Revision numbering has changed:
  * 1.x - no IGR implemented. Use mechanical (or external electrical) switches
  * 2.x - IGR functions implemented.