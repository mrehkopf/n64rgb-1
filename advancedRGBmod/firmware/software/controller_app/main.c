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
#include "screens.h"
#include "vd_driver.h"

#define MAINLOOP_DELAY_MS 15

int main()
{
  screentype_t current_screen;
  alt_u8 text_tpx;

  current_screen = HOME_SCR;
  print_home_screen();

  /* Event loop never exits. */
  while (1) {
    get_all_data();
    if (info_data & INFO_OSDOPEN_GETMASK) {
      if ((ctrl_data & CTRL_A_GETMASK) &&
          (current_screen != INFO_SCREEN)) {
        current_screen = INFO_SCREEN;
        print_info_screen();  // clears whole screen in first step
        sprintf(szText, "B: Cfg-Screen");
        text_tpx = VD_WIDTH - strlen(szText);
        vd_print_string(text_tpx, VD_HEIGHT-1, FONTCOLOR_RED, &szText[0]);
      }
      if ((ctrl_data & CTRL_B_GETMASK) &&
          (current_screen != CFG_SCREEN)) {
        current_screen = CFG_SCREEN;
        print_cfg_screen();   // clears whole screen in first step
        sprintf(szText, "A: Info-Screen");
        text_tpx = VD_WIDTH - strlen(szText);
        vd_print_string(text_tpx, VD_HEIGHT-1, FONTCOLOR_RED, &szText[0]);
      }
      switch (current_screen) {
        case HOME_SCR:
          break;
        case INFO_SCREEN:
          update_info_screen();
          break;
        case CFG_SCREEN:
          update_cfg_screen();
          break;
        default: break;
      };
    }  /* END OF: if (info_data & INFO_OSDOPEN_GETMASK) */
    else {
      current_screen = HOME_SCR;
      print_home_screen();
    }; /* END OF: if (info_data & INFO_OSDOPEN_GETMASK) else */
    sprintf(szText,"Ctrl.Data: 0x%08x",(uint) ctrl_data);
    vd_print_string(0, VD_HEIGHT-1, FONTCOLOR_WHITE, &szText[0]);
    usleep(MAINLOOP_DELAY_MS*1000);
  }

  return 0;
}
