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

# HiTVISc: скрипт конвертации мишени из PDB-формата в MOL2 (для молекулярного докинга CmDock) 
# и в PDBQT (для молекулярного докинга AutoDock Vina).
# Требует наличия установленных программ OpenBabel >=3.1.1, MGLTools >=1.5.7

# Usage: ./hitvisc_convert_target.sh file.pdb
# Output: created files file.mol2 file.pdbqt 

INFILE="$1"
INNAME=$(basename "$INFILE" .pdb)
INDIR=$(dirname "$INFILE")

eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
conda activate hitvisc-bio 2>/dev/null
if [ $? -eq 0 ]; then
    # Convert to MOL2 adding hydrogens 
    obabel -ipdb "$INFILE" -omol2 -O "$INDIR/$INNAME.mol2" -h &>/dev/null  
    # Convert to PDBQT adding hydrogens
    prepare_receptor4.py -A hydrogens -r "$INFILE" -o "$INDIR/$INNAME.pdbqt" &>/dev/null
    conda deactivate
else
    log_msg_error "Failed to activate hitvisc-bio environment of conda (/app/third-party/anaconda/bin/conda)"
    return $CODEENVERR
fi

if [ ! -f "$INDIR/$INNAME.mol2" ]; then return $CODECNVERR; else TARGETMOL2FILE="$INDIR/$INNAME.mol2"; fi
if [ ! -f "$INDIR/$INNAME.pdbqt" ]; then return $CODECNVERR; else TARGETPDBQTFILE="$INDIR/$INNAME.pdbqt"; fi

