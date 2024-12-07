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

# Скрипт вычисления и занесения в базу химических свойств лигандов, содержащихся в заданном файле формата sdf.

# Usage:
USAGE_TEMPLATE="hitvisc_get_ligand_properties.sh file.sdf LIBRARY_ID"

# Get the number of arguments from template:
NARGS="$(awk '{print NF-1}' <<< "$USAGE_TEMPLATE")"
if [ "$#" -ne $NARGS ]; then log_msg_error "Wrong number of arguments ($#)"; exit $CODEARGERR; fi

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

INFILE="$1"
INBASENAME=$(basename "$INFILE"); if [[ ! $INBASENAME =~ \.sdf?$ ]]; then log_msg_error "File ($INFILE) is not in SDF format"; return $CODEOTHERERR; fi
INEXT="${INBASENAME##*.}"
INFILESTR=$(basename "$INFILE" ".$INEXT" | sed 's/[[:blank:]]//g')

TMPFILE="$hitvisc_tmp_dir/tmp.txt"
#LIBRARY_ID=4
LIBRARY_ID="$2"; if [[ ! $LIBRARY_ID -gt 0 ]]; then log_msg_error "invalid value of LIBRARY_ID ($LIBRARY_ID)"; return $CODEOTHERERR; fi

eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
conda activate hitvisc-bio

# Calculate ligand properties
while read -ra line
do
  case ${line[0]} in
     name)
        if [ ${#line[@]} -ge 3 ]; then ligand_name="ligand_${INFILESTR}_${line[2]}";
        else ligand_name=${line[1]}; fi;;
     formula)
        ligand_formula=${line[1]};;
     mol_weight)
        ligand_mol_weight=${line[1]};;
     exact_mass)
        ligand_exact_mass=${line[1]};;
     canonical_SMILES)
        ligand_canonical_SMILES=${line[1]};;
     InChI)
        ligand_InChI_full=${line[1]}; ligand_InChI=${ligand_InChI_full#"InChI="};;
     num_atoms)
        ligand_num_atoms=${line[1]};;
     num_bonds)    
        ligand_num_bonds=${line[1]};;
     num_residues)
        ligand_num_residues=${line[1]};;
     sequence)
        ligand_sequence=${line[1]};;
     num_rings)
        ligand_num_rings=${line[1]};;
     logP)
        ligand_logP=${line[1]};;
     PSA)
        ligand_PSA=${line[1]};;
     MR)
        ligand_MR=${line[1]};;
     '$$$$')
        echo "$ligand_name $ligand_formula $ligand_mol_weight $ligand_exact_mass $ligand_canonical_SMILES $ligand_InChI $ligand_num_atoms $ligand_num_bonds $ligand_num_residues $ligand_sequence $ligand_num_rings $ligand_logP $ligand_PSA $ligand_MR";;
  esac
done <<< $(obprop "$INFILE" 2>/dev/null) > "$TMPFILE"

conda deactivate

# Paste ligand properties into database

PSQL_INSERTED_ROWS=$(echo "SELECT registry.hitvisc_ligand_add_multiple('$TMPFILE', $LIBRARY_ID);" | psql --dbname=hitvisc -qtA)

echo "Inserted $PSQL_INSERTED_ROWS rows"
