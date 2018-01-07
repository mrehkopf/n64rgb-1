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
 * virtual_display.c
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/
 
#include <string.h>
#include <stddef.h>
#include <unistd.h>
#include "virtual_display.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

alt_u8 _width = VD_WIDTH;
alt_u8 _height = VD_HEIGHT;

int VD_print_string(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, char string[])
{
  int i = 0;
  alt_u8 original_horiz_offset;

  original_horiz_offset = horiz_offset;

  // Print until we hit the '\0' char.
  while (string[i]) {
    //Handle newline char here.
    if (string[i] == '\n') {
      horiz_offset = original_horiz_offset;
      vert_offset++;
      i++;
      continue;
    }
    // Lay down that character and increment our offsets.
    VD_print_char(horiz_offset, vert_offset, color, string[i]);
    i++;
    horiz_offset++;
  }
  return (0);
}

int VD_print_char (alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, char character)
{
  if((horiz_offset >= 0) && (horiz_offset < _width) && (vert_offset >= 0) && (vert_offset < _height)){
    VD_SET_ADDR(horiz_offset,vert_offset);
    VD_SET_DATA(color,character);
    VD_write_data();
  }
  return(0);
}


void VD_write_data()
{
  alt_u8 wrctrl;

  wrctrl = IORD_ALTERA_AVALON_PIO_DATA(TXT_WRCTRL_BASE) | VD_WRCTRL_WREN_IORMASK;
  IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRCTRL_BASE,wrctrl);
  wrctrl = wrctrl & VD_WRCTRL_ACLR_ANDMASK;
  IOWR_ALTERA_AVALON_PIO_DATA(TXT_WRCTRL_BASE,wrctrl);
}
