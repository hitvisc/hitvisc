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
     project_directory)
        project_directory=${line[2]};;
     boinc_results_dir)
        boinc_results_dir=${line[2]};;
     boinc_user_email)
        boinc_user_email=${line[2]};;
     boinc_user_name)
        boinc_user_name=${line[2]};;
     boinc_user_passwd_hash)
        boinc_user_passwd_hash=${line[2]};;
     boinc_user_authenticator)
        boinc_user_authenticator=${line[2]};;
     hitvisc_api_dir)
        hitvisc_api_dir=${line[2]};;
     hitvisc_main_dir)
        hitvisc_main_dir=${line[2]};;
     hitvisc_data_dir)
        hitvisc_data_dir=${line[2]};;
     hitvisc_bio_dir)
        hitvisc_bio_dir=${line[2]};;
     hitvisc_log_dir)
        hitvisc_log_dir=${line[2]};;
     hitvisc_tmp_dir)
        hitvisc_tmp_dir=${line[2]};;
    esac
  fi
done < "$config_file"

