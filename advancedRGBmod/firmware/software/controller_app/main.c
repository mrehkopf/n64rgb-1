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
 * main.c
 *
 *  Created on: 08.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "system.h"

#include "cfg_header/cfg_internal_p.h"
#include "cfg_header/cfg_io_p.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "vd_driver.h"


#define DEBLUR_FORCE_OFF 1
#define DEBLUR_FORCE_ON  2

/* ToDo: break up with configuration word general - e.g. externalize non-flaged values for gamma and sl_str */

int main()
{
  cmd_t command;
  updateaction_t todo;
  menu_t *menu = &home_menu;

  cfg_word_t *cfg_io     = &cfg_data_general;
  cfg_word_t *cfg_intern = &cfg_data_internal;

//  char szText[VD_WIDTH];


  alt_u32 ctrl_data;
  alt_u8  info_data;

  static alt_u8  info_data_pre = 0;
  static alt_u16 cfg_io_word_pre = 0;

  info_data = get_info_data();

  /* ToDo: replace by load from flash */
  cfg_load_defaults(cfg_io,info_data & INFO_FALLBACKMODE_GETMASK);
  cfg_load_defaults(cfg_intern,0);
  cfg_io_word_pre = cfg_io->cfg_word_val;

  /* Event loop never exits. */
  while (1) {
    ctrl_data = get_ctrl_data();
    info_data = get_info_data();

    command = ctrl_data_to_cmd(&ctrl_data);

    if ((cfg_get_value(&igr_quickchange) & CFGI_QUDEBLUR_GETMASK) &&
        (!cfg_get_value(&show_osd))                                 )
      switch (command) {
        case CMD_DEBLUR_QUICK_ON:
          if (!(info_data & INFO_480I_GETMASK)) {
            cfg_set_value(&deblur,DEBLUR_FORCE_ON);
            cfg_apply_value(&deblur);
          };
          break;
        case CMD_DEBLUR_QUICK_OFF:
          if (!(info_data & INFO_480I_GETMASK)) {
            cfg_set_value(&deblur,DEBLUR_FORCE_OFF);
            cfg_apply_value(&deblur);
          };
          break;
        default:
          break;
      }

    if ((cfg_get_value(&igr_quickchange) & CFGI_QU15BITMODE_GETMASK) &&
        (!cfg_get_value(&show_osd))                                    )
      switch (command) {
        case CMD_15BIT_QUICK_ON:
          cfg_set_flag(&mode15bit);
          cfg_apply_value(&mode15bit);
          break;
        case CMD_15BIT_QUICK_OFF:
          cfg_clear_flag(&mode15bit);
          cfg_apply_value(&mode15bit);
          break;
        default:
          break;
      }

    todo = apply_command(command,&menu);

    switch (todo) {
      case MENU_OPEN:
        cfg_set_flag(&show_osd);
        cfg_apply_word(cfg_io);
        print_overlay(menu);
        print_selection_arrow(menu);
        break;
      case MENU_CLOSE:
        cfg_clear_flag(&show_osd);
        cfg_apply_word(cfg_io);
        break;
      case NEW_OVERLAY:
        print_overlay(menu);
        print_selection_arrow(menu);
//        print_selection_window(menu);
        break;
      case NEW_SELECTION:
        print_selection_arrow(menu);
//        print_selection_window(menu);
        break;
      default:
        break;
    }

    if ((menu->type == VINFO) &&
        ((info_data_pre != info_data)              ||
         (cfg_io_word_pre != cfg_io->cfg_word_val) ||
         (todo == NEW_OVERLAY)                     ))
      update_vinfo_screen(menu,&cfg_data_general,info_data);

    if ((menu->type == CONFIG) &&
        ((cfg_io_word_pre != cfg_io->cfg_word_val) ||
         (todo == NEW_OVERLAY)                     ||
         (todo == NEW_CONF_VALUE)                  ||
         (todo == NEW_SELECTION)                   ))
      update_cfg_screen(menu,cfg_io);

//    sprintf(szText,"Ctrl.Data: 0x%08x",(uint) ctrl_data);
//    if (menu->type == HOME)
//      vd_print_string(3, VD_HEIGHT-3, FONTCOLOR_WHITE, &szText[0]);


    info_data_pre = info_data;
    cfg_io_word_pre = cfg_io->cfg_word_val;

    /* ToDo: use external interrupt to go on on nVSYNC */
    while(!get_nvsync()) {};  /* wait for nVSYNC goes high */
    while( get_nvsync()) {};  /* wait for nVSYNC goes low  */
  }

  return 0;
}
