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

# Arguments: FRONT_TARGET_ID NAME USAGE_TYPE DESCRIPTION AUTHOR SOURCE

FRONT_TARGET_ID="$1"; if [[ ! $FRONT_TARGET_ID -gt 0 ]]; then log_msg_error "invalid value of FRONT_TARGET_ID ($FRONT_TARGET_ID)"; return $CODEARGERR; fi
TARGET_NAME="$2"; if [ ${#TARGET_NAME} -gt 256 ]; then log_msg_error "TARGET_NAME too long ($TARGET_NAME)"; return $CODEARGERR; fi

TARGET_USAGE_TYPE="$3"; if [[ ! $TARGET_USAGE_TYPE =~ ^[ORP]$ ]]; then
  log_msg_error "invalid value of TARGET_USAGE_TYPE ($TARGET_USAGE_TYPE)"; return $CODEARGERR; fi

TARGET_DESC="$4"; if [ ${#TARGET_DESC} -gt 1024 ]; then log_msg_error "TARGET_DESC too long ($TARGET_DESC)"; return $CODEARGERR; fi
TARGET_AUTHOR="$5"; if [ ${#TARGET_AUTHOR} -gt 256 ]; then log_msg_error "TARGET_AUTHOR too long ($TARGET_AUTHOR)"; return $CODEARGERR; fi
TARGET_SOURCE="$6"; if [ ${#TARGET_SOURCE} -gt 256 ]; then log_msg_error "TARGET_SOURCE too long ($TARGET_SOURCE)"; return $CODEARGERR; fi

TARGET_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = $FRONT_TARGET_ID AND entity_type = 'T'" | psql --dbname=hitvisc -qtA)

if [[ $TARGET_ID -gt 0 ]]; then
  PSQL_STATUS=$(echo "UPDATE registry.target SET name = '$TARGET_NAME', usage_type = '$TARGET_USAGE_TYPE', description = '$TARGET_DESC', authors = '$TARGET_AUTHOR', source = '$TARGET_SOURCE' WHERE id = $TARGET_ID" | psql --dbname=hitvisc -qtA)
else
  log_msg_error "unable to update target (cmd: UPDATE registry.target SET name = '$TARGET_NAME', usage_type = '$TARGET_USAGE_TYPE', description = '$TARGET_DESC', authors = '$TARGET_AUTHOR', source = '$TARGET_SOURCE' WHERE id = $TARGET_ID)"; return $CODEPSQLERR; fi
