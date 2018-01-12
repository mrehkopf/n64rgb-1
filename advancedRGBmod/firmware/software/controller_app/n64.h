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

#ifndef N64_H_
#define N64_H_

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"


extern alt_u32 ctrl_data;
extern alt_u8  info_data;


#define CTRL_A_OFFSET      0
#define CTRL_B_OFFSET      1
#define CTRL_Z_OFFSET      2
#define CTRL_START_OFFSET  3
#define CTRL_DU_OFFSET     4
#define CTRL_DD_OFFSET     5
#define CTRL_DL_OFFSET     6
#define CTRL_DR_OFFSET     7
#define CTRL_L_OFFSET     10
#define CTRL_R_OFFSET     11
#define CTRL_CU_OFFSET    12
#define CTRL_CD_OFFSET    13
#define CTRL_CL_OFFSET    14
#define CTRL_CR_OFFSET    15
#define CTRL_XAXIS_OFFSET 16
#define CTRL_YAXIS_OFFSET 24

#define CTRL_GETALL_MASK          0xFFFFFFFF
#define CTRL_GETALL_DIGITAL_MASK  0x0000FFFF
#define CTRL_GETALL_ANALOG_MASK   0xFFFF0000
#define CTRL_A_GETMASK            (1<<CTRL_A_OFFSET)
#define CTRL_A_SETMASK            (1<<CTRL_A_OFFSET)
#define CTRL_B_GETMASK            (1<<CTRL_B_OFFSET)
#define CTRL_B_SETMASK            (1<<CTRL_B_OFFSET)
#define CTRL_Z_GETMASK            (1<<CTRL_Z_OFFSET)
#define CTRL_Z_SETMASK            (1<<CTRL_Z_OFFSET)
#define CTRL_START_GETMASK        (1<<CTRL_START_OFFSET)
#define CTRL_START_SETMASK        (1<<CTRL_START_OFFSET)
#define CTRL_DU_GETMASK           (1<<CTRL_DU_OFFSET)
#define CTRL_DU_SETMASK           (1<<CTRL_DU_OFFSET)
#define CTRL_DD_GETMASK           (1<<CTRL_DD_OFFSET)
#define CTRL_DD_SETMASK           (1<<CTRL_DD_OFFSET)
#define CTRL_DL_GETMASK           (1<<CTRL_DL_OFFSET)
#define CTRL_DL_SETMASK           (1<<CTRL_DL_OFFSET)
#define CTRL_DR_GETMASK           (1<<CTRL_DR_OFFSET)
#define CTRL_DR_SETMASK           (1<<CTRL_DR_OFFSET)
#define CTRL_L_GETMASK            (1<<CTRL_L_OFFSET)
#define CTRL_L_SETMASK            (1<<CTRL_L_OFFSET)
#define CTRL_R_GETMASK            (1<<CTRL_R_OFFSET)
#define CTRL_R_SETMASK            (1<<CTRL_R_OFFSET)
#define CTRL_CU_GETMASK           (1<<CTRL_CU_OFFSET)
#define CTRL_CU_SETMASK           (1<<CTRL_CU_OFFSET)
#define CTRL_CD_GETMASK           (1<<CTRL_CD_OFFSET)
#define CTRL_CD_SETMASK           (1<<CTRL_CD_OFFSET)
#define CTRL_CL_GETMASK           (1<<CTRL_CL_OFFSET)
#define CTRL_CL_SETMASK           (1<<CTRL_CL_OFFSET)
#define CTRL_CR_GETMASK           (1<<CTRL_CR_OFFSET)
#define CTRL_CR_SETMASK           (1<<CTRL_CR_OFFSET)
#define CTRL_XAXIS_GETMASK        (0xFF<<CTRL_XAXIS_OFFSET)
#define CTRL_YAXIS_GETMASK        (0xFF<<CTRL_YAXIS_OFFSET)


#define BTN_OPEN_OSDMENU  (CTRL_L_SETMASK|CTRL_R_SETMASK|CTRL_DR_SETMASK|CTRL_CR_SETMASK)
#define BTN_CLOSE_OSDMENU (CTRL_L_SETMASK|CTRL_R_SETMASK|CTRL_DL_SETMASK|CTRL_CL_SETMASK)

