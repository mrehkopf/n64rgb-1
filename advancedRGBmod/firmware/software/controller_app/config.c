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
 * config.c
 *
 *  Created on: 11.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"
#include "config.h"


#define CFGI_DEFAULT  CFGI_QUICKCHANGE_RSTMASK

#define JUMPERSET_BASE  DEFAULT_CFG_SET_IN_BASE

#define CFG_GAMMA_DEFAULTVAL      5
#define CFG_GAMMA_DEFAULT_SETMASK (CFG_GAMMA_DEFAULTVAL<<CFG_GAMMA_OFFSET)

#define FALLBACK_DEFAULT_CONFIG (                 \
  CFG_GETALL_MASK & ( CFG_USEIGR_SETMASK        | \
                      CFG_GAMMA_DEFAULT_SETMASK | \
                      CFG_RGSB_SETMASK          | \
                      CFG_SLSTR_0_SETMASK         ))
#define DEFAULT0_CONFIG (                      \
  CFG_GETALL_MASK & ( CFG_USEIGR_SETMASK        | \
                      CFG_GAMMA_DEFAULT_SETMASK ))

#define DEFAULT_CFG_ALLMASK           0x3F
#define DEFAULT_CFG_NYPBPR_GETMASK    (1<<CFG_YPBPR_OFFSET)
#define DEFAULT_CFG_NRGSB_GETMASK     (1<<CFG_RGSB_OFFSET)
#define DEFAULT_CFG_NSLSTR_GETMASK    (3<<CFG_SLSTR_OFFSET)
#define DEFAULT_CFG_LINEX2_GETMASK    (1<<CFG_LINEX2_OFFSET)
#define DEFAULT_CFG_N480IBOB_GETMASK  (1<<CFG_480IBOB_OFFSET)
#define DEFAULT_CFG_JUMPERINV_MASK    0x3D  /* inversion due to nature of jumper */


void cfg_inc_value(config_t* cfg_data)
{
  if (cfg_data->cfg_type == FLAG) {
    cfg_toggle_flag(cfg_data);
    return;
  }

  alt_u16 cfg_word = cfg_data->cfg_word->cfg_word_val;
  alt_u16 cur_val = (cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

  cur_val = cur_val == cfg_data->value_details.max_value ? 0 : cur_val + 1;
  cfg_word = (cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);

  cfg_data->cfg_word->cfg_word_val = cfg_word;
};

void cfg_dec_value(config_t* cfg_data)
{
  if (cfg_data->cfg_type == FLAG) {
    cfg_toggle_flag(cfg_data);
    return;
  }

  alt_u16 cfg_word = cfg_data->cfg_word->cfg_word_val;
  alt_u16 cur_val = (cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

  cur_val = cur_val == 0 ? cfg_data->value_details.max_value : cur_val - 1;
  cfg_word = (cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);

  cfg_data->cfg_word->cfg_word_val = cfg_word;
};

alt_u16 cfg_get_value(config_t* cfg_data)
{
  if (cfg_data->cfg_type == FLAG) return ((cfg_data->cfg_word->cfg_word_val & cfg_data->flag_masks.setflag_mask)     >> cfg_data->cfg_word_offset);
  else                            return ((cfg_data->cfg_word->cfg_word_val & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset);
};

void cfg_set_value(config_t* cfg_data, alt_u16 value)
{
  if (cfg_data->cfg_type == FLAG) {
    if (value) cfg_set_flag(cfg_data);
    else       cfg_clear_flag(cfg_data);
  } else {
    alt_u16 cfg_word = cfg_data->cfg_word->cfg_word_val;
    alt_u16 cur_val = value > cfg_data->value_details.max_value ? 0 : value;

    cfg_word = (cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);

    cfg_data->cfg_word->cfg_word_val = cfg_word;
  }
};

void cfg_load_defaults(cfg_word_t* cfg_word,alt_u8 fallback)
{
  if (cfg_word->cfg_word_type == GENERAL) {
    alt_u16 jumperset = (IORD_ALTERA_AVALON_PIO_DATA(JUMPERSET_BASE) ^ DEFAULT_CFG_JUMPERINV_MASK) & DEFAULT_CFG_ALLMASK;

    if(fallback)
      cfg_word->cfg_word_val = FALLBACK_DEFAULT_CONFIG;
    else
      cfg_word->cfg_word_val = (DEFAULT0_CONFIG | jumperset) & CFG_GETALL_MASK;

    cfg_apply_word(cfg_word);
  } else if (cfg_word->cfg_word_type == INTERNAL) {
//    if(fallback)
//      cfg_word->cfg_word_val = CFGI_DEFAULT;
//    else
      cfg_word->cfg_word_val = CFGI_DEFAULT;
  }
}
