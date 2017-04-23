# Simple RGB Mod

## General Information

Technical information about this mod...

- Which N64 is suitable for it
- How to install this mod

... can be found on RetroRGB.com ([Compatibility](http://www.retrorgb.com/n64rgbcompatible.html) and [Installation](http://www.retrorgb.com/n64rgbmod.html))

Many thanks to Bob at this place for sharing that.

The rest

- Which parts are needed
- Some additional tips and hints

can be found in this document.

## Components

**be aware of the additional comments below this table**

| Label | Device / Part | Package | Quantity | Mouser Ordering Key | Comment |
|:---:|---|---|:---:|:---|---|
| | | | | | |
| **U1** | THS7374 | TSSOP-14 | 1 | 595-THS7374IPWR | |
| | THS7373 | TSSOP-14 | 1 | 595-THS7373IPWR | **Alternative** for the THS7374 [1] |
| **C1** | 0.1uF / 50V (10%) | SMD 0603 | 1 | 80-C0603C104K9R | |  
| **C2** | 22uF / 6.3V (tantal) | SMD case B (typical: 3.50mm x 2.80mm) | 1 | 74-593D226X96R3B2TE3 |
| | | | | | |
| **R1, R41** | 4.7kohm (1%) | SMD 0603 | 2 | 71-CRCW06034K70FKEAH | |
| **R42** | 475ohm (1%) | SMD 0603 | 1 | 71-CRCW0603-475-E3 | csync compatible with 75ohm termination [2,3] |
| | 10.7kohm | SMD 0603 | 1 | 71-CRCW060310K7FKEB | TTL compatible csync [2,3] |
| **C11,C21,C31** | 82pF / 50V (10%) | SMD 0603 | 3 | 80-C0603C824K8P | |
| **R12,R22,R32** | 5.1Mohm (1%) | SMD 0603 | 3 | 71-CRCW06035M10FKEA | |
| | | | | | |
| **R13,R23,R33** | 75ohm (1%) | SMD 0603 | 3 | 71-RCS060375R0FKEA | NTSC-SNES RGB cable setup or direct wiring on RGB wires [4] |
| | 39ohm (1%) | SMD 0603 | 3 | 71-CRCW060339R0FKEAH | PAL-SNES cable setup on RGB wires [4] |
| **C14,C24,C34** | 47pF / 25V (5%) | SMD 0603 | 3 | 77-VJ0603A470JXXPBC | | 
| | | | | | |
| **C43** | tantal 220uF / 6.3V (tantal) | SMD case D (typical: 7.30mm x 4.30mm) | 1 | 74-593D227X96R3D2TE3 | csync compatible with 75ohm termination[2,3] |
| | 330uF / 6.3V (tantal) | SMD case D (typical: 7.30mm x 4.30mm) | 1 | 74-TR3D337K6R3E0100 | /CSYNC compatible with 75ohm termination, **Alternative** to 220uF tantal [2,3] |
| | *free* | | | | TTL compatible /CSYNC, close **J2** [2,3] |
| **R43** | 75ohm (1%) | SMD 0603 | 1 | 71-RCS060375R0FKEA | csync compatible with 75ohm termination [2,3], NTSC-SNES RGB cable setup [4] |
|| 39ohm (1%) | SMD 0603 | 1 | 71-CRCW060339R0FKEAH | /CSYNC compatible with 75ohm termination [2,3], PAL-SNES cable setup on RGB wires [4] |
| | 0ohm | SMD 0603 | 1 | *use a piece of silver wire* |  TTL compatible /CSYNC [2,3] |
| **C44** | 47pF / 25V (5%) | SMD 0603 | 1 | 77-VJ0603A470JXXPBC | [3] | 


### Additional Comments:

  
##### [1]  
Both ICs are supported. The THS7373 has one SD-video low pass filter (used for /CSYNC) and three HD-video filters (used for R, G and B). The THS7374 has four SD-video filters.  
At the THS7373 the HD-video LPFs can be bypassed and at the THS7374 all four SD-video filters can be bypassed (using J1).

##### [2]
According to your needs, you can design the board such that it outputs 75ohm compatible /CSYNC or TTL /CSYNC. Be aware of the components marked with this note (**R42**, **R43**, **C43/J2** and **C44**).

##### [3]
If you are going to use the stock /CSYNC circuit of the N64 - which I recommend if you have a NUS-CPU-01/02/03 board - you don't need the components **R43**, **C43** and **C44**. Just leave the footprints disassembled.

##### [4]
As the N64 does not output RGB by stock, there is no official RGB cable available. A most common method is to refere to the [SNES cable schematics](http://members.optusnet.com.au/eviltim/gamescart/gamescart.htm#snes).

- If you use a NTSC cable cable, **R13**, **R23** and **R33** (and **R43**) has to be 75ohm resistors.
- If you use a PAL cable setup, **R13**, **R23** and **R33** (and **R43**) has to be 39ohm resistors.

## Source the PCB
Choose the PCB service which suits you. Here are some:

- OSHPark: [Link to the PCB](https://oshpark.com/shared_projects/B3Unx78x) (If the PCB was updated and I forgot to update this link, look onto [my profile](https://oshpark.com/profiles/borti4938))
- PCBWay.com: [Link](http://www.pcbway.com/), [Affiliate Link](http://www.pcbway.com/setinvite.aspx?inviteid=10658)

## Installation

A very good installation guide can be found on [RetroRGB.com](http://www.retrorgb.com/n64rgbmod.html).