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
 * screens.h
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef SCREENS_H_
#define SCREENS_H_

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

typedef enum {
  HOME_SCR = 0,
  INFO_SCREEN,
  CFG_SCREEN
} screentype_t;

extern char szText[];

void print_home_screen(void);
void print_info_screen(void);
void update_info_screen(void);
void print_cfg_screen(void);
void update_cfg_screen(void);


#endif /* SCREENS_H_ */
