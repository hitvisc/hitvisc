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

# Arguments: TMPDIR FRONT_ENTITY_ID NAME DESCRIPTION AUTHORS SOURCE USAGE_TYPE FILE_LOADED FILENAME ORIGINAL_FILENAME EXTENSION FILE_HREF

# Временная папка для загрузки и обработки файлов библиотеки лигандов
TMPDIR="$1"; if [ ! -d "$TMPDIR" ]; then 
  log_msg_error "TMPDIR ($TMPDIR) does not exist"; return $CODEENVERR; fi

FRONT_ENTITY_ID="$2"; if [[ ! $FRONT_ENTITY_ID -gt 0 ]]; then 
  log_msg_error "invalid value of FRONT_ENTITY_ID ($FRONT_ENTITY_ID)"; return $CODEARGERR; fi

LIBRARY_NAME="$3"; if [ ${#LIBRARY_NAME} -gt 256 ]; then
  log_msg_error "LIBRARY_NAME too long ($LIBRARY_NAME)"; return $CODEARGERR; fi

LIBRARY_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))

LIBRARY_DATA_DIR="$hitvisc_data_dir/library/$LIBRARY_SYSTEM_NAME"
if [ -d "$LIBRARY_DATA_DIR" ]; then log_msg_error "Directory LIBRARY_DATA_DIR already exists ($LIBRARY_DATA_DIR)"; return $CODEENVERR; fi
mkdir -p "$LIBRARY_DATA_DIR"
if [ ! -d "$LIBRARY_DATA_DIR" ]; then log_msg_error "Unable to create directory LIBRARY_DATA_DIR ($LIBRARY_DATA_DIR)"; return $CODEENVERR; fi

