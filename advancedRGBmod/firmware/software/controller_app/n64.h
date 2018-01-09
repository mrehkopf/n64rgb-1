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
extern alt_u16 cfg_data;


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

#define CTRL_GETALL_MASK    0xFFFFFFFF
#define CTRL_A_GETMASK      1<<CTRL_A_OFFSET
#define CTRL_B_GETMASK      1<<CTRL_B_OFFSET
#define CTRL_Z_GETMASK      1<<CTRL_Z_OFFSET
#define CTRL_START_GETMASK  1<<CTRL_START_OFFSET
#define CTRL_DU_GETMASK     1<<CTRL_DU_OFFSET
#define CTRL_DD_GETMASK     1<<CTRL_DD_OFFSET
#define CTRL_DL_GETMASK     1<<CTRL_DL_OFFSET
#define CTRL_DR_GETMASK     1<<CTRL_DR_OFFSET
#define CTRL_L_GETMASK      1<<CTRL_L_OFFSET
#define CTRL_R_GETMASK      1<<CTRL_R_OFFSET
#define CTRL_CU_GETMASK     1<<CTRL_CU_OFFSET
#define CTRL_CD_GETMASK     1<<CTRL_CD_OFFSET
#define CTRL_CL_GETMASK     1<<CTRL_CL_OFFSET
#define CTRL_CR_GETMASK     1<<CTRL_CR_OFFSET
#define CTRL_XAXIS_GETMASK  0xFF<<CTRL_XAXIS_OFFSET
#define CTRL_YAXIS_GETMASK  0xFF<<CTRL_YAXIS_OFFSET

#define CFG_NDEBLUR_OFFSET      11
#define CFG_NFORCEDEBLUR_OFFSET 10
#define CFG_N15BIT_OFFSET        9
#define CFG_GAMMA_OFFSET         6
  #define CFG_USEGAMMA_OFFSET      8
  #define CFG_GAMMASEL_OFFSET      6
#define CFG_NRGSB_OFFSET         5
#define CFG_NYPBPR_OFFSET        4
#define CFG_SLSTR_OFFSET         2
  #define CFG_SLMSB_OFFSET         3
  #define CFG_SLLSB_OFFSET         2
#define CFG_N240P_OFFSET         1
#define CFG_N480IBOB_OFFSET      0

#define CFG_GETALL_MASK           0xFFF
#define CFG_NDEBLUR_GETMASK       1<<CFG_NDEBLUR_OFFSET
#define CFG_NDEBLUR_SETMASK       1<<CFG_NDEBLUR_OFFSET
#define CFG_NDEBLUR_CLRMASK       CFG_GETALL_MASK & ~CFG_NDEBLUR_SETMASK
#define CFG_NFORCEDEBLUR_GETMASK  1<<CFG_NFORCEDEBLUR_OFFSET
#define CFG_NFORCEDEBLUR_SETMASK  1<<CFG_NFORCEDEBLUR_OFFSET
#define CFG_NFORCEDEBLUR_CLRMASK  CFG_GETALL_MASK & ~CFG_NFORCEDEBLUR_SETMASK
#define CFG_N15BIT_GETMASK        1<<CFG_N15BIT_OFFSET
#define CFG_N15BIT_SETMASK        1<<CFG_N15BIT_OFFSET
#define CFG_N15BIT_CLRMASK        CFG_GETALL_MASK & ~CFG_N15BIT_SETMASK
#define CFG_GAMMA_GETMASK         7<<CFG_GAMMA_OFFSET
  #define CFG_USEGAMMA_GETMASK      1<<CFG_USEGAMMA_OFFSET
  #define CFG_USEGAMMA_SETMASK      1<<CFG_USEGAMMA_OFFSET
  #define CFG_GAMMASEL_RSTMASK      CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK
  #define CFG_GAMMASEL_GETMASK      3<<CFG_GAMMASEL_OFFSET
  #define CFG_GAMMASEL_G3_SETMASK   3<<CFG_GAMMASEL_OFFSET
  #define CFG_GAMMASEL_G2_SETMASK   2<<CFG_GAMMASEL_OFFSET
  #define CFG_GAMMASEL_G1_SETMASK   1<<CFG_GAMMASEL_OFFSET
  #define CFG_GAMMASEL_G0_SETMASK   0<<CFG_GAMMASEL_OFFSET
