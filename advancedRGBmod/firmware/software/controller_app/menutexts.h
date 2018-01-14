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
 * menutexts.h
 *
 *  Created on: 14.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef MENUTEXTS_H_
#define MENUTEXTS_H_

#include <string.h>
#include <unistd.h>


#define HEADER_UNDERLINE      0x08
#define HOME_LOWSEC_UNDERLINE 0x00
#define HEADER_H_OFFSET       0
#define OVERLAY_V_OFFSET_WH   2
#define TEXTOVERLAY_H_OFFSET  0
#define HOMEOVERLAY_H_OFFSET  3

#define COPYRIGHT_SIGN          0x0A
#define COPYRIGHT_H_OFFSET      (VD_WIDTH - 15)
#define COPYRIGHT_V_OFFSET      (VD_HEIGHT - 1)
#define COPYRIGHT_SIGN_H_OFFSET (COPYRIGHT_H_OFFSET - 2)

#define CR_SIGN_LICENSE_H_OFFSET  15
#define CR_SIGN_LICENSE_V_OFFSET   2

#define VERSION_H_OFFSET 20
#define VERSION_V_OFFSET  5

#define BTN_OVERLAY_H_OFFSET  (VD_WIDTH - 12)
#define BTN_OVERLAY_V_OFFSET  (VD_HEIGHT - 5)

#define INFO_OVERLAY_H_OFFSET 2
#define INFO_OVERLAY_V_OFFSET 2
#define INFO_VALS_H_OFFSET    (17 + INFO_OVERLAY_H_OFFSET)
#define INFO_VALS_V_OFFSET    OVERLAY_V_OFFSET_WH

#define INFO_VIN_V_OFFSET     (1 + INFO_VALS_V_OFFSET)
#define INFO_VOUT_V_OFFSET    (2 + INFO_VALS_V_OFFSET)
#define INFO_COL_V_OFFSET     (3 + INFO_VALS_V_OFFSET)
#define INFO_FORMAT_V_OFFSET  (4 + INFO_VALS_V_OFFSET)
#define INFO_DEBLUR_V_OFFSET  (5 + INFO_VALS_V_OFFSET)
#define INFO_FAO_V_OFFSET     (6 + INFO_VALS_V_OFFSET)


static const char *copyright_note =
    "2018 borti4938"; /* 14 chars */

static const char *btn_overlay_0 =
    "A ... Enter\n"
    "B ... Close";

static const char *vinfo_header =
    "N64 Advanced - Video-Info";
static const char *vinfo_overlay =
    "* Video\n"
    "  - Input:\n"
    "  - Output:\n"
    "  - Color Depth:\n"
    "  - Format:\n"
    "* 240p-DeBlur:\n"
    "* Filter AddOn:";

static const char *thanks_overlay =
    "The N64 RGB project would not be what it is with\n"
    "without the contributions many other people.\n"
    "Here, I want to point out especially:\n"
    " - viletim  : First public DIY N64 DAC project\n"
    " - Ikari_01 : Initial implementation of PAL/NTSC\n"
    "              as well as 480i/576i detection\n"
    " - sftwninja: Pushing me to the N64A project\n"
    " - Xenogears: Sponsoring of prototypes\n\n"
    "Visit GitHub:\n"
    "     <https://github.com/borti4938/n64rgb>\n"
    "Any contribution in any kind is highly welcomed!";
  /* 123456789012345678901234567890123456789012345678 */

static const char *about_overlay =
    "The N64 RGB project is open source, i.e.\n"
    "PCB files, HDL and SW sources are provided\n"
    "to you FOR FREE!\n\n"
    "Your version\n"
    " - firmware (HDL):\n"
    " - firmware (SW) :\n\n"
    "Questions / Support:\n"
    " - GitHub: <https://github.com/borti4938/n64rgb>\n"
    " - Email:  <borti4938@gmx.de>";
  /* 123456789012345678901234567890123456789012345678 */

static const char *license_overlay =
    "The N64Advanced is part of the\n"
    "N64 RGB/YPbPr DAC project\n"
    "     Copyright   2015 - 2018 Peter Bartmann\n"
    "This project is published under GNU GPL v3.0 or\n"
    "later. You should have received a copy of the\n"
    "GNU General Public License along with this\n"
    "project. If not, see \n"
    "      <http://www.gnu.org/licenses/>.\n\n"
    "What ever you do, also respect licenses of third\n"
    "party vendors providing the design tools...";
  /* 123456789012345678901234567890123456789012345678  */

static const char *home_header =
    "N64 Advanced - Main Menu";
static const char *home_overlay =
    "[Video-Info]\n"
    "[Configuration]\n"
    "[Miscellaneous]\n\n"
    "About...\n"
    "Acknowledgment...\n"
    "License...";


static const char *OffOn[]        = {"Off","On"};
static const char *VideoMode[]    = {"240p60","288p50","480i60","576i50","480p60","576p50"};
static const char *VideoColor[]   = {"21bit","15bit"};
static const char *VideoFormat[]  = {"RGBS","RGBS/RGsB","YPbPr"};
static const char *DeBlur[]       = {"(estimated)","(forced)","(480i/576i)"};
//static const char *DeBlurCfg[]    = {"Auto","Off","Always"};
static const char *FilterAddOn[]  = {"not installed","9.5MHz","18MHz","Filter bypassed"};
//static const char *SLStrength[]   = {"0%","25%","50%","100%"};
//static const char *GammaValue[]   = {"1.0","0.8","0.9","1.1","1.2"};

#endif /* MENUTEXTS_H_ */
