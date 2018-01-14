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
 * menu.c
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "menutexts.h"
#include "vd_driver.h"


menu_t vinfo_screen = {
    .type = INFO,
    .header = &vinfo_header,
    .overlay = &vinfo_overlay,
    .parent = &home_menu
};

menu_t thanks_screen = {
   .type = TEXT,
   .overlay = &thanks_overlay,
   .parent = &home_menu
};

menu_t about_screen = {
   .type = TEXT,
   .overlay = &about_overlay,
   .parent = &home_menu
};

menu_t license_screen = {
   .type = TEXT,
   .overlay = &license_overlay,
   .parent = &home_menu
};

menu_t home_menu = {
    .type = HOME,
    .header  = &home_header,
    .overlay = &home_overlay,
    .arrowshape = ARROW_RIGHT,
    .current_selection = 0,
    .number_selections = 6,
    .hpos_selections = 1,
    .leaves = {
        {.id = (0+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = &vinfo_screen},
        {.id = (1+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = NULL},
        {.id = (2+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = NULL},
        {.id = (4+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = &about_screen},
        {.id = (5+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = &thanks_screen},
        {.id = (6+OVERLAY_V_OFFSET_WH), .leavetype = ISUBMENU, .submenu = &license_screen}
    }
};

updateaction_t apply_command(cmd_t command, menu_t* *current_menu)
{
  if ((command == CMD_OPEN_MENU) ||
      (command == CMD_CLOSE_MENU)) {
    while ((*current_menu)->parent) {
      (*current_menu)->current_selection = 0;
      *current_menu = (*current_menu)->parent;
    }
    (*current_menu)->current_selection = 0;
    return ((command == CMD_OPEN_MENU) ? MENU_OPEN : MENU_CLOSE);
  }

  updateaction_t todo = NON;

  if (((*current_menu)->type == TEXT) ||
      ((*current_menu)->type == INFO)) {
    switch (command) {
      case CMD_MENU_LEFT:
      case CMD_MENU_BACK:
        *current_menu = (*current_menu)->parent;
        return NEW_OVERLAY;
        break;
      default:
        break;
    }
  }

  if ((*current_menu)->type == HOME) {
    switch (command) {
      case CMD_MENU_RIGHT:
      case CMD_MENU_ENTER:
        if ((*current_menu)->leaves[(*current_menu)->current_selection].submenu) {
          *current_menu = (*current_menu)->leaves[(*current_menu)->current_selection].submenu;
          return NEW_OVERLAY;
        }
        break;
      case CMD_MENU_LEFT:
      case CMD_MENU_BACK:
        (*current_menu)->current_selection = 0;
        return MENU_CLOSE;
      case CMD_MENU_DOWN:
        (*current_menu)->current_selection++;
        if ((*current_menu)->current_selection == (*current_menu)->number_selections)
          (*current_menu)->current_selection = 0;
        todo = NEW_SELECTION;
        break;
      case CMD_MENU_UP:
        if ((*current_menu)->current_selection == 0)
          (*current_menu)->current_selection =  (*current_menu)->number_selections - 1;
        else
          (*current_menu)->current_selection--;
        todo = NEW_SELECTION;
        break;
      default:
        break;
    }
  }

  return todo;
}

void print_overlay(menu_t* current_menu)
{
  alt_u8 i;
  VD_CLEAR_SCREEN;
  alt_u8 overlay_h_offset = (current_menu->type == TEXT) ? TEXTOVERLAY_H_OFFSET : HOMEOVERLAY_H_OFFSET;
  alt_u8 overlay_v_offset = 0;
  if (current_menu->header) {
    overlay_v_offset = OVERLAY_V_OFFSET_WH;
    vd_print_string(HEADER_H_OFFSET,0,FONTCOLOR_RED,*current_menu->header);
    for (i = 0; i < VD_WIDTH; i++)
      vd_print_char(i,1,FONTCOLOR_YELLOW,(char) HEADER_UNDERLINE);
  }
  vd_print_string(overlay_h_offset,overlay_v_offset,FONTCOLOR_WHITE,*current_menu->overlay);
  switch (current_menu->type) {
    case HOME:
      vd_print_string(COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,FONTCOLOR_RED,copyright_note);
      vd_print_char(COPYRIGHT_SIGN_H_OFFSET,COPYRIGHT_V_OFFSET,FONTCOLOR_RED,(char) COPYRIGHT_SIGN);
      vd_print_string(BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET,FONTCOLOR_GREEN,btn_overlay_0);
      for (i = 0; i < VD_WIDTH; i++)
        vd_print_char(i,VD_HEIGHT-2,FONTCOLOR_YELLOW,(char) HOME_LOWSEC_UNDERLINE);
      break;
    case TEXT:
      if (&(*current_menu->overlay) == &license_overlay)
        vd_print_char(CR_SIGN_LICENSE_H_OFFSET,CR_SIGN_LICENSE_V_OFFSET,FONTCOLOR_WHITE,(char) COPYRIGHT_SIGN);
      break;
    default:
      break;
  }
}

void print_select(menu_t* current_menu)
{
  alt_u8 h_select = current_menu->hpos_selections;
  alt_u8 v_run;
  for (v_run = 0; v_run < current_menu->number_selections; v_run++)
    if (v_run == current_menu->current_selection)
      vd_print_char(h_select,current_menu->leaves[v_run].id,FONTCOLOR_WHITE,(char) current_menu->arrowshape);
    else
      vd_clear_char(h_select,current_menu->leaves[v_run].id);
}

void update_vinfo_screen()
{
  alt_u8 str_select;
  static alt_u8 video_sd_ed;

  // Video Input
  str_select = ((info_data & (INFO_480I_GETMASK | INFO_VMODE_GETMASK)) >> INFO_VMODE_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_VIN_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_VIN_V_OFFSET, FONTCOLOR_WHITE, VideoMode[str_select]);

  // Video Output
  switch(((cfg_data & (CFG_LINEX2_GETMASK | CFG_480IBOB_GETMASK)) << 2) | str_select) {
   /* order: lineX2, 480ibob, 480i, pal */
    case 0xF: /* 1111 */
    case 0xD: /* 1101 */
    case 0x9: /* 1001 */
      str_select  = 5;
      video_sd_ed = 1;
      break;
    case 0xE: /* 1110 */
    case 0xC: /* 1100 */
    case 0x8: /* 1000 */
      str_select  = 4;
      video_sd_ed = 1;
      break;
    default :
      video_sd_ed = 0;
      break;
  }
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_VOUT_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_VOUT_V_OFFSET, FONTCOLOR_WHITE, VideoMode[str_select]);

  // Color Depth
  str_select = (cfg_data & CFG_15BITMODE_GETMASK) >> CFG_15BITMODE_OFFSET;
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_COL_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_COL_V_OFFSET, FONTCOLOR_WHITE, VideoColor[str_select]);

  // Video Format
  if (cfg_data & CFG_YPBPR_GETMASK)
    str_select = 2;
  else
    str_select = (cfg_data & CFG_RGSB_GETMASK) >> CFG_RGSB_OFFSET;
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_FORMAT_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_FORMAT_V_OFFSET, FONTCOLOR_WHITE, VideoFormat[str_select]);

  // 240p DeBlur
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (info_data & INFO_480I_GETMASK) {
    str_select = 2;
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET, FONTCOLOR_RED, DeBlur[str_select]);
  } else {
    str_select = (info_data & INFO_DODEBLUR_GETMASK) >> INFO_DODEBLUR_OFFSET;
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET, FONTCOLOR_WHITE, OffOn[str_select]);
    str_select = (cfg_data & CFG_FORCEDEBLUR_GETMASK) >> CFG_FORCEDEBLUR_OFFSET;
    vd_print_string(INFO_VALS_H_OFFSET + 4, INFO_DEBLUR_V_OFFSET, FONTCOLOR_WHITE, DeBlur[str_select]);
  }

  // Filter Add-on
  if (info_data & INFO_USEVGA_GETMASK)
    str_select = 0;
  else if (info_data & INFO_FILTERNBYPASS_GETMASK)
    str_select = video_sd_ed + 1;
  else
    str_select = 3;
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_FAO_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_FAO_V_OFFSET, FONTCOLOR_WHITE, FilterAddOn[str_select]);
}


