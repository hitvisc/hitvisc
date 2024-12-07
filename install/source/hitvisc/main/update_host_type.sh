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

# Usage:
USAGE_TEMPLATE="update_host_type.sh HITVISC_HOST_ID HITVISC_HOST_TYPE"

# Get the number of arguments from template:
NARGS="$(awk '{print NF-1}' <<< "$USAGE_TEMPLATE")"
if [ "$#" -ne $NARGS ]; then log_msg_error "Wrong number of arguments ($#)"; exit $CODEARGERR; fi

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

## Change venue of BOINC host as the type of HiTViSc host has changed
HITVISC_HOST_ID=$1
if [[ ! $HITVISC_HOST_ID =~ ^-?[0-9]+$ ]] || [[ $HITVISC_HOST_ID -le 0 ]]; then
  log_msg_error "invalid value of HITVISC_HOST_ID ($HITVISC_HOST_ID)"; return $CODEARGERR; fi

HITVISC_HOST_TYPE=$2
if [[ ! $HITVISC_HOST_TYPE =~ ^[RPT]$ ]]; then
  log_msg_error "invalid value of HITVISC_HOST_TYPE ($HITVISC_HOST_TYPE)"; return $CODEARGERR; fi

BOINC_HOST_ID=$(echo "SELECT boinc_host_id FROM registry.host where id = $HITVISC_HOST_ID;" | psql --dbname=hitvisc -qtA)
if [[ ! $BOINC_HOST_ID =~ ^-?[0-9]+$ ]] || [[ $BOINC_HOST_ID -le 0 ]]; then
  log_msg_error "invalid value of BOINC_HOST_ID ($BOINC_HOST_ID)"; return $CODEOTHERERR; fi

unset boinc_venue
case $HITVISC_HOST_TYPE in
    T)
      boinc_venue="work";;
    R)
      boinc_venue="home";;
    P)
      boinc_venue="school";;
esac

if [ ! -z $boinc_venue ]; then
  PSQL_STATUS=$(echo "UPDATE registry.host SET host_usage_type = '$HITVISC_HOST_TYPE' WHERE id = $HITVISC_HOST_ID;" | psql --dbname=hitvisc -qtA)
  MYSQL_STATUS=$(mysql --database=$project_database --user=$project_user --password=$project_password -e "UPDATE host SET venue = '$boinc_venue' WHERE id = $BOINC_HOST_ID;" 2>/dev/null)
fi



