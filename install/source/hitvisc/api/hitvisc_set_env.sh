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

# Read database connection parameters
postgresql_environment="/app/postgresql/_environment"
postgresql_instance_name="HiTViSc"
# Store current directory
api_root=$(pwd)

# Set the environment
cd $postgresql_environment
. ./env.sh &>/dev/null <<TEXT
$postgresql_instance_name
TEXT
cd $api_root

function log_msg_error() { # arguments: message 
  log_msg_err='$(date +"%Y-%m-%d %H:%M:%S") $script_name error: $msg'
  msg="$1"
  script_name="${BASH_SOURCE[1]}"
  log_msg_str=$(eval "echo ${log_msg_err} >> $hitvisc_log_dir/api.log")
}
