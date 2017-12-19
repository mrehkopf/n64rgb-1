# Filter Add On for N64 RGBv2 and N64 Advanced

This filter board is meant to use with the N64RGBv2 and N64 Advanced. It can be used to filter the video signal comming out of the ADV7125 or to adjust signal levels such that one can use SNES PAL RGB cables.

The PCB can be sourced on every manufacturer you like. Use a **PCB substrate thickness** as small as possible; e.g., 0.8mm at OSHPark.

- OSHPark: [Link to the Filter AddOn PCB](https://oshpark.com/shared_projects/BTvi9bfX) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938)) -- get this PCB with 0.8mm (or less) substrate thickness
- PCBWay.com: [Link](http://www.pcbway.com/), [Affiliate Link](http://www.pcbway.com/setinvite.aspx?inviteid=10658)

## Filter Settings

The board utilizes the THS7368 with selectable filters. The setup is done via inputs _F1_ and _F2_.

### N64RGBv2

- Leave _F1_ and _F2_ open or short the to GND to use the filter.
- Connect _F1_ and _F2_ to Vcc, i.e. +5V, to effectively bypass the filter.

### N64Advanced

Commect _F1_ and _F2_ to the modding board and use _J1_ to set it up.

## Jumper J1

With the jumper _J1_ you are able to forward composite sync input to either MultiAV pin 3 or pin 7.  
The composite sync input _/CS_ **is not** passed through the THS7386. You can either connect TTL level sync or 75ohm attenuated sync, here.

## BOM

- U1: THS7368
- C1: 0.1uF SMD0603 ceramic cap
- C2: 22uF SMD1206 ceramic cap
- RN1: 4x 75ohm resistor array SMD1206
- RN2:
  * NTSC cable:: 4x 75ohm resistor array SMD1206
  * PAL cable:: 4x 39ohm resistor array SMD1206
  
