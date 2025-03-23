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

# Arguments: FRONT_SEARCH_ID NAME USAGE_TYPE DESCRIPTION

FRONT_SEARCH_ID="$1"; if [[ ! $FRONT_SEARCH_ID -gt 0 ]]; then log_msg_error "invalid value of FRONT_SEARCH_ID ($FRONT_SEARCH_ID)"; return $CODEARGERR; fi
SEARCH_NAME="$2"; if [ ${#SEARCH_NAME} -gt 256 ]; then log_msg_error "SEARCH_NAME too long ($SEARCH_NAME)"; return $CODEARGERR; fi

SEARCH_USAGE_TYPE="$3"; if [[ ! $SEARCH_USAGE_TYPE =~ ^[ORP]$ ]]; then
  log_msg_error "invalid value of SEARCH_USAGE_TYPE ($SEARCH_USAGE_TYPE)"; return $CODEARGERR; fi

SEARCH_DESC="$4"; if [ ${#SEARCH_DESC} -gt 1024 ]; then log_msg_error "SEARCH_DESC too long ($SEARCH_DESC)"; return $CODEARGERR; fi

SEARCH_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = $FRONT_SEARCH_ID AND entity_type = 'S'" | psql --dbname=hitvisc -qtA)

if [[ $SEARCH_ID -gt 0 ]]; then
  PSQL_STATUS=$(echo "UPDATE registry.search SET name = '$SEARCH_NAME', usage_type = '$SEARCH_USAGE_TYPE', description = '$SEARCH_DESC' WHERE id = $SEARCH_ID" | psql --dbname=hitvisc -qtA)
else
  log_msg_error "unable to update search (cmd: UPDATE registry.search SET name = '$SEARCH_NAME', usage_type = '$SEARCH_USAGE_TYPE', description = '$SEARCH_DESC' WHERE id = $SEARCH_ID)"; return $CODEPSQLERR; fi
