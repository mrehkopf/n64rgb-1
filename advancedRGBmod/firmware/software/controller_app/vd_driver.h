/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
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
 * vd_driver.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef VD_DRIVER_H_
#define VD_DRIVER_H_

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"


// define virtual display (memory mapped)
#define VD_WIDTH  49
#define VD_HEIGHT 12

// define some masks and shifts
#define VD_WRDATA_COLOR_OFFSET  8

#define VD_WRDATA_COLOR_ANDMASK 0x700
#define VD_WRDATA_FONT_ANDMASK  0x0FF


#define VD_WRADDR_HSHIFT_OFFSET 4

#define VD_WRADDR_V_ANDMASK 0x00F
#define VD_WRADDR_H_ANDMASK 0x3F0


#define VD_WRCTRL_GETALL_MASK   0x3
#define VD_WRCTRL_WREN_GETMASK  0x1
#define VD_WRCTRL_WREN_SETMASK  0x1
#define VD_WRCTRL_WREN_CLRMASK  (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WREN_SETMASK)
#define VD_WRCTRL_ACLR_GETMASK  0x2
#define VD_WRCTRL_ACLR_SETMASK  0x2
#define VD_WRCTRL_ACLR_CLRMASK  (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_ACLR_SETMASK)


// Color definitions
#define FONTCOLOR_NON     0x0
#define FONTCOLOR_WHITE   0x1
#define FONTCOLOR_RED     0x2
#define FONTCOLOR_GREEN   0x3
#define FONTCOLOR_BLUE    0x4
#define FONTCOLOR_YELLOW  0x5
#define FONTCOLOR_CYAN    0x6
#define FONTCOLOR_MAGENTA 0x7

// some special chars
#define TRIANGLE_RIGTH  0x10
#define TRIANGLE_LEFT   0x11
#define ARROW_RIGHT     0x1a
#define ARROW_LEFT      0x1b

// some macros
#define VD_SET_ADDR(h,v) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRADDR_BASE,((h<<VD_WRADDR_HSHIFT_OFFSET) & VD_WRADDR_H_ANDMASK) | (v & VD_WRADDR_V_ANDMASK))
#define VD_SET_DATA(c,f) IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRDATA_BASE,((c<<VD_WRDATA_COLOR_OFFSET) & VD_WRDATA_COLOR_ANDMASK) | (f & VD_WRDATA_FONT_ANDMASK))
#define VD_CLEAR_SCREEN  vd_clear_area(0,VD_WIDTH,0,VD_HEIGHT)

// prototypes
int vd_clear_column(alt_u8 horiz_offset, alt_u8 vert_offset_start, alt_u8 vert_offset_stop);
int vd_clear_area(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop);
static int inline vd_clear_lineend (alt_u8 horiz_offset_start, alt_u8 vert_offset)
  { return vd_clear_area(horiz_offset_start, VD_WIDTH-1, vert_offset, vert_offset); }
static int inline vd_clear_fullline (alt_u8 vert_offset)
  { return vd_clear_area(0, VD_WIDTH-1, vert_offset, vert_offset); }
static int inline vd_clear_columnend (alt_u8 horiz_offset, alt_u8 vert_offset_start)
  { return vd_clear_area(horiz_offset, horiz_offset, vert_offset_start, VD_HEIGHT-1); }
static int inline vd_clear_fullcolumn (alt_u8 horiz_offset)
  { return vd_clear_area(horiz_offset, horiz_offset, 0, VD_HEIGHT-1); }
static int inline vd_clear_char (alt_u8 horiz_offset, alt_u8 vert_offset)
  { return vd_clear_area(horiz_offset, horiz_offset, vert_offset, vert_offset); }
int vd_print_string(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char *string);
int vd_print_char(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char character);
void vd_write_data();
void vd_mute();
void vd_unmute();

#endif /* VD_DRIVER_H_ */
