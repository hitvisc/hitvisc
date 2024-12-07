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

# Create a BOINC workunit for the specified docking app with a specified target 
# and a specified package of ligands. Configuration files must 
# be named as the target file.
#
# Usage: ./hitvisc_create_boinc_task.sh APPNAME TARGETDIR/TARGET.ext LIGANDSDIR/LIGANDS.zip 

CODESUCCESS=0; CODEARGERR=-1; CODEINPERR=1;

declare -A TARGET_EXT=(["cmdock"]="mol2" ["test-cmdock"]="mol2" ["private-cmdock"]="mol2" ["public-cmdock"]="mol2" ["autodockvina"]="pdbqt" ["test-autodockvina"]="pdbqt" ["private-autodockvina"]="pdbqt" ["public-autodockvina"]="pdbqt")

if [ "$#" -ne 3 ]; then
  echo "Usage: hitvisc_create_boinc_task.sh APPNAME TARGETDIR/TARGET.ext LIGANDSDIR/LIGANDS.zip"; exit $CODEARGERR;
fi

DOCKING_APP="$1"
TARGET_PATH="$2"
PACKAGE_PATH="$3"

if [[ "$DOCKING_APP" != "cmdock" ]] && [[ "$DOCKING_APP" != "test-cmdock" ]] && [[ "$DOCKING_APP" != "private-cmdock" ]] && [[ "$DOCKING_APP" != "public-cmdock" ]] && [[ "$DOCKING_APP" != "autodockvina" ]] && [[ "$DOCKING_APP" != "test-autodockvina" ]] && [[ "$DOCKING_APP" != "private-autodockvina" ]] && [[ "$DOCKING_APP" != "public-autodockvina" ]]; then
  echo "Provide a valid app name: [test/private/public]-cmdock or [test/private/public]-autodockvina."; exit $CODEARGERR; fi

TEMPLATE_IN="${DOCKING_APP}_in"
TEMPLATE_OUT="${DOCKING_APP}_out"

INDIR="EXAMPLE-virtualscreening_example"
INDIR_TARGETS="$INDIR/$DOCKING_APP/targets"
INDIR_LIGANDS="$INDIR/$DOCKING_APP/ligands"
INDIR_CONFIGS="$INDIR/$DOCKING_APP/configs"

if [ ! -d "$INDIR_TARGETS" ] || [ ! -d "$INDIR_LIGANDS" ] || [ ! -d "$INDIR_CONFIGS" ]; then 
  exit $CODEINPERR
fi

TARGET_FILE_NAME=$(basename $TARGET_PATH)
TARGET_BASE_NAME=$(basename $TARGET_PATH .${TARGET_EXT[$DOCKING_APP]})
PACKAGE_FILE_NAME=$(basename $PACKAGE_PATH)

if [[ "$DOCKING_APP" =~ .*cmdock$ ]]; then
  # CmDock-specific parameters of the target
  TARGET_CONF_PRM_PATH="$INDIR_CONFIGS/$TARGET_BASE_NAME.prm"
  TARGET_CONF_AS_PATH="$INDIR_CONFIGS/$TARGET_BASE_NAME.as"
  TARGET_CONF_PTC_PATH="$INDIR_CONFIGS/$TARGET_BASE_NAME.ptc"

  TARGET_CONF_PRM_FILE_NAME=$(basename $TARGET_CONF_PRM_PATH)
  TARGET_CONF_AS_FILE_NAME=$(basename $TARGET_CONF_AS_PATH)
  TARGET_CONF_PTC_FILE_NAME=$(basename $TARGET_CONF_PTC_PATH)

  PATHS=("$TARGET_CONF_PRM_PATH" "$TARGET_CONF_AS_PATH" "$TARGET_CONF_PTC_PATH" "$TARGET_PATH" "$PACKAGE_PATH")
  FILES=("$TARGET_CONF_PRM_FILE_NAME" "$TARGET_CONF_AS_FILE_NAME" "$TARGET_CONF_PTC_FILE_NAME" "$TARGET_FILE_NAME" "$PACKAGE_FILE_NAME")

else if [[ "$DOCKING_APP" =~ .*autodockvina$ ]]; then
       # AutoDock Vina-specific parameters of the target       
       TARGET_CONF_TXT_PATH="$INDIR_CONFIGS/$TARGET_BASE_NAME.txt"
       TARGET_CONF_TXT_FILE_NAME=$(basename $TARGET_CONF_TXT_PATH)

       PATHS=("$TARGET_CONF_TXT_PATH" "$TARGET_PATH" "$PACKAGE_PATH")
       FILES=("$TARGET_CONF_TXT_FILE_NAME" "$TARGET_FILE_NAME" "$PACKAGE_FILE_NAME")
     fi
fi

for VAR in "${PATHS[@]}" ; do
  if [ -z "$VAR" ] || [ ! -f "$VAR" ]; then
  echo "File \"$VAR\" is missing!"; exit $CODEINPERR; fi
done

for VAR in "${FILES[@]}" ; do
  if [ -z "$VAR" ]; then
  echo "Failed to derive the file name!"; exit $CODEINPERR; fi
done

for VAR in "${PATHS[@]}" ; do
  ./bin/stage_file --copy $VAR
  EXITCODE=$?
  if [ $EXITCODE -ne $CODESUCCESS ]; then exit $EXITCODE; fi
done

BOINC_WORKUNIT_NAME="workunit_$(date +%s.%N_$RANDOM)"

./bin/create_work --appname $DOCKING_APP --wu_template templates/$TEMPLATE_IN --result_template templates/$TEMPLATE_OUT --wu_name $BOINC_WORKUNIT_NAME ${FILES[@]} &>/dev/null

EXITCODE=$?
if [ $EXITCODE -ne $CODESUCCESS ]; then exit $EXITCODE; else echo "$BOINC_WORKUNIT_NAME"; fi

