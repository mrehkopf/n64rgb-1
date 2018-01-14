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
 * config.h
 *
 *  Created on: 11.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef CONFIG_H_
#define CONFIG_H_


#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"


extern volatile alt_u16 cfg_data;

#define CFG_SHOWOSD_OFFSET      13
#define CFG_USEIGR_OFFSET       12
#define CFG_DEBLUR_OFFSET       11
#define CFG_FORCEDEBLUR_OFFSET  10
#define CFG_15BITMODE_OFFSET     9
#define CFG_GAMMA_OFFSET         6
  #define CFG_USEGAMMA_OFFSET      8
  #define CFG_GAMMASEL_OFFSET      6
#define CFG_RGSB_OFFSET          5
#define CFG_YPBPR_OFFSET         4
#define CFG_SLSTR_OFFSET         2
  #define CFG_SLMSB_OFFSET         3
  #define CFG_SLLSB_OFFSET         2
#define CFG_LINEX2_OFFSET        1
#define CFG_480IBOB_OFFSET       0

#define CFG_GETALL_MASK           0x3FFF
#define CFG_SHOWOSD_GETMASK       (1<<CFG_SHOWOSD_OFFSET)
#define CFG_SHOWOSD_SETMASK       (1<<CFG_SHOWOSD_OFFSET)
#define CFG_SHOWOSD_CLRMASK       (CFG_GETALL_MASK & ~CFG_SHOWOSD_SETMASK)
#define CFG_USEIGR_GETMASK        (1<<CFG_USEIGR_OFFSET)
#define CFG_USEIGR_SETMASK        (1<<CFG_USEIGR_OFFSET)
#define CFG_USEIGR_CLRMASK        (CFG_GETALL_MASK & ~CFG_USEIGR_SETMASK)
#define CFG_DEBLUR_GETMASK        (1<<CFG_DEBLUR_OFFSET)
#define CFG_DEBLUR_SETMASK        (1<<CFG_DEBLUR_OFFSET)
#define CFG_DEBLUR_CLRMASK        (CFG_GETALL_MASK & ~CFG_DEBLUR_SETMASK)
#define CFG_FORCEDEBLUR_GETMASK   (1<<CFG_FORCEDEBLUR_OFFSET)
#define CFG_FORCEDEBLUR_SETMASK   (1<<CFG_FORCEDEBLUR_OFFSET)
#define CFG_FORCEDEBLUR_CLRMASK   (CFG_GETALL_MASK & ~CFG_FORCEDEBLUR_SETMASK)
#define CFG_15BITMODE_GETMASK     (1<<CFG_15BITMODE_OFFSET)
#define CFG_15BITMODE_SETMASK     (1<<CFG_15BITMODE_OFFSET)
#define CFG_15BITMODE_CLRMASK     (CFG_GETALL_MASK & ~CFG_15BITMODE_SETMASK)
#define CFG_GAMMA_GETMASK         (7<<CFG_GAMMA_OFFSET)
  #define CFG_USEGAMMA_GETMASK      (1<<CFG_USEGAMMA_OFFSET)
  #define CFG_USEGAMMA_SETMASK      (1<<CFG_USEGAMMA_OFFSET)
  #define CFG_GAMMASEL_RSTMASK      (CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK)
  #define CFG_GAMMASEL_GETMASK      (3<<CFG_GAMMASEL_OFFSET)
  #define CFG_GAMMASEL_G3_SETMASK   (3<<CFG_GAMMASEL_OFFSET)
  #define CFG_GAMMASEL_G2_SETMASK   (2<<CFG_GAMMASEL_OFFSET)
  #define CFG_GAMMASEL_G1_SETMASK   (1<<CFG_GAMMASEL_OFFSET)
  #define CFG_GAMMASEL_G0_SETMASK   (0<<CFG_GAMMASEL_OFFSET)
#define CFG_GAMMA_CLRMASK         (CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK)
#define CFG_RGSB_GETMASK          (1<<CFG_RGSB_OFFSET)
#define CFG_RGSB_SETMASK          (1<<CFG_RGSB_OFFSET)
#define CFG_RGSB_CLRMASK          (CFG_GETALL_MASK & ~CFG_RGSB_SETMASK)
#define CFG_YPBPR_GETMASK         (1<<CFG_YPBPR_OFFSET)
#define CFG_YPBPR_SETMASK         (1<<CFG_YPBPR_OFFSET)
#define CFG_YPBPR_CLRMASK         (CFG_GETALL_MASK & ~CFG_YPBPR_SETMASK)
#define CFG_SLSTR_GETMASK         (3<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_RSTMASK         (CFG_GETALL_MASK & ~CFG_SLSTR_GETMASK)
  #define CFG_SLSTR_100_GETMASK     (3<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_100_SETMASK     (3<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_50_GETMASK      (2<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_50_SETMASK      (2<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_25_GETMASK      (1<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_25_SETMASK      (1<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_0_GETMASK       (0<<CFG_SLSTR_OFFSET)
  #define CFG_SLSTR_0_SETMASK       (0<<CFG_SLSTR_OFFSET)
#define CFG_SLSTR_CLRMASK         (CFG_GETALL_MASK & ~CFG_SLSTR_GETMASK)
#define CFG_LINEX2_GETMASK        (1<<CFG_LINEX2_OFFSET)
#define CFG_LINEX2_SETMASK        (1<<CFG_LINEX2_OFFSET)
#define CFG_LINEX2_CLRMASK        (CFG_GETALL_MASK & ~CFG_LINEX2_SETMASK)
#define CFG_480IBOB_GETMASK       (1<<CFG_480IBOB_OFFSET)
#define CFG_480IBOB_SETMASK       (1<<CFG_480IBOB_OFFSET)
#define CFG_480IBOB_CLRMASK       (CFG_GETALL_MASK & ~CFG_480IBOB_SETMASK)


typedef struct {
  alt_u8 cfg_word_offset;
  alt_u8 value;
} config_t;

void cfg_load_defaults();
inline void get_config()
  {  cfg_data = IORD_ALTERA_AVALON_PIO_DATA(CFG_SET_OUT_BASE) & CFG_GETALL_MASK;  };
inline void cfg_apply(void)
  {  IOWR_ALTERA_AVALON_PIO_DATA(CFG_SET_OUT_BASE, (cfg_data & CFG_GETALL_MASK));  };

#endif /* CONFIG_H_ */
