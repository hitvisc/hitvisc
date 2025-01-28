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

# Arguments: TMPDIR FRONT_ENTITY_ID NAME DESCRIPTION AUTHORS SOURCE USAGE_TYPE FILE_LOADED FILENAME ORIGINAL_FILENAME EXTENSION PDB_ID REFLIG_EXTRACT REFLIG_EXIST REFLIG_FILENAME REFLIG_ORIGINAL_FILENAME REFLIG_EXTENSION

# Временная папка для загрузки и обработки файлов, связанных с мишенью
TMPDIR="$1"; if [ ! -d "$TMPDIR" ]; then
  log_msg_error "TMPDIR ($TMPDIR) does not exist"; return $CODEENVERR; fi

FRONT_ENTITY_ID="$2"; if [[ ! $FRONT_ENTITY_ID -gt 0 ]]; then
  log_msg_error "invalid value of FRONT_ENTITY_ID ($FRONT_ENTITY_ID)"; return $CODEARGERR; fi

TARGET_NAME="$3"; if [ ${#TARGET_NAME} -gt 256 ]; then
  log_msg_error "TARGET_NAME too long ($TARGET_NAME)"; return $CODEARGERR; fi

TARGET_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))

TARGET_DATA_DIR="$hitvisc_data_dir/target/$TARGET_SYSTEM_NAME"
if [ -d "$TARGET_DATA_DIR" ]; then log_msg_error "Directory TARGET_DATA_DIR already exists ($TARGET_DATA_DIR)"; return $CODEENVERR; fi
mkdir -p "$TARGET_DATA_DIR"
if [ ! -d "$TARGET_DATA_DIR" ]; then log_msg_error "Unable to create directory TARGET_DATA_DIR ($TARGET_DATA_DIR)"; return $CODEENVERR; fi

