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

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

## Get new HiTViSc users and create BOINC users for them
while IFS='|' read -r id email name; do
  HITVISC_USER_ID="$id"
  BOINC_USER_EMAIL="$email"
  BOINC_USER_NAME="$name"
  BOINC_USER_PASSWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
  BOINC_USER_PASSWD_HASH=$(php $DIR/../main/get_boinc_password_hash.php $BOINC_USER_PASSWD $BOINC_USER_EMAIL)
  if [ $? -ne 0 ]; then log_msg_error "Failed to generate a password for BOINC user"; return $CODEOTHERERR; fi
  BOINC_USER_AUTHENTICATOR=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)

  mysql --database=$project_database --user=$project_user --password=$project_password &>/dev/null<<QUERY
INSERT INTO user(create_time, email_addr, name, passwd_hash, authenticator, total_credit, expavg_credit, expavg_time, teamid, venue, send_email, show_hosts, posts, seti_id, seti_nresults, seti_last_result_time, seti_total_cpu, has_profile, cross_project_id, email_validated, donated, project_prefs) VALUES(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()), '$BOINC_USER_EMAIL', '$BOINC_USER_NAME', '$BOINC_USER_PASSWD_HASH', '$BOINC_USER_AUTHENTICATOR', 0, 0, 0, 0, 'home', 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, LOAD_FILE('/var/lib/mysql-files/hitvisc_project_prefs.xml'));
QUERY
  
  BOINC_USER_ID=$(mysql --database=$project_database --user=$project_user --password=$project_password -s -N -e "SELECT id FROM user WHERE email_addr LIKE '$BOINC_USER_EMAIL';" 2>/dev/null)
  if [[ "$BOINC_USER_ID" =~ ^-?[0-9]+$ && "$BOINC_USER_ID" -gt 0 ]]; then
    PSQL_STATUS=$(echo "UPDATE registry.user SET boinc_user_id = $BOINC_USER_ID, boinc_authenticator = '$BOINC_USER_AUTHENTICATOR', 
                        boinc_password = '$BOINC_USER_PASSWD' WHERE id = $HITVISC_USER_ID;" | psql --dbname=hitvisc -qtA)
  else
    log_msg_error "Failed to create BOINC user for HiTViSc user with id = $HITVISC_USER_ID."
  fi

done < <(echo "SELECT id, email, name FROM registry.user WHERE boinc_user_id IS NULL;" | psql --dbname=hitvisc -qtA)

