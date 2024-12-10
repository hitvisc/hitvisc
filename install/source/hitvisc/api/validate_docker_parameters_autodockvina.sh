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

  if ! [[ $CENTER_X =~ ^[+-]?[0-9]+\.?[0-9]*$ && $CENTER_Y =~ ^[+-]?[0-9]+\.?[0-9]*$ && $CENTER_Z =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
    log_msg_error "invalid value of CENTER_X CENTER_Y CENTER_Z ($CENTER_X $CENTER_Y $CENTER_Z)"; return $CODEARGERR; fi

  if ! [[ $SIZE_X =~ ^[+-]?[0-9]+\.?[0-9]*$ && $SIZE_Y =~ ^[+-]?[0-9]+\.?[0-9]*$ && $SIZE_Z =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
    log_msg_error "invalid value of SIZE_X SIZE_Y SIZE_Z ($SIZE_X $SIZE_Y $SIZE_Z)"; return $CODEARGERR; fi

  # Exhaustiveness of search (1-8, default 8) - thoroughness of search, roughly proportional to time
  if ! [[ "$EXHAUSTIVENESS" =~ ^[0-9]+$ && $EXHAUSTIVENESS -ge 1 && $EXHAUSTIVENESS -le 8 ]]; then
    log_msg_error "invalid value of EXHAUSTIVENESS ($EXHAUSTIVENESS)"; return $CODEARGERR; fi

  # Number of binding modes (1-10, default 9) - maximum number of binding modes to generate
  if ! [[ "$NMODES" =~ ^[0-9]+$ && $NMODES -ge 1 && $NMODES -le 10 ]]; then
    log_msg_error "invalid value of NMODES ($NMODES)"; return $CODEARGERR; fi

  # Maximum energy difference (kcal/mol) (1-3, default 3) - maximum score range
  if ! [[ "$ERANGE" =~ ^[0-9]+$ && $ERANGE -ge 1 && $ERANGE -le 10 ]]; then
    log_msg_error "invalid value of ERANGE ($ERANGE)"; return $CODEARGERR; fi