TARGET_DESC="$4"; if [ ${#TARGET_DESC} -gt 1024 ]; then
  log_msg_error "TARGET_DESC too long ($TARGET_DESC)"; return $CODEARGERR; fi

TARGET_AUTH="$5"; if [ ${#TARGET_AUTH} -gt 256 ]; then
  log_msg_error "TARGET_AUTH too long ($TARGET_AUTH)"; return $CODEARGERR; fi

TARGET_SRC="$6"; if [ ${#TARGET_SRC} -gt 256 ]; then
  log_msg_error "TARGET_SRC too long ($TARGET_SRC)"; return $CODEARGERR; fi

TARGET_USAGE_TYPE="$7"; if [[ ! $TARGET_USAGE_TYPE =~ ^[ORP]$ ]]; then
  log_msg_error "invalid value of TARGET_USAGE_TYPE ($TARGET_USAGE_TYPE)"; return $CODEARGERR; fi

PDB_FILE_LOADED="$8"; if [[ ! $PDB_FILE_LOADED =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of PDB_FILE_LOADED ($PDB_FILE_LOADED)"; return $CODEARGERR; fi

PDB_FILENAME="$9"
PDB_ORIGINAL_FILENAME="${10}"
PDB_EXTENSION="${11}"
PDB_ID="${12}"

REFLIG_EXTRACT="${13}"; if [[ ! $REFLIG_EXTRACT =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of REFLIG_EXTRACT ($REFLIG_EXTRACT)"; return $CODEARGERR; fi

REFLIG_EXIST="${14}"; if [[ ! $REFLIG_EXIST =~ ^[YN]$ ]]; then
  log_msg_error "invalid value of REFLIG_EXIST ($REFLIG_EXIST)"; return $CODEARGERR; fi

REFLIG_FILENAME="${15}"
REFLIG_ORIGINAL_FILENAME="${16}"
REFLIG_EXTENSION="${17}"

## Process PDB file
if [ "$PDB_FILE_LOADED" == "N" ]; then
  #TMPPDBFILENAME=$(source "$DIR/download_pdb.sh" "$TMPDIR" "$PDB_ID" "$TARGET_SYSTEM_NAME")
  INFO_PDB_FILE=$(source "$DIR/download_pdb.sh" "$TMPDIR" "$PDB_ID" "$TARGET_SYSTEM_NAME")
  if [ $? -ne 0 ]; then log_msg_error "Failed to download PDB file by ID ($PDB_ID)"; return $CODEOTHERERR; fi

  # Parse the output: TMPPDBFILENAME COMMENT
  ARR_PDB_INFO=$(INFO_PDB_FILE)
  TMPPDBFILENAME=${ARR_PDB_INFO[0]}
  COMMENT=${ARR_PDB_INFO[1]}
else
  TMPPDBFILENAME="$TMPDIR/target_${TARGET_SYSTEM_NAME}.pdb"
  cp "$TMPDIR/$PDB_FILENAME" "$TMPPDBFILENAME"
fi

if [ ! -f "$TMPPDBFILENAME" ]; then log_msg_error "Failed to create PDB file on server ($TMPPDBFILENAME)"; return $CODEOTHERERR; fi

if [ "$REFLIG_EXTRACT" == "Y" ]; then REFLIGCOUNT=-1; else REFLIGCOUNT=0; fi

INFO_REF_LIGANDS=$(source "$DIR/prepare_target.sh" "$TMPDIR" "$TARGET_DATA_DIR" "$TMPPDBFILENAME" $REFLIGCOUNT)
if [ $? -ne 0 ]; then log_msg_error "Failed to prepare target file ($TMPPDBFILENAME)"; return $CODEOTHERERR; fi

# Parse the output: READY_TARGET_FILENAME LIGAND_1_FILENAME:X;Y;Z:A ... LIGAND_N_FILENAME:X;Y;Z:A
ARR_REF_LIGANDS=($INFO_REF_LIGANDS)
let NUM_REF_LIGANDS=${#ARR_REF_LIGANDS[@]}-1
READY_TARGET_FILENAME=${ARR_REF_LIGANDS[0]}

if [ ! -f "$READY_TARGET_FILENAME" ]; then log_msg_error "Failed to get READY_TARGET_FILENAME ($READY_TARGET_FILENAME)"; return $CODEOTHERERR; fi

source "$DIR/convert_target.sh" "$READY_TARGET_FILENAME"
if [ $? -ne 0 ]; then log_msg_error "Failed to convert target file ($READY_TARGET_FILENAME)"; return $CODEOTHERERR; fi
if [ ! -f $TARGETMOL2FILE ]; then log_msg_error "Failed to prepare target file MOL2 ($TARGETMOL2FILE)"; return $CODEOTHERERR; fi
if [ ! -f $TARGETPDBQTFILE ]; then log_msg_error "Failed to prepare target file PDBQT ($TARGETPDBQTFILE)"; return $CODEOTHERERR; fi

TARGETMOL2NAME=$(basename $TARGETMOL2FILE); TARGETPDBQTNAME=$(basename $TARGETPDBQTFILE);

TARGET_STATE='P'  # initially the state 'preparing'

## Add target with the given parameters
TARGET_ID=$(echo "SELECT registry.hitvisc_target_add('$TARGET_NAME', '$TARGET_SYSTEM_NAME', '$TARGET_DESC', '$TARGET_AUTH', '$TARGET_SRC', '$TARGET_USAGE_TYPE', '$TARGET_STATE');" | psql --dbname=hitvisc -qtA)

if [[ $TARGET_ID -gt 0 ]]; then
  TARGET_FILE_MOL2_ID=$(echo "SELECT registry.hitvisc_target_file_add($TARGET_ID, 'mol2', '$TARGETMOL2FILE', '$TARGETMOL2NAME');" | psql --dbname=hitvisc -qtA)
  TARGET_FILE_PDBQT_ID=$(echo "SELECT registry.hitvisc_target_file_add($TARGET_ID, 'pdbqt', '$TARGETPDBQTFILE', '$TARGETPDBQTNAME');" | psql --dbname=hitvisc -qtA)
  # Insert all reference ligands for this target
  let N=${#ARR_REF_LIGANDS[@]}-1
  for i in $(seq 1 $N); do
    REFLIGSTR="${ARR_REF_LIGANDS[$i]}"
    IFS=':' read -ra REFLIG <<< "$REFLIGSTR"
    P_REFLIG_FILEPATH="${REFLIG[0]}"
    P_REFLIG_FILENAME=$(basename $P_REFLIG_FILEPATH)
    P_REFLIG_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))
    P_REFLIG_COORDS="${REFLIG[1]}"
    IFS=';' read -ra COORDS <<< "$P_REFLIG_COORDS"
    P_X="${COORDS[0]}"; P_Y="${COORDS[1]}"; P_Z="${COORDS[2]}"
    P_REFLIG_CHAIN="${REFLIG[2]}"

    REFERENCE_LIGAND_ID=$(echo "SELECT registry.hitvisc_reference_ligand_add($TARGET_ID, '$P_REFLIG_NAME', $P_X, $P_Y, $P_Z, '$P_REFLIG_CHAIN');" | psql --dbname=hitvisc -qtA)
    if [[ $REFERENCE_LIGAND_ID -le 0 ]]; then
        log_msg_error "unable to insert reference ligand (cmd: SELECT registry.hitvisc_reference_ligand_add($TARGET_ID, '', $P_X, $P_Y, $P_Z, '$P_REFLIG_CHAIN');)"; return $CODEPSQLERR; fi
    echo "INSERT INTO registry.reference_ligand_file(id, reference_ligand_id, type, file_path, file_name) VALUES(NEXTVAL('registry.seq_reference_ligand_file_id'), $REFERENCE_LIGAND_ID, 'sdf', '$P_REFLIG_FILEPATH', '$P_REFLIG_FILENAME');" | psql --dbname=hitvisc -qtA
  done

  PSQL_STATUS=$(echo "UPDATE registry.target SET state = 'U' WHERE id = $TARGET_ID" | psql --dbname=hitvisc -qtA)
  ENTITY_MAPPING_ID=$(echo "SELECT registry.hitvisc_entity_mapping_add($FRONT_ENTITY_ID, $TARGET_ID, 'T');" | psql --dbname=hitvisc -qtA)
else
  log_msg_error "unable to create new target (cmd: SELECT registry.hitvisc_target_add('$TARGET_NAME', '$TARGET_SYSTEM_NAME', '$TARGET_DESC', '$TARGET_AUTH', '$TARGET_SRC', '$TARGET_USAGE_TYPE', '$TARGET_STATE');)"; return $CODEPSQLERR; fi

if [[ $ENTITY_MAPPING_ID -le 0 ]]; then
  log_msg_error "unable to create mapping between front_target (id $FRONT_ENTITY_ID) and back_target (id $TARGET_ID)"; return $CODEPSQLERR; fi
