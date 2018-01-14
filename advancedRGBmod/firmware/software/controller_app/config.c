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
 * config.c
 *
 *  Created on: 11.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"
#include "config.h"


#define FALLBACK_DEFAULT_CONFIG (             \
  CFG_GETALL_MASK & ( CFG_USEIGR_SETMASK    | \
                      CFG_RGSB_SETMASK      | \
                      CFG_SLSTR_0_SETMASK     ))
#define DEFAULT0_CONFIG (                      \
  CFG_GETALL_MASK & ( CFG_USEIGR_SETMASK    | \
                      CFG_SLSTR_0_SETMASK     ))

#define DEFAULT_CFG_ALLMASK           0x3F
#define DEFAULT_CFG_NRGSB_GETMASK     (1<<CFG_RGSB_OFFSET)
#define DEFAULT_CFG_NYPBPR_GETMASK    (1<<CFG_YPBPR_OFFSET)
#define DEFAULT_CFG_NSLSTR_GETMASK    (3<<CFG_SLSTR_OFFSET)
#define DEFAULT_CFG_LINEX2_GETMASK    (1<<CFG_LINEX2_OFFSET)
#define DEFAULT_CFG_N480IBOB_GETMASK  (1<<CFG_480IBOB_OFFSET)
#define DEFAULT_CFG_JUMPERINV_MASK    0x3D  /* inversion due to nature of jumper */


volatile alt_u16 cfg_data;


void cfg_load_defaults()
{
  if(info_data & INFO_FALLBACKMODE_GETMASK)
    cfg_data = FALLBACK_DEFAULT_CONFIG;
  else
    cfg_data = DEFAULT0_CONFIG | ((IORD_ALTERA_AVALON_PIO_DATA(DEFAULT_CFG_SET_IN_BASE) ^ DEFAULT_CFG_JUMPERINV_MASK) & DEFAULT_CFG_ALLMASK);

  cfg_apply();
}
