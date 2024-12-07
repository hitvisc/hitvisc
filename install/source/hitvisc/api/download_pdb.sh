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
# Reference for the entries without ready PDB files:
# https://www.rcsb.org/docs/general-help/structures-without-legacy-pdb-format-files
# Usage: download_pdb.sh $TMPDIR $PDBSTR $TARGET_SYSTEM_NAME

TMPDIR="$1"
PDBSTR="$2"
TARGET_SYSTEM_NAME="$3"
RESULT="NULL"

if [[ "$PDBSTR" =~ ^[0-9A-Za-z]{4}$ ]]; then
  PDBFILENAME="target_${TARGET_SYSTEM_NAME}.pdb" 
  wget -q -O "$TMPDIR/$PDBFILENAME" "https://files.rcsb.org/download/$PDBSTR.pdb" 2>/dev/null 
  if [ $? -ne 0 ]; then 
    rm "$TMPDIR/$PDBFILENAME"; RESULT="NULL"; 
    log_msg_error "Failed to download PDB file (https://files.rcsb.org/download/$PDBSTR.pdb)"; return $CODEOTHERERR;
  else RESULT="$TMPDIR/$PDBFILENAME"; fi
fi

echo "$RESULT"
