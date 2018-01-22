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
 * cfg_intern_p.h
 *
 *  Created on: 19.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef CFG_HEADER_CFG_INTERNAL_P_H_
#define CFG_HEADER_CFG_INTERNAL_P_H_


#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "../config.h"


extern const char *QuickChange[];

cfg_word_t cfg_data_internal =
  { .cfg_word_type = INTERNAL,
    .cfg_word_mask = CFGI_GETALL_MASK,
    .cfg_word_val  = 0x0000
  };

config_t igr_quickchange = {
    .cfg_word        = &cfg_data_internal,
    .cfg_word_offset = CFGI_QUICKCHANGE_OFFSET,
    .cfg_type        = VALUE,
    .value_details   = {
        .max_value     = CFGI_QUICKCHANGE_MAX_VALUE,
        .getvalue_mask = CFGI_QUICKCHANGE_GETMASK,
    },
    .value_string = &QuickChange
};


#endif /* CFG_HEADER_CFG_INTERNAL_P_H_ */
