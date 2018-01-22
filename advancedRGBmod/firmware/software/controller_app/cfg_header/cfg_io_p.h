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
 * cfg_io_p.h
 *
 *  Created on: 17.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef CFG_HEADER_CFG_IO_P_H_
#define CFG_HEADER_CFG_IO_P_H_


#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "../config.h"


extern const char *OffOn[];
extern const char *VideoFormat[];
extern const char *DeBlurCfg[];
extern const char *SLStrength[];
extern const char *GammaValue[];

cfg_word_t cfg_data_general =
  { .cfg_word_type = GENERAL,
    .cfg_word_base = CFG_WORD_GENERAL,
    .cfg_word_mask = CFG_GETALL_MASK,
    .cfg_word_val  = 0x0000
  };

config_t show_osd = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_SHOWOSD_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_SHOWOSD_SETMASK,
        .clrflag_mask = CFG_SHOWOSD_CLRMASK
    }
};

config_t igr_reset = {
    .cfg_word = &cfg_data_general,
    .cfg_word_offset = CFG_USEIGR_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_USEIGR_SETMASK,
        .clrflag_mask = CFG_USEIGR_CLRMASK
    },
    .value_string = &OffOn
};

config_t deblur = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_DEBLUR_OFFSET,
    .cfg_type        = VALUE,
    .value_details   = {
        .max_value     = CFG_DEBLUR_MAX_VALUE,
        .getvalue_mask = CFG_DEBLUR_GETMASK,
    },
    .value_string = &DeBlurCfg
};

config_t mode15bit = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_15BITMODE_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_15BITMODE_SETMASK,
        .clrflag_mask = CFG_15BITMODE_CLRMASK
    },
    .value_string = &OffOn
};

config_t gamma_lut = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_GAMMA_OFFSET,
    .cfg_type        = VALUE,
    .value_details   = {
        .max_value     = CFG_GAMMA_MAX_VALUE,
        .getvalue_mask = CFG_GAMMA_GETMASK
    },
    .value_string = &GammaValue
};

config_t vformat = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_VFORMAT_OFFSET,
    .cfg_type        = VALUE,
    .value_details   = {
        .max_value     = CFG_VFORMAT_MAX_VALUE,
        .getvalue_mask = CFG_VFORMAT_GETMASK
    },
    .value_string = &VideoFormat
};

config_t sl_str = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_SLSTR_OFFSET,
    .cfg_type        = VALUE,
    .value_details   = {
        .max_value     = CFG_SLSTR_MAX_VALUE,
        .getvalue_mask = CFG_SLSTR_GETMASK
    },
    .value_string = &SLStrength
};

config_t linex2 = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_LINEX2_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_LINEX2_SETMASK,
        .clrflag_mask = CFG_LINEX2_CLRMASK
    },
    .value_string = &OffOn
};

config_t deint480ibob = {
    .cfg_word        = &cfg_data_general,
    .cfg_word_offset = CFG_480IBOB_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_480IBOB_SETMASK,
        .clrflag_mask = CFG_480IBOB_CLRMASK
    },
    .value_string = &OffOn
};

#endif /* CFG_HEADER_CFG_IO_P_H_ */
