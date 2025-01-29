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

# HiTViSC: скрипт скачивания PDB-файла мишени, скачанного с сайта RCSB по заданному идентификатору.
#
# Usage: download_pdb.sh $TMPDIR $PDBSTR $TARGET_SYSTEM_NAME
#
# Reference for the entries without ready PDB files: https://www.rcsb.org/docs/general-help/structures-without-legacy-pdb-format-files

TMPDIR="$1"
PDBSTR="$2"
TARGET_SYSTEM_NAME="$3"
TMPPDBFILENAME="NULL"
COMMENT="NULL"

if [[ "$PDBSTR" =~ ^[0-9A-Za-z]{4}$ ]]; then
  PDBFILENAME="target_${TARGET_SYSTEM_NAME}.pdb" # filename in HiTViSc system
  PDBURL="https://files.rcsb.org/download/${PDBSTR}.pdb"
  status_code_pdb=$(curl -Is "$PDBURL" | head -n 1 | awk '{print $2}')
  if [[ "$status_code_pdb" == "200" ]]; then
    # Legacy PDB format file exists and is accessible: download it
    wget -q -O "$TMPDIR/$PDBFILENAME" "$PDBURL" > /dev/null
    if [ $? -ne 0 ]; then
      rm "$TMPDIR/$PDBFILENAME"; TMPPDBFILENAME="NULL";
      log_msg_error "Failed to download PDB file from the RCSB PDB database (URL: $PDBURL)"
      return $CODEOTHERERR
    else
      TMPPDBFILENAME="$TMPDIR/$PDBFILENAME"
      COMMENT="Note: legacy PDB format file for PDB ID $PDBSTR has been retrieved from the RCSB PDB database (URL: $PDBURL)."
    fi
  else
    # Legacy PDB format file not found: check the availability of PDB bundle in the PDB FTP archive
    DIR=$(cut -c 2-3 <<<"$PDBSTR" | tr '[:upper:]' '[:lower:]')
    PDBSTRlower=$(echo "$PDBSTR" | tr '[:upper:]' '[:lower:]')
    BUNDLEFILENAME="${PDBSTRlower}-pdb-bundle.tar.gz"
    BUNDLEURL=$(echo "https://files.wwpdb.org/pub/pdb/compatible/pdb_bundle/$DIR/$PDBSTRlower/$BUNDLEFILENAME")
    status_code_bundle=$(curl -Is "$BUNDLEURL" | head -n 1 | awk '{print $2}')
      if [[ "$status_code_bundle" == "200" ]]; then
        wget -q -O "$TMPDIR/$BUNDLEFILENAME" "$BUNDLEURL" > /dev/null
        if [ $? -ne 0 ]; then
          rm "$TMPDIR/$BUNDLEFILENAME"; TMPPDBFILENAME="NULL";
          log_msg_error "Failed to download PDB bundle (URL: $BUNDLEURL)"
          return $CODEOTHERERR
        else
          ORIGPDBFILENAME="${PDBSTRlower}-pdb-bundle1.pdb"
          if tar --list -f "$TMPDIR/$BUNDLEFILENAME" 2>/dev/null | grep -q "$ORIGPDBFILENAME"; then
            if tar -xzvf "$TMPDIR/$BUNDLEFILENAME" --to-stdout "$ORIGPDBFILENAME" 2>/dev/null > "$TMPDIR/$PDBFILENAME"; then
              TMPPDBFILENAME="$TMPDIR/$PDBFILENAME"
              COMMENT="Note: legacy PDB format file for PDB ID $PDBSTR was not available for this structure. The best effort/minimal PDB format file has been retrieved from URL: $BUNDLEURL (file $ORIGPDBFILENAME). See more information at https://www.rcsb.org/docs/general-help/structures-without-legacy-pdb-format-files."
            else
              log_msg_error "Error extracting PDB bundle ($ORIGPDBFILENAME from $TMPDIR/$BUNDLEFILENAME)"
              return $CODEOTHERERR
            fi
          else
            log_msg_error "File $ORIGPDBFILENAME does not exist in archive $TMPDIR/$BUNDLEFILENAME"
            return $CODEOTHERERR
          fi
        fi
      fi
  fi
fi

echo "$TMPPDBFILENAME" "\"$COMMENT\""