//#define INFO_HEADER_H_OFFSET  0
//#define INFO_HEADER_V_OFFSET  0
//
//#define CFG_HEADER_H_OFFSET   INFO_HEADER_H_OFFSET
//#define CFG_HEADER_V_OFFSET   INFO_HEADER_V_OFFSET
//#define CFG_OVERLAY_H_OFFSET  INFO_OVERLAY_H_OFFSET
//#define CFG_OVERLAY_V_OFFSET  INFO_OVERLAY_V_OFFSET
//#define CFG_VALS_H_OFFSET     INFO_VALS_H_OFFSET
//#define CFG_VALS_V_OFFSET     INFO_VALS_V_OFFSET
//
//
//#define CFG_LINEX2_V_OFFSET   (CFG_OVERLAY_V_OFFSET+1)
//#define CFG_480IBOB_V_OFFSET  (CFG_OVERLAY_V_OFFSET+2)
//#define CFG_SLSTR_V_OFFSET    (CFG_OVERLAY_V_OFFSET+3)
//#define CFG_FORMAT_V_OFFSET   (CFG_OVERLAY_V_OFFSET+4)
//#define CFG_DEBLUR_V_OFFSET   (CFG_OVERLAY_V_OFFSET+5)
//#define CFG_15BIT_V_OFFSET    (CFG_OVERLAY_V_OFFSET+6)
//#define CFG_GAMMA_V_OFFSET    (CFG_OVERLAY_V_OFFSET+7)


