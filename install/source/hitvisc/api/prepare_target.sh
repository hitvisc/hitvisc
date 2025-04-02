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

# HiTViSC: скрипт подготовки PDB-файла мишени к последующей конвертации и молекулярному докингу.
# Разбирает PDB-файл, выделяя мишень (рецептор). Скачивает справочные лиганды в отдельные файлы.
# Если PDB-файл содержит несколько моделей, скрипт сохраняет только первую из них.
# Если мишень содержит несколько отдельных цепей, скрипт сохраняет только первую из них. 

# HiTViSC: script to prepare the PDB file of the target for subsequent conversion and molecular docking.
# Parses a PDB file to extract the target (receptor). Downloads the reference ligands to separate files.
# If the file contains multiple models, keeps only the first one.
# If the target contains multiple disjoint chains, keeps only the first one.                                
# Currently, only structures without modified residues are supported.
#
# Output: target_filename.pdb ligand_filename.pdb:X;Y;Z:C ligand_filename.pdb:X;Y;Z:C
#
# X Y Z are the coordinates of the geometric center of the ligand relative to the target.
# C is the chain identifier.

# source hitvisc_prepare_target.sh $TMPDIR $TARGETDIR $TMPPDBFILENAME $REFLIGCOUNT

TMPDIR="$1"
TARGETDIR="$2"
TMPPDBFILENAME="$3"
REFLIGCOUNT="$4"

PDBFILE=$(basename "$TMPPDBFILENAME")
if [ ! -f "$TMPPDBFILENAME" ]; then log_msg_error "Target PDB file not found ($TMPPDBFILENAME)"; return $CODEPDBERR; fi

TMPFILE="tmp.${PDBFILE}.without_extra_molecules"
TARGETFILE="$TARGETDIR/${PDBFILE}"
TARGETNAME=$(basename "$TARGETFILE" .pdb)

THRESHOLD=10    # Minimal allowed atoms count of a reference ligand
ALLCHAINS=true  # Keep all chains (otherwise the first one)

# Remove the anisotropic temperature factors. Remove water molecules. Separate HETATM with a space if needed.
# TODO: remove ions, anything else?
sed -i 's/^HETATM\([0-9]*\)/HETATM \1/' "$TMPPDBFILENAME"
awk '{ if($1=="ENDMDL") stop=1; if(($1!="ANISOU") && !($1=="HETATM" && $4=="HOH") && ($1!="MODEL") && (stop!=1 || $1=="MASTER" || $1=="END" )) print $0}' "$TMPPDBFILENAME" > "$TMPDIR/$TMPFILE"

if [ ! -s "$TMPDIR/$TMPFILE" ]; then log_msg_error "Failed to preprocess target PDB file"; return $CODEPDBERR; fi


# Extract the target (receptor).

# TODO: specify the needed chain? Keep all chains? Keep only the needed chain (currently the first one)?
#
# In PDB file format, TER records are used to separate protein and nucleic acid chains. 
# The chains are included one after another in the file, separated by a TER record 
# to indicate that the chains are not physically connected to each other.

if $ALLCHAINS
then
  awk -v TARGETFILE=$TARGETFILE '{if($1!="HETATM") print $0 >> TARGETFILE}' "$TMPDIR/$TMPFILE"
else
  SELECTED_CHAIN=$(awk -v TARGETFILE=$TARGETFILE 'BEGIN {chain_id=1} {if($1=="TER") chain_id++; if(chain_id == 1 || $1 == "MASTER" || $1 == "END") print $0 >> TARGETFILE; if($1=="ATOM") chains[chain_id]=substr($5,1,1)} END {print(chains[1])}' "$TMPDIR/$TMPFILE")
fi

if [ ! -s "$TARGETFILE" ]; then log_msg_error "Failed to get non-HETATM records from target PDB file"; return $CODEPDBERR; fi

