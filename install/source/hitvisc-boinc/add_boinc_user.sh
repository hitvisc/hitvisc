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

config_file="/app/hitvisc/main/hitvisc.conf"

while read -ra line
do 
  if [ "${line[1]}" = "=" ]
  then  
    case ${line[0]} in
     project_database)
        project_database=${line[2]};;
     project_user)
        project_user=${line[2]};;
     project_password)
        project_password=${line[2]};;
     boinc_user_email)
        boinc_user_email=${line[2]};;
     boinc_user_name)
        boinc_user_name=${line[2]};;
     boinc_user_passwd_hash)
        boinc_user_passwd_hash=${line[2]};;
     boinc_user_authenticator)
        boinc_user_authenticator=${line[2]};;
    esac
  fi
done < "$config_file"

mysql --database=$project_database --user=$project_user --password=$project_password <<QUERY
INSERT INTO user(create_time, email_addr, name, passwd_hash, authenticator, total_credit, expavg_credit, expavg_time, teamid, venue, send_email, show_hosts, posts, seti_id, seti_nresults, seti_last_result_time, seti_total_cpu, has_profile, cross_project_id, email_validated, donated, project_prefs) VALUES(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()), '$boinc_user_email', '$boinc_user_name', '$boinc_user_passwd_hash', '$boinc_user_authenticator', 0, 0, 0, 0, 'home', 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, LOAD_FILE('/var/lib/mysql-files/hitvisc_project_prefs.xml'));
QUERY
