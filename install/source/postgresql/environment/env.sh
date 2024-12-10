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

registry_file="postgresql.env"
pg_instance_name=""
pg_home_dir=""
pg_data_dir=""

#echo ""
#echo "Welcome fo HiTViSc PostgreSQL environment configuration utility!"
#echo "Currently registered instances:"
#cat $registry_file | grep -v "^#"
#echo ""

read -p "Instance name: " pg_instance_name

pg_home_dir=$(cat $registry_file | grep "^${pg_instance_name}" | awk -F ":" '{ field_value = $2; gsub(/ /, "", field_value); print(field_value); }')
pg_data_dir=$(cat $registry_file | grep "^${pg_instance_name}" | awk -F ":" '{ field_value = $3; gsub(/ /, "", field_value); print(field_value); }')

#echo "Read values:"
#echo "HiTViSc PostgreSQL home:    $pg_home_dir"
#echo "HiTViSc database directory: $pg_data_dir"

export PG_DATA=$pg_data_dir
export PATH=$pg_home_dir/bin:$PATH
