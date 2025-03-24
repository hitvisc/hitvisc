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

# Arguments: FRONT_LIBRARY_ID NAME USAGE_TYPE DESCRIPTION AUTHOR SOURCE

FRONT_LIBRARY_ID="$1"; if [[ ! $FRONT_LIBRARY_ID -gt 0 ]]; then log_msg_error "invalid value of FRONT_LIBRARY_ID ($FRONT_LIBRARY_ID)"; return $CODEARGERR; fi
LIBRARY_NAME="$2"; if [ ${#LIBRARY_NAME} -gt 256 ]; then log_msg_error "LIBRARY_NAME too long ($LIBRARY_NAME)"; return $CODEARGERR; fi

LIBRARY_USAGE_TYPE="$3"; if [[ ! $LIBRARY_USAGE_TYPE =~ ^[ORP]$ ]]; then
  log_msg_error "invalid value of LIBRARY_USAGE_TYPE ($LIBRARY_USAGE_TYPE)"; return $CODEARGERR; fi

LIBRARY_DESC="$4"; if [ ${#LIBRARY_DESC} -gt 1024 ]; then log_msg_error "LIBRARY_DESC too long ($LIBRARY_DESC)"; return $CODEARGERR; fi
LIBRARY_AUTHOR="$5"; if [ ${#LIBRARY_AUTHOR} -gt 256 ]; then log_msg_error "LIBRARY_AUTHOR too long ($LIBRARY_AUTHOR)"; return $CODEARGERR; fi
LIBRARY_SOURCE="$6"; if [ ${#LIBRARY_SOURCE} -gt 256 ]; then log_msg_error "LIBRARY_SOURCE too long ($LIBRARY_SOURCE)"; return $CODEARGERR; fi

LIBRARY_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = $FRONT_LIBRARY_ID AND entity_type = 'L'" | psql --dbname=hitvisc -qtA)

if [[ $LIBRARY_ID -gt 0 ]]; then
  PSQL_STATUS=$(echo "UPDATE registry.library SET name = '$LIBRARY_NAME', usage_type = '$LIBRARY_USAGE_TYPE', description = '$LIBRARY_DESC', authors = '$LIBRARY_AUTHOR', source = '$LIBRARY_SOURCE' WHERE id = $LIBRARY_ID" | psql --dbname=hitvisc -qtA)
else
  log_msg_error "unable to update library (cmd: UPDATE registry.library SET name = '$LIBRARY_NAME', usage_type = '$LIBRARY_USAGE_TYPE', description = '$LIBRARY_DESC', authors = '$LIBRARY_AUTHOR', source = '$LIBRARY_SOURCE' WHERE id = $LIBRARY_ID)"; return $CODEPSQLERR; fi
