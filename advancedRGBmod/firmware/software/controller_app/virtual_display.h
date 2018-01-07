/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2016-2017 by Peter Bartmann <borti4938@gmx.de>
 *
 * N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *********************************************************************************
 *
 * virtual_display.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef VIRTUAL_DISPLAY_H_
#define VIRTUAL_DISPLAY_H_

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"

// define virtual display (memory mapped)
#define VD_WIDTH  48
#define VD_HEIGHT 12

// define some masks and shifts
#define VD_WRDATA_COLOR_ANDMASK 0x700
#define VD_WRDATA_FONT_ANDMASK  0x0FF

#define VD_WRADDR_Y_ANDMASK 0x00F
#define VD_WRADDR_X_ANDMASK 0x3F0

#define VD_WRCTRL_WREN_ANDMASK  0x1
#define VD_WRCTRL_WREN_IORMASK  0x1
#define VD_WRCTRL_ACLR_ANDMASK  0x2

#define VD_WRDATA_COLOR_SHIFT   8
#define VD_WRADDR_X_SHIFT       4

// Color definitions
#define VD_NON      0x0
#define VD_WHITE    0x1
#define VD_RED      0x2
#define VD_GREEN    0x3
#define VD_BLUE     0x4
#define VD_YELLOW   0x5
#define VD_CYAN     0x6
#define VD_MAGENTA  0x7

// some macros
#define VD_SET_ADDR(x,y) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRADDR_BASE,((x<<VD_WRADDR_X_SHIFT) & VD_WRADDR_X_ANDMASK) | (y & VD_WRADDR_Y_ANDMASK))
#define VD_SET_DATA(c,f) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRDATA_BASE,((c<<VD_WRDATA_COLOR_SHIFT) & VD_WRDATA_COLOR_ANDMASK) | (f & VD_WRDATA_FONT_ANDMASK))

// prototypes
int VD_print_string(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, char string[]);
int VD_print_char(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, char character);
void VD_write_data(void);

#endif /* VIRTUAL_DISPLAY_H_ */
