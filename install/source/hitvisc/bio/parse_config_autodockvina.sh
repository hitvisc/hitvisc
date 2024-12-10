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

config_file="$1"

if [ ! -f "$config_file" ]; then log_msg_error "AutoDock Vina config file was not found ($config_file)"; return $CODEARGERR; fi

while read -ra line
do 
  if [ "${line[1]}" = "=" ]
  then  
    case ${line[0]} in
     center_x)
        CENTER_X=${line[2]};;
     center_y)
        CENTER_Y=${line[2]};;
     center_z)
        CENTER_Z=${line[2]};;
     size_x)
        SIZE_X=${line[2]};;
     size_y)
        SIZE_Y=${line[2]};;
     size_z)
        SIZE_Z=${line[2]};;
     exhaustiveness)
        EXHAUSTIVENESS=${line[2]};;
     nmodes) 
        NMODES=${line[2]};;
     erange)
        ERANGE=${line[2]};;
    esac
  fi
done < "$config_file"

