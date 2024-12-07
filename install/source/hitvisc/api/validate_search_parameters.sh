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

if [[ ! $CRIT_HIT =~ ^[NF]$ ]]; then
  log_msg_error "invalid value of CRIT_HIT ($CRIT_HIT)"; return $CODEARGERR; fi

if [ "$BIND_EN" != "NULL" ] && [[ ! $BIND_EN =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
  log_msg_error "invalid value of BIND_EN ($BIND_EN)"; return $CODEARGERR; fi

if [ "$LIG_EFF" != "NULL" ] && [[ ! $LIG_EFF =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
  log_msg_error "invalid value of LIG_EFF ($LIG_EFF)"; return $CODEARGERR; fi

if [[ ! $CRIT_STOP =~ ^[LHF]$ ]]; then
  log_msg_error "invalid value of CRIT_STOP ($CRIT_STOP)"; return $CODEARGERR; fi

if [ "$PCENT_LIG_TESTED" != "NULL" ] && (($(echo $PCENT_LIG_TESTED | awk '{if ($1 < 0.0 || $1 > 1.0) print 1;}'))); then
  log_msg_error "invalid value of PCENT_LIG_TESTED ($PCENT_LIG_TESTED)"; return $CODEARGERR; fi

if [ "$N_HITS_FOUND" != "NULL" ] && (($(echo $N_HITS_FOUND | awk '{if ($1 < 0.0) print 1;}'))); then
  log_msg_error "invalid value of N_HITS_FOUND ($N_HITS_FOUND)"; return $CODEARGERR; fi

if [ "$PCENT_HITS" != "NULL" ] && (($(echo $PCENT_HITS | awk '{if ($1 < 0.0 || $1 > 1.0) print 1;}'))); then
  log_msg_error "invalid value of PCENT_HITS ($PCENT_HITS)"; return $CODEARGERR; fi

if [[ ! $t_is_notify_hits =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of t_is_notify_hits ($t_is_notify_hits)"; return $CODEARGERR; fi
NOTIFY_HITS=$([ "$t_is_notify_hits" == 'Y' ] && echo "TRUE" || echo "FALSE")

if [[ ! $t_is_notify_fr_ligs =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of t_is_notify_fr_ligs ($t_is_notify_fr_ligs)"; return $CODEARGERR; fi
NOTIFY_LIGS=$([ "$t_is_notify_fr_ligs" == 'Y' ] && echo "TRUE" || echo "FALSE")

if [ "$NOTIFY_N_LIGS" != "NULL" ] && (($(echo $NOTIFY_N_LIGS | awk '{if ($1 < 0.0 || $1 > 1.0) print 1;}'))); then
  log_msg_error "invalid value of NOTIFY_N_LIGS ($NOTIFY_N_LIGS)"; return $CODEARGERR; fi

