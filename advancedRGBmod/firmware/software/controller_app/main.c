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
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "vd_driver.h"

#define MAINLOOP_DELAY_MS 15

int main()
{
  cmd_t command;
  updateaction_t todo;
  menu_t *menu = &home_menu;

//  char szText[VD_WIDTH];

  static alt_u8  info_data_pre = 0;

  cfg_load_defaults();

  /* Event loop never exits. */
  while (1) {
    get_ctrl_data();
    get_info_data();

    command = ctrl_data_to_cmd();

    switch (command) {
      case CMD_DEBLUR_QUICK_ON:
        if (!(info_data & INFO_480I_GETMASK)) {
          cfg_data = (cfg_data | CFG_DEBLUR_SETMASK) | CFG_FORCEDEBLUR_SETMASK;
          cfg_apply();
        };
        break;
      case CMD_DEBLUR_QUICK_OFF:
        if (!(info_data & INFO_480I_GETMASK)) {
          cfg_data = (cfg_data & CFG_DEBLUR_CLRMASK) | CFG_FORCEDEBLUR_SETMASK;
          cfg_apply();
        };
        break;
      case CMD_15BIT_QUICK_ON:
        cfg_data |= CFG_15BITMODE_SETMASK;
        cfg_apply();
        break;
      case CMD_15BIT_QUICK_OFF:
        cfg_data &= CFG_15BITMODE_CLRMASK;
        cfg_apply();
        break;
      default:
        break;
    }

    todo = apply_command(command,&menu);

    switch (todo) {
      case MENU_OPEN:
        cfg_data |= CFG_SHOWOSD_SETMASK;
        cfg_apply();
        print_overlay(menu);
        print_select(menu);
        break;
      case MENU_CLOSE:
        cfg_data &= CFG_SHOWOSD_CLRMASK;
        cfg_apply();
        break;
      case NEW_OVERLAY:
        print_overlay(menu);
        print_select(menu);
        break;
      case NEW_SELECTION:
        print_select(menu);
        break;
      default:
        break;
    }

    if ((menu->type == INFO) &&
        ((info_data_pre != info_data) ||
         (todo == NEW_OVERLAY)))
      update_vinfo_screen();

//    sprintf(szText,"Ctrl.Data: 0x%08x",(uint) ctrl_data);
//    if (menu->type == HOME)
//      vd_print_string(3, VD_HEIGHT-3, FONTCOLOR_WHITE, &szText[0]);

    info_data_pre = info_data;

    /* ToDo:
     * use external interrupt to go on, e.g. using VSYNC
     */
    usleep(MAINLOOP_DELAY_MS*1000);
  }

  return 0;
}
