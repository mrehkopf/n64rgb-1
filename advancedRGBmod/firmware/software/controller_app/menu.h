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
 * menu.h
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef MENU_H_
#define MENU_H_

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "config.h"


typedef enum {
  NON = 0,
  MENU_OPEN,
  MENU_CLOSE,
  NEW_OVERLAY,
  NEW_SELECTION,
  NEW_CONF_VALUE
} updateaction_t;

typedef enum {
  HOME = 0,
  VINFO,
  CONFIG,
  TEXT
} screentype_t;

typedef enum {
  ICONFIG,
  ISUBMENU,
  IFUNC
} leavetype_t;

typedef struct {
  alt_u8      id;
  leavetype_t leavetype;
  union {
    struct menu     *submenu;
    config_t        *config_value;
  };
} leaves_t;

typedef struct menu {
  const screentype_t  type;
  const char*         *header;
  const char*         *overlay;
  struct menu         *parent;
  const alt_u8        arrowshape;
  alt_u8              current_selection;
  const alt_u8        number_selections;
  alt_u8              hpos_selections;
  leaves_t            leaves[];

} menu_t;

extern menu_t home_menu;

updateaction_t apply_command(cmd_t command, menu_t** current_menu);
void print_overlay(menu_t* current_menu);
void print_selection_arrow(menu_t* current_menu);
void print_selection_window(menu_t* current_menu);
int update_vinfo_screen(menu_t* current_menu, cfg_word_t* cfg_word, alt_u8 info_data);
int update_cfg_screen(menu_t* current_menu, cfg_word_t* cfg_word);


//extern char szText[];
//
//void print_home_screen();
//void print_info_screen();
//void print_cfg_screen();


#endif /* MENU_H_ */
