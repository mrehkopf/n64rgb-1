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


typedef enum {
  GENERAL,
  INTERNAL
} cfg_word_type_t;

typedef struct {
  const cfg_word_type_t cfg_word_type;
  const alt_u32         cfg_word_base;
  const alt_u16         cfg_word_mask;
  alt_u16               cfg_word_val;
} cfg_word_t;

typedef enum {
  FLAG,
  VALUE
} config_type_t;

typedef struct {
  alt_u16 setflag_mask;
  alt_u16 clrflag_mask;
} config_flag_t;

typedef struct {
  alt_u16 max_value;
  alt_u16 getvalue_mask;
} config_value_t;

typedef struct {
  cfg_word_t          *cfg_word;
  const alt_u8        cfg_word_offset;
  const config_type_t cfg_type;
  union {
    const config_flag_t  flag_masks;
    const config_value_t value_details;
  };
  const char*         *value_string;
} config_t;

#define CFGI_QUICKCHANGE_MAX_VALUE  3
#define CFGI_QUICKCHANGE_OFFSET     0
  #define CFGI_QU15BITMODE_OFFSET     1
  #define CFGI_QUDEBLUR_OFFSET        0

#define CFGI_GETALL_MASK      0x3
#define CFGI_QUICKCHANGE_GETMASK  (0x3<<CFGI_QUICKCHANGE_OFFSET)
  #define CFGI_QUICKCHANGE_RSTMASK  (CFGI_GETALL_MASK & ~CFGI_QUICKCHANGE_GETMASK)
  #define CFGI_QU15BITMODE_SETMASK  (1<<CFGI_QU15BITMODE_OFFSET)
  #define CFGI_QU15BITMODE_GETMASK  (1<<CFGI_QU15BITMODE_OFFSET)
  #define CFGI_QU15BITMODE_CLRMASK  (CFGI_GETALL_MASK & ~CFGI_QU15BITMODE_SETMASK)
  #define CFGI_QUDEBLUR_SETMASK     (1<<CFGI_QUDEBLUR_OFFSET)
  #define CFGI_QUDEBLUR_GETMASK     (1<<CFGI_QUDEBLUR_OFFSET)
  #define CFGI_QUDEBLUR_CLRMASK     (CFGI_GETALL_MASK & ~CFGI_QUDEBLUR_SETMASK)

#define CFG_WORD_GENERAL  CFG_SET_OUT_BASE

#define CFG_SLSTR_MAX_VALUE     3
#define CFG_GAMMA_MAX_VALUE     8
#define CFG_VFORMAT_MAX_VALUE   2
#define CFG_DEBLUR_MAX_VALUE    2

#define CFG_SHOWOSD_OFFSET      14
#define CFG_USEIGR_OFFSET       13
#define CFG_DEBLUR_OFFSET       11
#define CFG_15BITMODE_OFFSET    10
#define CFG_GAMMA_OFFSET         6
#define CFG_VFORMAT_OFFSET       4
  #define CFG_YPBPR_OFFSET         5
  #define CFG_RGSB_OFFSET          4
#define CFG_SLSTR_OFFSET         2
  #define CFG_SLMSB_OFFSET         3
  #define CFG_SLLSB_OFFSET         2
#define CFG_LINEX2_OFFSET        1
#define CFG_480IBOB_OFFSET       0

