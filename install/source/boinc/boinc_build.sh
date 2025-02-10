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

# Script for unpacking and building BOINC server software

# Store input parameters
source_code_archive=${1}
boinc_project_host=${2}
boinc_url_base=${3}
boinc_project_home=${4}
boinc_db_host=${5}
boinc_db_name=${6}
boinc_db_user=${7}
boinc_db_password=${8}
boinc_project_name=${9}
boinc_project_caption=${10}

# Print parameters
echo "Script started with the following parameters:"
echo "source_code_archive   = $source_code_archive"
echo "boinc_project_host    = $boinc_project_host"
echo "boinc_url_base        = $boinc_url_base"
echo "boinc_project_home    = $boinc_project_home"
echo "boinc_db_host         = $boinc_db_host"
echo "boinc_db_name         = $boinc_db_name"
echo "boinc_db_user         = $boinc_db_user"
echo "boinc_db_password     = $boinc_db_password"
echo "boinc_project_name    = $boinc_project_name"
echo "boinc_project_caption = $boinc_project_caption"

# Exctract source code from archive
tar -zxvf $source_code_archive
source_code_directory=$(echo $source_code_archive | sed 's/.tar.gz//g')
cd ./${source_code_directory}

# Build BOINC server software
echo "----------------------------------------------------------------"
echo "--- Starting to build BOINC server"
echo "------------------------------------------------------------------------------------------------"
echo "--- Run autosetup"
echo "------------------------------------------------------------------------------------------------"
./_autosetup

echo "------------------------------------------------------------------------------------------------"
echo "--- Run configure"
echo "------------------------------------------------------------------------------------------------"
./configure --disable-client --disable-manager

echo "------------------------------------------------------------------------------------------------"
echo "--- Run make"
echo "------------------------------------------------------------------------------------------------"
make

echo "------------------------------------------------------------------------------------------------"
echo "--- Run make_project"
echo "------------------------------------------------------------------------------------------------"
cd ./tools/
./make_project --no_query --project_host $boinc_project_host --url_base $boinc_url_base --project_root $boinc_project_home --db_name $boinc_db_name --db_user $boinc_db_user --db_passwd $boinc_db_password --drop_db_first --delete_prev_inst $boinc_project_name $boinc_project_caption

echo "------------------------------------------------------------------------------------------------"
echo "--- Set project and team name into project.inc"
echo "------------------------------------------------------------------------------------------------"
cd ${boinc_project_home}/html/project/
sed -i 's/REPLACE WITH PROJECT NAME/HiT@Roll/g' project.inc
sed -i 's/REPLACE WITH COPYRIGHT HOLDER/Our cool team/g' project.inc

echo "------------------------------------------------------------------------------------------------"
echo "--- Disable caching in cache_parameters.inc"
echo "------------------------------------------------------------------------------------------------"
cd ${boinc_project_home}/html/project/
sed -i "s/define('TEAM_PAGE_TTL', 3600);/define('TEAM_PAGE_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('USER_PAGE_TTL', 3600);/define('USER_PAGE_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('USER_HOST_TTL', 3600);/define('USER_HOST_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('USER_PROFILE_TTL', 3600);/define('USER_PROFILE_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('TOP_PAGES_TTL', 43200);/define('TOP_PAGES_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('INDEX_PAGE_TTL', 3600);/define('INDEX_PAGE_TTL', 0);/g" cache_parameters.inc
sed -i "s/define('STATUS_PAGE_TTL', 3600);/define('STATUS_PAGE_TTL', 0);/g" cache_parameters.inc

echo "------------------------------------------------------------------------------------------------"
echo "--- Set password for operator interface"
echo "------------------------------------------------------------------------------------------------"
cd ${boinc_project_home}/html/ops/
htpasswd -b -c .htpasswd $boinc_db_user $boinc_db_password


echo "boinc_url_base           = $boinc_url_base" >> "/app/hitvisc/main/hitvisc.conf"
echo "boinc_project_name       = $boinc_project_name" >> "/app/hitvisc/main/hitvisc.conf"

