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
 * screens.c
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "system.h"
#include "n64.h"
#include "vd_driver.h"


#define INFO_HEADER_H_OFFSET  0
#define INFO_HEADER_V_OFFSET  0
#define INFO_OVERLAY_H_OFFSET 1
#define INFO_OVERLAY_V_OFFSET 2
#define INFO_VALS_H_OFFSET    29 + INFO_OVERLAY_H_OFFSET
#define INFO_VALS_V_OFFSET    INFO_OVERLAY_V_OFFSET

#define CFG_HEADER_H_OFFSET   INFO_HEADER_H_OFFSET
#define CFG_HEADER_V_OFFSET   INFO_HEADER_V_OFFSET
#define CFG_OVERLAY_H_OFFSET  INFO_OVERLAY_H_OFFSET
#define CFG_OVERLAY_V_OFFSET  INFO_OVERLAY_V_OFFSET
#define CFG_VALS_H_OFFSET     INFO_VALS_H_OFFSET
#define CFG_VALS_V_OFFSET     INFO_VALS_V_OFFSET

#define INFO_VIN_V_OFFSET     INFO_OVERLAY_V_OFFSET+1
#define INFO_VOUT_V_OFFSET    INFO_OVERLAY_V_OFFSET+2
#define INFO_COL_V_OFFSET     INFO_OVERLAY_V_OFFSET+3
#define INFO_FORMAT_V_OFFSET  INFO_OVERLAY_V_OFFSET+4
#define INFO_DEBLUR_V_OFFSET  INFO_OVERLAY_V_OFFSET+5
#define INFO_FAO_V_OFFSET     INFO_OVERLAY_V_OFFSET+6

#define CFG_LINEX2_V_OFFSET   CFG_OVERLAY_V_OFFSET+1
#define CFG_480IBOB_V_OFFSET  CFG_OVERLAY_V_OFFSET+2
#define CFG_SLSTR_V_OFFSET    CFG_OVERLAY_V_OFFSET+3
#define CFG_FORMAT_V_OFFSET   CFG_OVERLAY_V_OFFSET+4
#define CFG_DEBLUR_V_OFFSET   CFG_OVERLAY_V_OFFSET+5
#define CFG_15BIT_V_OFFSET    CFG_OVERLAY_V_OFFSET+6
#define CFG_GAMMA_V_OFFSET    CFG_OVERLAY_V_OFFSET+7

static const char *info_screen_header =  "Info-Screen\n"
                                         "=============";
static const char *info_screen_overlay = "* Video\n"
                                         "  - Input:\n"
                                         "  - Output:\n"
                                         "  - Color Depth:\n"
                                         "  - Format:\n"
                                         "* 240p-DeBlur:\n"
                                         "* Filter AddOn:";

static const char *cfg_screen_header =   "Config-Status\n"
                                         "=============";
static const char *cfg_screen_overlay =  "* Linedoubling\n"
                                         "  - LineX2:\n"
                                         "  - 480i de-interlace (bob):\n"
                                         "  - Scanlines:\n"
                                         "* Output Format:\n"
                                         "* 240p-DeBlur:\n"
                                         "* 15bit Mode:\n"
                                         "* Gamma Value:";

static const char *OnOff[]        = {"On","Off"};
static const char *VideoMode[]    = {"240p60","288p50","480i60","576i50","480p60","576p50"};
static const char *VideoColor[]   = {"15bit","21bit"};
static const char *VideoFormat[]  = {"RGBS/RGsB","RGBS","YPbPr"};
static const char *DeBlur[]       = {"(forced)","(estimated)","(480i/576i)"};
static const char *DeBlurCfg[]    = {"Auto","Always","Off"};
static const char *FilterAddOn[]  = {"not installed","9.5MHz","18MHz","Filter bypassed"};
static const char *SLStrength[]   = {"0%","25%","50%","100%"};
static const char *GammaValue[]   = {"1.0","0.8","0.9","1.1","1.2"};

char szText[VD_WIDTH];


void print_home_screen()
{
  VD_CLEAR_SCREEN;
  sprintf(szText, "Top Left");
  vd_print_string(0, 0, FONTCOLOR_RED, &szText[0]);
  sprintf(szText, "Hello World! Your N64A here.  ");
  szText[29] = 0x01;
  vd_print_string(8, 3, FONTCOLOR_GREEN, &szText[0]);
  sprintf(szText, "... press A to show video information");
  vd_print_string(3, 5, FONTCOLOR_GREEN, &szText[0]);
  sprintf(szText, "... press B to show configuration set");
  vd_print_string(3, 6, FONTCOLOR_GREEN, &szText[0]);
  sprintf(szText, "Bottom Right");
  alt_u8 text_tpx = VD_WIDTH - strlen(szText);
  vd_print_string(text_tpx, VD_HEIGHT-1, FONTCOLOR_RED, &szText[0]);
}

void print_info_screen()
{
  VD_CLEAR_SCREEN;
  vd_print_string(INFO_HEADER_H_OFFSET, INFO_HEADER_V_OFFSET, FONTCOLOR_RED, info_screen_header);
  vd_print_string(INFO_OVERLAY_H_OFFSET, INFO_OVERLAY_V_OFFSET, FONTCOLOR_WHITE, info_screen_overlay);
}


