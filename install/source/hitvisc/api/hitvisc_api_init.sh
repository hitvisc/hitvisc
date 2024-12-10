#!/bin/bash
#
#    Copyright (C) 2024 HiTViSc Contributors
#    Contact e-mail: hitvisc@yandex.ru    
#
#    GNU GENERAL PUBLIC LICENSE
#    Version 3, 29 June 2007
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <https://www.gnu.org/licenses/>.

source "$DIR/../api/hitvisc_error_codes.sh"
source "$DIR/../api/hitvisc_set_env.sh"
source "$DIR/../main/hitvisc_parse_config.sh"

if [ ! -d "$hitvisc_api_dir" ]; then log_msg_error "hitvisc_api_dir ($hitvisc_api_dir) does not exist"; exit 1; fi
if [ ! -d "$hitvisc_main_dir" ]; then log_msg_error "hitvisc_main_dir ($hitvisc_main_dir) does not exist"; exit 1; fi
if [ ! -d "$hitvisc_data_dir" ]; then log_msg_error "hitvisc_data_dir ($hitvisc_data_dir) does not exist"; exit 1; fi
if [ ! -d "$hitvisc_bio_dir" ]; then log_msg_error "hitvisc_bio_dir ($hitvisc_bio_dir) does not exist"; exit 1; fi
if [ ! -d "$hitvisc_log_dir" ]; then log_msg_error "hitvisc_log_dir ($hitvisc_log_dir) does not exist"; exit 1; fi
if [ ! -d "$hitvisc_tmp_dir" ]; then log_msg_error "hitvisc_tmp_dir ($hitvisc_tmp_dir) does not exist"; exit 1; fi
if [ ! -d "$boinc_results_dir" ]; then log_msg_error "boinc_results_dir ($boinc_results_dir) does not exist"; exit 1; fi