LIBRARY_DESC="$4"; if [ ${#LIBRARY_DESC} -gt 1024 ]; then
  log_msg_error "LIBRARY_DESC too long ($LIBRARY_DESC)"; return $CODEARGERR; fi

LIBRARY_AUTH="$5"; if [ ${#LIBRARY_AUTH} -gt 256 ]; then
  log_msg_error "LIBRARY_AUTH too long ($LIBRARY_AUTH)"; return $CODEARGERR; fi

LIBRARY_SRC="$6"; if [ ${#LIBRARY_SRC} -gt 256 ]; then
  log_msg_error "LIBRARY_SRC too long ($LIBRARY_SRC)"; return $CODEARGERR; fi

LIBRARY_USAGE_TYPE="$7"; if [[ ! $LIBRARY_USAGE_TYPE =~ ^[ORP]$ ]]; then
  log_msg_error "invalid value of LIBRARY_USAGE_TYPE ($LIBRARY_USAGE_TYPE)"; return $CODEARGERR; fi

FILE_LOADED="$8"; if [[ ! $FILE_LOADED =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of FILE_LOADED ($FILE_LOADED)"; return $CODEARGERR; fi

FILENAME="$9"
ORIGINAL_FILENAME="${10}"
EXTENSION="${11}"
FILE_HREF="${12}"

if [ $FILE_LOADED == "Y" ] && [ $EXTENSION != "zip" ]; then log_msg_error "Invalid format of the library file!"; return $CODEARGERR; fi

TMPLIBFILENAME="$LIBRARY_DATA_DIR/library_$LIBRARY_SYSTEM_NAME.zip"
if [ "$FILE_LOADED" == "Y" ]; then
  cp "$TMPDIR/$FILENAME" "$TMPLIBFILENAME"
else
  # Download library file
  wget -q -O "$TMPLIBFILENAME" "$FILE_HREF" 2>/dev/null
  if [ $? -ne 0 ]; then rm "$TMPLIBFILENAME"; log_msg_error "Failed to download library file ($FILE_HREF)"; return $CODEOTHERERR; fi
fi

if [ ! -f "$TMPLIBFILENAME" ]; then log_msg_error "Failed to create library file on server ($TMPLIBFILENAME)"; return $CODEOTHERERR; fi

## Define directories structure for library files
declare -A LIBRARY_DATA_DIR_LIST
LIBRARY_DATA_DIR_LIST[TMP]="$LIBRARY_DATA_DIR/tmp"
LIBRARY_DATA_DIR_LIST[CMDOCK]="$LIBRARY_DATA_DIR/cmdock"
LIBRARY_DATA_DIR_LIST[AUTODOCKVINA]="$LIBRARY_DATA_DIR/autodockvina"
for key in ${!LIBRARY_DATA_DIR_LIST[@]}; do mkdir -p "${LIBRARY_DATA_DIR_LIST[${key}]}"; done

unzip -q -o "$TMPLIBFILENAME" -d "${LIBRARY_DATA_DIR_LIST[TMP]}"

## Save the initial library file
#rm "$TMPLIBFILENAME" 

## Create packages for two libraries: CmDock version and AutoDock Vina version

# Check if at least one .sdf file exists and process the existing .sdf files
TEST=$(find "${LIBRARY_DATA_DIR_LIST[TMP]}" -name "*.sdf" -print -quit)
if [ ! -z "$TEST" ]; then
  # Get the total number of ligands. In SDF format, molecules are separated by string '$$$$' which can be missing in the end of file
  NLIGANDS=$(find "${LIBRARY_DATA_DIR_LIST[TMP]}" -maxdepth 1 -type f -name "*.sdf" -print0 | xargs -0 -I{} sh -c '(awk -vRS= '\''END{if($0 != "$$$$") print "$$$$"}'\'' {} && grep "\$\$\$\$" {})' | wc -l)
  PACKAGE_SIZE=10 # For testing purposes; use 100-500 for a real project

  LAST_PACKAGE_SIZE=$(($NLIGANDS % $PACKAGE_SIZE))
  NPACKAGES=$(($NLIGANDS / $PACKAGE_SIZE))
  if [ $LAST_PACKAGE_SIZE == 0 ]; then LAST_PACKAGE_SIZE=$PACKAGE_SIZE; else let "NPACKAGES=$NPACKAGES+1"; fi

  if [[ $NLIGANDS -gt 0 ]]; then
    # Create packages for CmDock
    awk -v LIBSYSTEMNAME=$LIBRARY_SYSTEM_NAME -v N=$NLIGANDS -v P=$PACKAGE_SIZE -v DIRCMDOCK="${LIBRARY_DATA_DIR_LIST[CMDOCK]}" -f "$DIR/split_sdf.awk" $(find "${LIBRARY_DATA_DIR_LIST[TMP]}" -maxdepth 1 -type f -name "*.sdf" -print0 | xargs -0 -I{} sh -c 'echo -n {}; echo -n " "')
    # Create packages for AutoDock Vina    
    source "$DIR/make_pdbqt.sh"
  else
    log_msg_error "No ligands found in the uploaded library!"; return $CODEOTHERERR
  fi
else
  log_msg_error "No sdf files found ($LIBRARY_DATA_DIR)"; return $CODEOTHERERR
fi

find "${LIBRARY_DATA_DIR_LIST[TMP]}" -maxdepth 1 -type f -name "*.sdf" -print0 | xargs -0 rm


TEST=$(find "${LIBRARY_DATA_DIR_LIST[CMDOCK]}/" -maxdepth 1 -type f -name "package*.zip" -print -quit)
if [ -z "$TEST" ]; then
  log_msg_error "No packages created for the new library, docking app CmDock"; return $CODEOTHERERR; fi

TEST=$(find "${LIBRARY_DATA_DIR_LIST[AUTODOCKVINA]}/" -maxdepth 1 -type f -name "package*.zip" -print -quit)
if [ -z "$TEST" ]; then
  log_msg_error "No packages created for the new library, docking app AutoDock Vina"; return $CODEOTHERERR; fi


LIBRARY_STATE='P' # initially the state 'preparing'

LIBRARY_ID=$(echo "SELECT registry.hitvisc_library_add('$LIBRARY_NAME', '$LIBRARY_SYSTEM_NAME', '$LIBRARY_DESC', '$LIBRARY_AUTH', '$LIBRARY_SRC', '$LIBRARY_USAGE_TYPE', '$LIBRARY_STATE');" | psql --dbname=hitvisc -qtA)

# Register packages info for CmDock and AutoDock Vina
if [[ $LIBRARY_ID -gt 0 ]]; then
  ids=($(echo "SELECT id FROM registry.docker WHERE system_name IN ('autodockvina', 'cmdock') ORDER BY system_name ASC;" | psql --dbname=hitvisc -qtA))
  DOCKER_ID_AUTODOCKVINA="${ids[0]}"; DOCKER_ID_CMDOCK="${ids[1]}"
  if [[ ! $DOCKER_ID_AUTODOCKVINA -gt 0 ]] || [[ ! $DOCKER_ID_CMDOCK -gt 0 ]]; then
    log_msg_error "Invalid docker ID ($DOCKER_ID_AUTODOCKVINA, $DOCKER_ID_CMDOCK)"; return $CODEOTHERERR; fi

  declare -A DOCKER_IDS; DOCKER_IDS[AUTODOCKVINA]="${ids[0]}"; DOCKER_IDS[CMDOCK]="${ids[1]}"

  for i in "CMDOCK" "AUTODOCKVINA"; do
    PACKAGE_N=0
    for PACKAGE_FILEPATH in $(find "${LIBRARY_DATA_DIR_LIST[$i]}" -maxdepth 1 -type f -name "package*.zip" -print); do
      PACKAGE_FILENAME=$(basename "$PACKAGE_FILEPATH")
      let "PACKAGE_N++"
      if [ "$PACKAGE_N" -lt "$NPACKAGES" ]; then PACKAGE_LIG_COUNT="$PACKAGE_SIZE"; else PACKAGE_LIG_COUNT="$LAST_PACKAGE_SIZE"; fi
      PSQL_STATUS=$(echo "INSERT INTO registry.package(id, library_id, docker_id, file_name, file_path, ligand_count) 
                          VALUES(NEXTVAL('registry.seq_package_id'), $LIBRARY_ID, ${DOCKER_IDS[$i]}, '$PACKAGE_FILENAME', 
                          '$PACKAGE_FILEPATH', $PACKAGE_LIG_COUNT);" | psql --dbname=hitvisc -qtA)
    done
  done

  PSQL_STATUS=$(echo "UPDATE registry.library SET state = 'U' WHERE id = $LIBRARY_ID" | psql --dbname=hitvisc -qtA)
  ENTITY_MAPPING_ID=$(echo "SELECT registry.hitvisc_entity_mapping_add($FRONT_ENTITY_ID, $LIBRARY_ID, 'L');" | psql --dbname=hitvisc -qtA)
else
  log_msg_error "unable to create new library (cmd: SELECT registry.hitvisc_library_add('$LIBRARY_NAME', '$LIBRARY_SYSTEM_NAME', '$LIBRARY_DESC', '$LIBRARY_AUTH', '$LIBRARY_SRC', '$LIBRARY_USAGE_TYPE', '$LIBRARY_STATE');)"; return $CODEPSQLERR; fi

if [[ $ENTITY_MAPPING_ID -le 0 ]]; then 
  log_msg_error "unable to create mapping between front_library (id $FRONT_ENTITY_ID) and back_library (id $LIBRARY_ID)"; return $CODEPSQLERR; fi