#define CFG_GAMMA_CLRMASK         CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK
#define CFG_NRGSB_GETMASK         1<<CFG_NRGSB_OFFSET
#define CFG_NRGSB_SETMASK         1<<CFG_NRGSB_OFFSET
#define CFG_NRGSB_CLRMASK         CFG_GETALL_MASK & ~CFG_NRGSB_SETMASK
#define CFG_NYPBPR_GETMASK        1<<CFG_NYPBPR_OFFSET
#define CFG_NYPBPR_SETMASK        1<<CFG_NYPBPR_OFFSET
#define CFG_NYPBPR_CLRMASK        CFG_GETALL_MASK & ~CFG_NYPBPR_SETMASK
#define CFG_SLSTR_GETMASK         3<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_RSTMASK         CFG_GETALL_MASK & ~CFG_SLSTR_GETMASK
  #define CFG_SLSTR_100_GETMASK     3<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_100_SETMASK     3<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_50_GETMASK      2<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_50_SETMASK      2<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_25_GETMASK      1<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_25_SETMASK      1<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_0_GETMASK       0<<CFG_SLSTR_OFFSET
  #define CFG_SLSTR_0_SETMASK       0<<CFG_SLSTR_OFFSET
#define CFG_SLSTR_CLRMASK         CFG_GETALL_MASK & ~CFG_SLSTR_GETMASK
#define CFG_N240P_GETMASK         1<<CFG_N240P_OFFSET
#define CFG_N240P_SETMASK         1<<CFG_N240P_OFFSET
#define CFG_N240P_CLRMASK         CFG_GETALL_MASK & ~CFG_N240P_SETMASK
#define CFG_N480IBOB_GETMASK      1<<CFG_N480IBOB_OFFSET
#define CFG_N480IBOB_SETMASK      1<<CFG_N480IBOB_OFFSET
#define CFG_N480IBOB_CLRMASK      CFG_GETALL_MASK & ~CFG_N480IBOB_SETMASK


#define INFO_OSDOPEN_OFFSET       5
#define INFO_480I_OFFSET          4
#define INFO_VMODE_OFFSET         3
#define INFO_NDODEBLUR_OFFSET     2
#define INFO_USEVGA_OFFSET        1
#define INFO_FILTERNBYPASS_OFFSET 0

#define INFO_GETALL_MASK            0x3F
#define INFO_OSDOPEN_GETMASK        1<<INFO_OSDOPEN_OFFSET
#define INFO_OSDOPEN_SETMASK        1<<INFO_OSDOPEN_OFFSET
#define INFO_OSDOPEN_CLRMASK        INFO_GETALL_MASK & ~INFO_OSDOPEN_SETMASK
#define INFO_480I_GETMASK           1<<INFO_480I_OFFSET
#define INFO_480I_SETMASK           1<<INFO_480I_OFFSET
#define INFO_480I_CLRMASK           INFO_GETALL_MASK & ~INFO_480I_SETMASK
#define INFO_VMODE_GETMASK          1<<INFO_VMODE_OFFSET
#define INFO_VMODE_SETMASK          1<<INFO_VMODE_OFFSET
#define INFO_VMODE_CLRMASK          INFO_GETALL_MASK & ~INFO_VMODE_SETMASK
#define INFO_NDODEBLUR_GETMASK      1<<INFO_NDODEBLUR_OFFSET
#define INFO_NDODEBLUR_SETMASK      1<<INFO_NDODEBLUR_OFFSET
#define INFO_NDODEBLUR_CLRMASK      INFO_GETALL_MASK & ~INFO_NDODEBLUR_SETMASK
#define INFO_USEVGA_GETMASK         1<<INFO_USEVGA_OFFSET
#define INFO_USEVGA_SETMASK         1<<INFO_USEVGA_OFFSET
#define INFO_USEVGA_CLRMASK         INFO_GETALL_MASK & ~INFO_USEVGA_SETMASK
#define INFO_FILTERNBYPASS_GETMASK  1<<INFO_FILTERNBYPASS_OFFSET
#define INFO_FILTERNBYPASS_SETMASK  1<<INFO_FILTERNBYPASS_OFFSET
#define INFO_FILTERNBYPASS_CLRMASK  INFO_GETALL_MASK & ~INFO_FILTERNBYPASS_SETMASK

void get_all_data(void);
void get_ctrl_data(void);
void get_info_data(void);
void get_config(void);

#endif /* N64_H_ */
