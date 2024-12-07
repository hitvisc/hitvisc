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

#obabel file.sdf -osdf --filter "MW>500 logP>5"

# Usage:  ./hitvisc_filter_ligands.sh file.sdf "FILTER CONDITIONS"
# Output: created file file.sdf
#
# See the glossary of chemical descriptors at
# https://openbabel.org/docs/Descriptors/descriptors.html

INFILE="$1"
INNAME=$(basename "$INFILE" .sdf)
INDIR=$(dirname "$INFILE")

eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
conda activate hitvisc-bio

# Filter ligands satisfying the given conditions
obabel $INFILE -osdf -O"$INDIR/$INNAME.filtered.sdf" --filter "MW>600 logP>5" &>/dev/null

conda deactivate