#define BTN_DEBLUR_QUICK_ON   (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CR_SETMASK)
#define BTN_DEBLUR_QUICK_OFF  (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CL_SETMASK)
#define BTN_15BIT_QUICK_ON    (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CU_SETMASK)
#define BTN_15BIT_QUICK_OFF   (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CD_SETMASK)

#define BTN_MENU_ENTER  CTRL_A_SETMASK
#define BTN_MENU_BACK   CTRL_B_SETMASK


#define INFO_480I_OFFSET          5
#define INFO_VMODE_OFFSET         4
#define INFO_DODEBLUR_OFFSET     3
#define INFO_USEVGA_OFFSET        2
#define INFO_FILTERNBYPASS_OFFSET 1
#define INFO_FALLBACKMODE         0

#define INFO_GETALL_MASK            0x3F
#define INFO_480I_GETMASK           (1<<INFO_480I_OFFSET)
//#define INFO_480I_SETMASK           (1<<INFO_480I_OFFSET)
//#define INFO_480I_CLRMASK           (INFO_GETALL_MASK & ~INFO_480I_SETMASK)
#define INFO_VMODE_GETMASK          (1<<INFO_VMODE_OFFSET)
//#define INFO_VMODE_SETMASK          (1<<INFO_VMODE_OFFSET)
//#define INFO_VMODE_CLRMASK          (INFO_GETALL_MASK & ~INFO_VMODE_SETMASK)
#define INFO_DODEBLUR_GETMASK      (1<<INFO_DODEBLUR_OFFSET)
//#define INFO_DODEBLUR_SETMASK      (1<<INFO_DODEBLUR_OFFSET)
//#define INFO_DODEBLUR_CLRMASK      (INFO_GETALL_MASK & ~INFO_DODEBLUR_SETMASK)
#define INFO_USEVGA_GETMASK         (1<<INFO_USEVGA_OFFSET)
//#define INFO_USEVGA_SETMASK         (1<<INFO_USEVGA_OFFSET)
//#define INFO_USEVGA_CLRMASK         (INFO_GETALL_MASK & ~INFO_USEVGA_SETMASK)
#define INFO_FILTERNBYPASS_GETMASK  (1<<INFO_FILTERNBYPASS_OFFSET)
//#define INFO_FILTERNBYPASS_SETMASK  (1<<INFO_FILTERNBYPASS_OFFSET)
//#define INFO_FILTERNBYPASS_CLRMASK  (INFO_GETALL_MASK & ~INFO_FILTERNBYPASS_SETMASK)
#define INFO_FALLBACKMODE_GETMASK   (1<<INFO_FALLBACKMODE)
//#define INFO_FALLBACKMODE_SETMASK   (1<<INFO_FALLBACKMODE)
//#define INFO_FALLBACKMODE_CLRMASK   (INFO_GETALL_MASK & ~INFO_FALLBACKMODE_SETMASK)


typedef enum {
  CMD_NON = 0,
  CMD_OPEN_MENU,
  CMD_CLOSE_MENU,
  CMD_DEBLUR_QUICK_ON,
  CMD_DEBLUR_QUICK_OFF,
  CMD_15BIT_QUICK_ON,
  CMD_15BIT_QUICK_OFF,
  CMD_CFG_SAVE,
  CMD_CFG_DEFAULT,
  CMD_CFG_RELOAD,
  CMD_MENU_ENTER,
  CMD_MENU_BACK,
  CMD_MENU_UP,
  CMD_MENU_DOWN,
  CMD_MENU_LEFT,
  CMD_MENU_RIGHT
} cmd_t;


cmd_t ctrl_data_to_cmd();
inline void get_ctrl_data()
  {  ctrl_data = IORD_ALTERA_AVALON_PIO_DATA(CTRL_DATA_IN_BASE);  };
inline void get_info_data()
  {  info_data = IORD_ALTERA_AVALON_PIO_DATA(INFO_SET_IN_BASE) & INFO_GETALL_MASK;  };

#endif /* N64_H_ */
