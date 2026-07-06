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

# Variables set in the parent script:
# LIBRARY_SYSTEM_NAME
# {LIBRARY_DATA_DIR_LIST[AUTODOCKVINA]}
# LIBRARY_DATA_DIR
# PACKAGE_SIZE
# NPACKAGES

eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
conda activate hitvisc-bio

find "${LIBRARY_DATA_DIR_LIST[TMP]}" -maxdepth 1 -type f -name "*.sdf" -print0 | while IFS= read -r -d '' sdf; do
    FILENAME=$(basename "$sdf" .sdf)
    # Convert to MOL2 splitting into separate files
    obabel -isdf "$sdf" -omol2 --split -O "${LIBRARY_DATA_DIR_LIST[TMP]}/$FILENAME.mol2" -e -m /nochg &>/dev/null
done

cd "${LIBRARY_DATA_DIR_LIST[TMP]}" || exit 1

# Convert to PDBQT adding hydrogens
find . -maxdepth 1 -type f -name "*.mol2" -print0 | while IFS= read -r -d '' mol2; do
    mol2_clean="${mol2#./}"
    FILENAMEMOL2="${mol2_clean%.mol2}"
    prepare_ligand4.py -l "$mol2_clean" -o "$FILENAMEMOL2.pdbqt" &>/dev/null
    rm "$mol2_clean"
done

conda deactivate

# Create packages
for package in $(seq 1 $NPACKAGES); do
  package_filename="${LIBRARY_DATA_DIR_LIST[AUTODOCKVINA]}/package_${LIBRARY_SYSTEM_NAME}_autodockvina_$package.zip"
  find "${LIBRARY_DATA_DIR_LIST[TMP]}" -maxdepth 1 -type f -name "*.pdbqt" -print0 | head -z -n $PACKAGE_SIZE | xargs -0 zip -qjm "$package_filename" -@
done
