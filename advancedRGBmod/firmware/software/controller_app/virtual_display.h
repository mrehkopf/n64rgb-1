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

// define for font
#define FONT_10PT_ROW 11
#define FONT_10PT_COLUMN 8

extern char* cour10_font;

// define virtual display (memory mapped)
#define VD_WIDTH  288
#define VD_HEIGHT 128

#define VD_MAXCHARS_FONT_10PT 37
#define VD_MAXROWS_FONT_10PT  10

// define some masks
#define VD_WRDATA_ANDMASK       0x7
#define VD_WRCTRL_WREN_ORMASK   0x1
#define VD_WRCTRL_WREN_ANDMASK  0x2
#define VD_WRCTRL_ACLR_ORMASK   0x2
#define VD_WRCTRL_ACLR_ANDMASK  0x1

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
#define VD_SET_ADDR(x,y) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRADDR_BASE,x<<7 | (y & 0x7F))
#define VD_SET_DATA(x) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRDATA_BASE,x & VD_WRDATA_ANDMASK)

// prototypes
int VD_print_string(int horiz_offset, int vert_offset, alt_u8 color, char *font, char string[]);
int VD_print_char (int horiz_offset, int vert_offset, alt_u8 color, char character, char *font);
void VD_draw_Pixel(alt_u16 x, alt_u8 y, alt_u8 color);
void VD_write_data(void);

#endif /* VIRTUAL_DISPLAY_H_ */