# Get ligands for the selected receptor chain
if [ $REFLIGCOUNT -eq -1 ]; then
  # Copy every ligand to a separate file for further processing. 
  # In PDB format, each ligand is identified by field 4, chain by field 5.
  TMPLIGANDFILES=$(awk -v TMPDIR="$TMPDIR" -v PDBFILE="$PDBFILE" '{if($1=="HETATM") {THIS_LIGAND_FILENAME=TMPDIR"/tmp.ligand_"$4"_"substr($5,1,1)"_"PDBFILE; print $0 >> THIS_LIGAND_FILENAME; tmpligandfilenames[$4"_"substr($5,1,1)]=THIS_LIGAND_FILENAME}} END {for (key in tmpligandfilenames) {printf "%s ", tmpligandfilenames[key]}; printf "\n"}' "$TMPDIR/$TMPFILE")
  i=0
  for LIGANDFILENAME in $TMPLIGANDFILES; do
    if [ ! -f "$LIGANDFILENAME" ]; then log_msg_error "Failed to get ligand file ($LIGANDFILENAME)"; return $CODEPDBERR; fi
    LIGAND_RCSB_ID=$(basename "$LIGANDFILENAME" | cut -d'_' -f2)
    LIGAND_CHAIN=$(basename "$LIGANDFILENAME" | cut -d'_' -f3)
    if [ "$LIGAND_CHAIN" == "$SELECTED_CHAIN" -o $ALLCHAINS ]; then
      # Continue conversion only if the atom count exceeds the threshold,
      # to avoid keeping metal ions etc. as reference ligands.
      # TODO: a more precise filter may be, for example, molecular weight > 100.0 Da

      ATOMCOUNT=$(grep HETATM "$LIGANDFILENAME" | wc -l)
      if [ $ATOMCOUNT -ge $THRESHOLD ]; then
        # Calculate the coordinates of the geometric center.
        CENTER="$(awk '{if($1=="HETATM") {COUNT++; X+=$7; Y+=$8; Z+=$9}} END {if(COUNT>0) printf "%.6f;%.6f;%.6f", X/COUNT, Y/COUNT, Z/COUNT}' ${LIGANDFILENAME})"

        # The model SDF for the ligand identified by "$LIGAND_RCSB_ID" is in the RCSB PDB database at
	# https://download.rcsb.org/batch/ccd/"$LIGAND_RCSB_ID"_ideal.sdf
	# (previously at https://files.rcsb.org/ligands/download/"$LIGAND_RCSB_ID"_model.sdf)
        LIGAND_SDF_FILENAME="$TARGETDIR/"$PDBFILE"_ligand_"$LIGAND_RCSB_ID"_"$LIGAND_CHAIN".sdf"
        if [ ! -f "$LIGAND_SDF_FILENAME" ]; then
          wget -O "$LIGAND_SDF_FILENAME" "https://download.rcsb.org/batch/ccd/"$LIGAND_RCSB_ID"_ideal.sdf" 2>/dev/null
          #wget -O "$LIGAND_SDF_FILENAME" "https://files.rcsb.org/ligands/download/"$LIGAND_RCSB_ID"_model.sdf" 2>/dev/null
        fi
        if [ ! -s "$LIGAND_SDF_FILENAME" ]; then LIGAND_SDF_FILENAME="NULL"; fi
        READYLIGANDS[$i]="$LIGAND_RCSB_ID:$LIGAND_SDF_FILENAME:$CENTER:$LIGAND_CHAIN"
        i=$i+1
      fi
    fi
  done
fi

# Переместить загруженные пользователем файлы справочных лигандов 
# из временной папки в постоянную и преобразовать их из формата SDF в PDBQT
if [ $REFLIGCOUNT -gt 0 ]; then 
  i=0
  ligandfiles=$(ls $TMPDIR/reference_ligands/*.[sS][dD][fF])
  for ligandfile in $ligandfiles; do
    if [ ! -f "$ligandfile" ]; then log_msg_error "Failed to get temporary ligand file ($ligandfile)"; return $CODEPDBERR; fi
    LIGAND_RCSB_ID=$(head -1 "$ligandfile")
    if [ "$LIGAND_RCSB_ID" = "" ]; then log_msg_error "Failed to get ligand name from ligand file ($ligandfile)"; return $CODEPDBERR; fi
    OUTFILENAME="$TARGETDIR/${TARGETNAME}_ligand_${LIGAND_RCSB_ID}_model.sdf"
    cp "$ligandfile" "$OUTFILENAME"
    if [ ! -f "$OUTFILENAME" ]; then log_msg_error "Failed to copy temporary ligand file ($ligandfile)"; return $CODEPDBERR; fi
    source convert_reference_ligand.sh "$OUTFILENAME"
    LIGAND_SDF_FILENAME=$OUTFILENAME
    CENTER="NULL;NULL;NULL"
    LIGAND_CHAIN="NULL"
    READYLIGANDS[$i]="$LIGAND_RCSB_ID:$LIGAND_SDF_FILENAME:$CENTER:$LIGAND_CHAIN"
    i=$i+1
  done 
fi

if [ ! -f "$TARGETFILE" ]; then READY_TARGET_FILENAME="NONE"; else READY_TARGET_FILENAME="$TARGETFILE"; fi
echo -n "$READY_TARGET_FILENAME " 
for readyligand in "${READYLIGANDS[@]}"; do
  echo -n "$readyligand "
done

if [ -f "$TMPDIR/$TMPFILE" ]; then rm -f "$TMPDIR/$TMPFILE"; fi
if [ -f "$TMPDIR/$TMPLIGANDFILES" ]; then rm -f "$TMPDIR/$TMPLIGANDFILES"; fi
