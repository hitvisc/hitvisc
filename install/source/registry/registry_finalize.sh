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
# Run scripts for finalizing HiTViSc registry database
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

echo "------------------------------------------------------------------------------------------------"
echo "--- Insert example data"
echo "------------------------------------------------------------------------------------------------"
psql --dbname=hitvisc --user=hitviscadm -f ./scripts/04_data/insert_example_data.sql

echo "------------------------------------------------------------------------------------------------"
echo "--- End of Run!"
echo "------------------------------------------------------------------------------------------------"
