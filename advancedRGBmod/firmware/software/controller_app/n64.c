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
 * n64.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"

alt_u32 ctrl_data;
alt_u8  info_data;
alt_u16 cfg_data;


void get_all_data(void)
{
  get_ctrl_data();
  get_info_data();
  get_config();
};

void get_ctrl_data(void)
{
  ctrl_data = IORD_ALTERA_AVALON_PIO_DATA(CTRL_DATA_IN_BASE);
};

void get_info_data(void)
{
  info_data = IORD_ALTERA_AVALON_PIO_DATA(INFO_SET_IN_BASE) & INFO_GETALL_MASK;
};

void get_config(void)
{
  cfg_data = IORD_ALTERA_AVALON_PIO_DATA(CFG_SET_IN_BASE) & CFG_GETALL_MASK;
};