//
//static const char *cfg_screen_header =   "Config-Status\n"
//                                         "=============";
//static const char *cfg_screen_overlay =  "* Linedoubling\n"
//                                         "  - LineX2:\n"
//                                         "  - 480i de-interlace (bob):\n"
//                                         "  - Scanlines:\n"
//                                         "* Output Format:\n"
//                                         "* 240p-DeBlur:\n"
//                                         "* 15bit Mode:\n"
//                                         "* Gamma Value:";
//
//
//char szText[VD_WIDTH];
//
//
//void print_cfg_screen()
//{
//  VD_CLEAR_SCREEN;
//  vd_print_string(CFG_HEADER_H_OFFSET, CFG_HEADER_V_OFFSET, FONTCOLOR_RED, cfg_screen_header);
//  vd_print_string(CFG_OVERLAY_H_OFFSET, CFG_OVERLAY_V_OFFSET, FONTCOLOR_WHITE, cfg_screen_overlay);
//}
//
//
//void update_cfg_screen()
//{
//  alt_u8 str_select;
//
//  // Linedoubling
//  str_select = (cfg_data & CFG_LINEX2_GETMASK) >> CFG_LINEX2_OFFSET;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_LINEX2_V_OFFSET);
//  vd_print_string(CFG_VALS_H_OFFSET, CFG_LINEX2_V_OFFSET, FONTCOLOR_WHITE, OffOn[str_select]);
//
//  str_select = (cfg_data & CFG_480IBOB_GETMASK) >> CFG_480IBOB_OFFSET;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET);
//  if (info_data & INFO_480I_GETMASK)
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET, FONTCOLOR_RED, OffOn[str_select]);
//  else
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET, FONTCOLOR_WHITE, OffOn[str_select]);
//
//  str_select = (cfg_data & CFG_SLSTR_GETMASK) >> CFG_SLSTR_OFFSET;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET);
//  if ((cfg_data & CFG_LINEX2_GETMASK) && (~info_data & INFO_480I_GETMASK))
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET, FONTCOLOR_WHITE, SLStrength[str_select]);
//  else
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET, FONTCOLOR_RED, SLStrength[str_select]);
//
//  // Output Format
//  if (cfg_data & CFG_YPBPR_GETMASK)
//    str_select = 2;
//  else
//    str_select = (cfg_data & CFG_RGSB_GETMASK) >> CFG_RGSB_OFFSET;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_FORMAT_V_OFFSET);
//  vd_print_string(CFG_VALS_H_OFFSET, CFG_FORMAT_V_OFFSET, FONTCOLOR_WHITE, VideoFormat[str_select]);
//
//  // 240p DeBlur
//  if (cfg_data & CFG_FORCEDEBLUR_GETMASK)
//    str_select = ((cfg_data & CFG_DEBLUR_GETMASK) >> CFG_DEBLUR_OFFSET) + 1;
//  else
//    str_select = 0;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET);
//  if (info_data & INFO_480I_GETMASK)
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET, FONTCOLOR_RED, DeBlurCfg[str_select]);
//  else
//    vd_print_string(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET, FONTCOLOR_WHITE, DeBlurCfg[str_select]);
//
//  // 15bit mode
//  str_select = (cfg_data & CFG_15BITMODE_GETMASK) >> CFG_15BITMODE_OFFSET;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_15BIT_V_OFFSET);
//  vd_print_string(CFG_VALS_H_OFFSET, CFG_15BIT_V_OFFSET, FONTCOLOR_WHITE, OffOn[str_select]);
//
//  // Gamma
//  str_select = ((cfg_data & CFG_GAMMASEL_GETMASK) >> CFG_GAMMASEL_OFFSET) + 1;
//  if (!(cfg_data & CFG_USEGAMMA_GETMASK))
//    str_select = 0;
//  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_GAMMA_V_OFFSET);
//  vd_print_string(CFG_VALS_H_OFFSET, CFG_GAMMA_V_OFFSET, FONTCOLOR_WHITE, GammaValue[str_select]);
//}
