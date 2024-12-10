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

# Script for unpacking and building PostgreSQL server software

# Store input parameters
source_code_archive=${1}
postgresql_environment=${2}
postgresql_database=${3}
postgresql_home=${4}
postgresql_serverlog=${5}
postgresql_user=${6}

build_root=$PWD

# Print inpur parameters values
echo "------------------------------------------------------------------------------------------------"
echo "--- Script started with the following parameters"
echo "------------------------------------------------------------------------------------------------"
echo "source_code_archive    = ${source_code_archive}"
echo "postgresql_environment = ${postgresql_environment}"
echo "postgresql_database    = ${postgresql_database}"
echo "postgresql_home        = ${postgresql_home}"
echo "postgresql_serverlog   = ${postgresql_serverlog}"
echo "postgresql_user        = ${postgresql_user}"

echo "------------------------------------------------------------------------------------------------"
echo "--- Set PostgreSQL parameters"
echo "------------------------------------------------------------------------------------------------"
# Write actual values into environment configuration file
cd $build_root/environment/
sed -i "s#{PostgreSQL_Home} : {PostgreSQL_Database}#${postgresql_home} : ${postgresql_database}#g" postgresql.env
cp * $postgresql_environment

# Write actual values into hitvisc-postgresql.service unit file
cd $build_root/config
sed -i "s/{PostgreSQL_user}/${postgresql_user}/g" hitvisc-postgresql.service
sed -i "s#{PostgreSQL_home}/bin/postgres -D {PostgreSQL_Database}#${postgresql_home}/bin/postgres -D ${postgresql_database}#g" hitvisc-postgresql.service

# Write actual values info postgresql.conf file
cd $build_root/config
sed -i "s#{PostgreSQL_Log}#${postgresql_serverlog}#g" postgresql.conf

# Extract source code from archive
cd $build_root/rdbms
tar -zxvf $source_code_archive
source_code_directory=$(echo $source_code_archive | sed 's/.tar.gz//g')
cd ./${source_code_directory}

# Compilation configuring
echo "------------------------------------------------------------------------------------------------"
echo "--- Run PostgreSQL build configure"
echo "------------------------------------------------------------------------------------------------"
./configure --prefix=${postgresql_home} --with-python --with-systemd --with-libxml --with-ssl=openssl --with-uuid=ossp CXXFLAGS=-O3

# PostgreSQL compliaton
echo "------------------------------------------------------------------------------------------------"
echo "--- Run PostgreSQL build"
echo "------------------------------------------------------------------------------------------------"
make world
make install-world

# Postgresql cluster of databases creation
# Set enviroment variables
cd $postgresql_environment
. ./env.sh <<TEXT
HiTViSc
TEXT

# Performs database cluster creation
initdb --username=${postgresql_user} --data-checksums --pgdata=${PG_DATA} --encoding=UTF8

# Copy configuration files into postgresql database directory
mv ${postgresql_database}/postgresql.conf ${postgresql_database}/postgresql.conf.old
mv ${postgresql_database}/pg_hba.conf ${postgresql_database}/pg_hba.conf.old
cp $build_root/config/pg_hba.conf ${postgresql_database}
cp $build_root/config/postgresql.conf ${postgresql_database}