void update_info_screen()
{
  alt_u8 str_select;
  static alt_u8 video_sd_ed;

  // Video Input
  str_select = ((info_data & (INFO_480I_GETMASK | INFO_VMODE_GETMASK)) >> INFO_VMODE_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_VIN_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_VIN_V_OFFSET, FONTCOLOR_WHITE, VideoMode[str_select]);

  // Video Output
  switch(((cfg_data & (CFG_N240P_GETMASK | CFG_N480IBOB_GETMASK)) << 2) | str_select) {
    case 0xD: // 1101
    case 0xB: // 1011
    case 0x9: // 1001
      str_select  = 5;
      video_sd_ed = 1;
      break;
    case 0xC: // 1100
    case 0xA: // 1010
    case 0x8: // 1000
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
  str_select = (cfg_data & CFG_N15BIT_GETMASK) >> CFG_N15BIT_OFFSET;
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_COL_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_COL_V_OFFSET, FONTCOLOR_WHITE, VideoColor[str_select]);

  // Video Format
  if (cfg_data & CFG_NYPBPR_GETMASK)
    str_select = (cfg_data & CFG_NRGSB_GETMASK) >> CFG_NRGSB_OFFSET;
  else
    str_select = 2;
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_FORMAT_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET, INFO_FORMAT_V_OFFSET, FONTCOLOR_WHITE, VideoFormat[str_select]);

  // 240p DeBlur
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (info_data & INFO_480I_GETMASK) {
    str_select = 2;
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET, FONTCOLOR_RED, DeBlur[str_select]);
  } else {
    str_select = (info_data & INFO_NDODEBLUR_GETMASK) >> INFO_NDODEBLUR_OFFSET;
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET, FONTCOLOR_WHITE, OnOff[str_select]);
    str_select = (cfg_data & CFG_NFORCEDEBLUR_GETMASK) >> CFG_NFORCEDEBLUR_OFFSET;
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


void print_cfg_screen()
{
  VD_CLEAR_SCREEN;
  vd_print_string(CFG_HEADER_H_OFFSET, CFG_HEADER_V_OFFSET, FONTCOLOR_RED, cfg_screen_header);
  vd_print_string(CFG_OVERLAY_H_OFFSET, CFG_OVERLAY_V_OFFSET, FONTCOLOR_WHITE, cfg_screen_overlay);
}


void update_cfg_screen(alt_u8 force_update)
{
  alt_u8 str_select;

  // Linedoubling
  str_select = (~cfg_data & CFG_N240P_GETMASK) >> CFG_N240P_OFFSET;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_LINEX2_V_OFFSET);
  vd_print_string(CFG_VALS_H_OFFSET, CFG_LINEX2_V_OFFSET, FONTCOLOR_WHITE, OnOff[str_select]);

  str_select = (cfg_data & CFG_N480IBOB_GETMASK) >> CFG_N480IBOB_OFFSET;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET);
  if (info_data & INFO_480I_GETMASK)
    vd_print_string(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET, FONTCOLOR_RED, OnOff[str_select]);
  else
    vd_print_string(CFG_VALS_H_OFFSET, CFG_480IBOB_V_OFFSET, FONTCOLOR_WHITE, OnOff[str_select]);

  str_select = (~cfg_data & CFG_SLSTR_GETMASK) >> CFG_SLSTR_OFFSET;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET);
  if ((cfg_data & CFG_N240P_GETMASK) && (~info_data & INFO_480I_GETMASK))
    vd_print_string(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET, FONTCOLOR_WHITE, SLStrength[str_select]);
  else
    vd_print_string(CFG_VALS_H_OFFSET, CFG_SLSTR_V_OFFSET, FONTCOLOR_RED, SLStrength[str_select]);

  // Output Format
  if (cfg_data & CFG_NYPBPR_GETMASK)
    str_select = (cfg_data & CFG_NRGSB_GETMASK) >> CFG_NRGSB_OFFSET;
  else
    str_select = 2;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_FORMAT_V_OFFSET);
  vd_print_string(CFG_VALS_H_OFFSET, CFG_FORMAT_V_OFFSET, FONTCOLOR_WHITE, VideoFormat[str_select]);

  // 240p DeBlur
  if (cfg_data & CFG_NFORCEDEBLUR_GETMASK)
    str_select = 0;
  else
    str_select = ((cfg_data & CFG_NDEBLUR_GETMASK) >> CFG_NDEBLUR_OFFSET) + 1;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET);
  if (info_data & INFO_480I_GETMASK)
    vd_print_string(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET, FONTCOLOR_RED, DeBlurCfg[str_select]);
  else
    vd_print_string(CFG_VALS_H_OFFSET, CFG_DEBLUR_V_OFFSET, FONTCOLOR_WHITE, DeBlurCfg[str_select]);

  // 15bit mode
  str_select = (cfg_data & CFG_N15BIT_GETMASK) >> CFG_N15BIT_OFFSET;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_15BIT_V_OFFSET);
  vd_print_string(CFG_VALS_H_OFFSET, CFG_15BIT_V_OFFSET, FONTCOLOR_WHITE, OnOff[str_select]);

  // Gamma
  str_select = ((cfg_data & CFG_GAMMASEL_GETMASK) >> CFG_GAMMASEL_OFFSET) + 1;
  if (!(cfg_data & CFG_USEGAMMA_GETMASK))
    str_select = 0;
  vd_clear_lineend(CFG_VALS_H_OFFSET, CFG_GAMMA_V_OFFSET);
  vd_print_string(CFG_VALS_H_OFFSET, CFG_GAMMA_V_OFFSET, FONTCOLOR_WHITE, GammaValue[str_select]);
}
