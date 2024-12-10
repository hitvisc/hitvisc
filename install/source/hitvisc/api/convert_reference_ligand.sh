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

# HiTVISc: скрипт конвертации справочного лиганда из SDF-формата в PDBQT 
# (для сравнения с результатами молекулярного докинга AutoDock Vina).
# Требует наличия установленных программ MGLTools >=1.5.7

# Usage: ./convert_reference_ligand.sh file.sdf
# Output: the created file file.pdbqt 

INFILE="$1"
INNAME=$(basename "$INFILE" .sdf)
INDIR=$(dirname "$INFILE")
CURRENTDIR=$(pwd)

cd "$INDIR"
eval "$(command conda 'shell.bash' 'hook' 2>/dev/null)"
conda activate hitvisc-bio

# Convert to PDBQT 
prepare_ligand4.py -l "$INFILE" -o "$INDIR/$INNAME.pdbqt" &>/dev/null
conda deactivate
cd "$CURRENTDIR"

if [ ! -f "$INDIR/$INNAME.pdbqt" ]; then return $CODECNVERR; else REFLIGPDBQTFILE="$INDIR/$INNAME.pdbqt"; fi

