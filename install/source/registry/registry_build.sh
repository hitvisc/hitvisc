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

# ---------------------------------------------------------------
# Run scripts for creating HiTViSc registry database
# ---------------------------------------------------------------

# Read input parameters
postgresql_environment=${1}
postgresql_instance_name=${2}

# Print input parameters
echo "------------------------------------------------------------------------------------------------"
echo "--- Script started with the following parameters"
echo "------------------------------------------------------------------------------------------------"
echo "postgresql_environment   = $postgresql_environment"
echo "postgresql_instance_name = $postgresql_instance_name"

# Store current directory
build_root=$PWD

# Set the environment
cd $postgresql_environment
. ./env.sh <<TEXT
$postgresql_instance_name
TEXT

# Return into build root
cd $build_root

# Create Owner role, database and administrator account
echo "------------------------------------------------------------------------------------------------"
echo "--- Create role, database and user"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=postgres -f ./scripts/00_database/create_db.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- Create extensions"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc -f ./scripts/01_extensions/extensions.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- Create schema objects like tables, views and related"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/02_tables/create_registry.sql
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/02_tables/create_docking_data.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- Create functions"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/03_functions/create_functions.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- Insert initial data"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/04_data/insert_initial_data.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- Insert example data"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/04_data/insert_example_data.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- End of Run!"
echo "------------------------------------------------------------------------------------------------"