#define CFG_GETALL_MASK           0x7FFF
#define CFG_SHOWOSD_GETMASK       (1<<CFG_SHOWOSD_OFFSET)
#define CFG_SHOWOSD_SETMASK       (1<<CFG_SHOWOSD_OFFSET)
#define CFG_SHOWOSD_CLRMASK       (CFG_GETALL_MASK & ~CFG_SHOWOSD_SETMASK)
#define CFG_USEIGR_GETMASK        (1<<CFG_USEIGR_OFFSET)
#define CFG_USEIGR_SETMASK        (1<<CFG_USEIGR_OFFSET)
#define CFG_USEIGR_CLRMASK        (CFG_GETALL_MASK & ~CFG_USEIGR_SETMASK)
#define CFG_DEBLUR_GETMASK        (3<<CFG_DEBLUR_OFFSET)
#define CFG_DEBLUR_RSTMASK        (CFG_GETALL_MASK & ~CFG_DEBLUR_GETMASK)
#define CFG_DEBLUR_CLRMASK        (CFG_GETALL_MASK & ~CFG_DEBLUR_GETMASK)
#define CFG_15BITMODE_GETMASK     (1<<CFG_15BITMODE_OFFSET)
#define CFG_15BITMODE_SETMASK     (1<<CFG_15BITMODE_OFFSET)
#define CFG_15BITMODE_CLRMASK     (CFG_GETALL_MASK & ~CFG_15BITMODE_SETMASK)
#define CFG_GAMMA_GETMASK         (0xF<<CFG_GAMMA_OFFSET)
  #define CFG_GAMMASEL_RSTMASK      (CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK)
#define CFG_GAMMA_CLRMASK         (CFG_GETALL_MASK & ~CFG_GAMMA_GETMASK)
#define CFG_VFORMAT_GETMASK       (3<<CFG_VFORMAT_OFFSET)
#define CFG_VFORMAT_RSTMASK       (CFG_GETALL_MASK & ~CFG_VFORMAT_GETMASK)
#define CFG_VFORMAT_CLRMASK       (CFG_GETALL_MASK & ~CFG_VFORMAT_GETMASK)
  #define CFG_YPBPR_GETMASK         (1<<CFG_YPBPR_OFFSET)
  #define CFG_YPBPR_SETMASK         (1<<CFG_YPBPR_OFFSET)
  #define CFG_YPBPR_CLRMASK         (CFG_GETALL_MASK & ~CFG_YPBPR_SETMASK)
  #define CFG_RGSB_GETMASK          (1<<CFG_RGSB_OFFSET)
  #define CFG_RGSB_SETMASK          (1<<CFG_RGSB_OFFSET)
  #define CFG_RGSB_CLRMASK          (CFG_GETALL_MASK & ~CFG_RGSB_SETMASK)
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


inline void cfg_toggle_flag(config_t* cfg_data)
  {  if (cfg_data->cfg_type == FLAG) cfg_data->cfg_word->cfg_word_val ^= cfg_data->flag_masks.setflag_mask;  };
inline void cfg_set_flag(config_t* cfg_data)
  {  if (cfg_data->cfg_type == FLAG) cfg_data->cfg_word->cfg_word_val |= cfg_data->flag_masks.setflag_mask;  };
inline void cfg_clear_flag(config_t* cfg_data)
  {  if (cfg_data->cfg_type == FLAG) cfg_data->cfg_word->cfg_word_val &= cfg_data->flag_masks.clrflag_mask;  };
void cfg_inc_value(config_t* cfg_data);
void cfg_dec_value(config_t* cfg_data);
alt_u16 cfg_get_value(config_t* cfg_data);
void cfg_set_value(config_t* cfg_data, alt_u16 value);
void cfg_load_defaults(cfg_word_t* cfg_word,alt_u8 fallback);
inline alt_u16 cfg_get_word(alt_u32 cfg_word_base)
  {  return IORD_ALTERA_AVALON_PIO_DATA(cfg_word_base) & CFG_GETALL_MASK;  };
inline void cfg_apply_word(cfg_word_t* cfg_word)
  {  IOWR_ALTERA_AVALON_PIO_DATA(cfg_word->cfg_word_base, (cfg_word->cfg_word_val & cfg_word->cfg_word_mask));  };
inline void cfg_apply_value(config_t* cfg_data)
  {  IOWR_ALTERA_AVALON_PIO_DATA(cfg_data->cfg_word->cfg_word_base, (cfg_data->cfg_word->cfg_word_val & cfg_data->cfg_word->cfg_word_mask));  };

#endif /* CONFIG_H_ */
