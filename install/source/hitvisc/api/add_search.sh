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

# Arguments: TMPDIR FRONT_SEARCH_ID NAME USAGE_TYPE DESCRIPTION TARGET_ID LIBRARY_ID DOCKER_NAME DOCKER_PARAMETERS_INPUT "DOCKER_PARAMETERS_FILES" "DOCKER_PARAMETERS" "SEARCH_PARAMETERS" RESOURCE_TYPE

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

# Временная папка для загрузки и обработки файлов, связанных с поиском
TMPDIR="$1"; if [ ! -d "$TMPDIR" ]; then log_msg_error "TMPDIR ($TMPDIR) does not exist"; return $CODEENVERR; fi
FRONT_SEARCH_ID="$2"; if [[ ! $FRONT_SEARCH_ID -gt 0 ]]; then log_msg_error "invalid value of FRONT_SEARCH_ID ($FRONT_SEARCH_ID)"; return $CODEARGERR; fi
SEARCH_NAME="$3"; if [ ${#SEARCH_NAME} -gt 256 ]; then log_msg_error "SEARCH_NAME too long ($SEARCH_NAME)"; return $CODEARGERR; fi
SEARCH_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))

SEARCH_DATA_DIR="$hitvisc_data_dir/search/$SEARCH_SYSTEM_NAME"
if [ -d "$SEARCH_DATA_DIR" ]; then log_msg_error "Directory SEARCH_DATA_DIR already exists ($SEARCH_DATA_DIR)"; return $CODEENVERR; fi
mkdir -p "$SEARCH_DATA_DIR"
if [ ! -d "$SEARCH_DATA_DIR" ]; then log_msg_error "Unable to create directory SEARCH_DATA_DIR ($SEARCH_DATA_DIR)"; return $CODEENVERR; fi

SEARCH_USAGE_TYPE="$4"; if [[ ! $SEARCH_USAGE_TYPE =~ ^[ORP]$ ]]; then 
  log_msg_error "invalid value of SEARCH_USAGE_TYPE ($SEARCH_USAGE_TYPE)"; return $CODEARGERR; fi

SEARCH_DESC="$5"; if [ ${#SEARCH_DESC} -gt 1024 ]; then log_msg_error "SEARCH_DESC too long ($SEARCH_DESC)"; return $CODEARGERR; fi

FRONT_TARGET_ID="$6"
TARGET_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = '$FRONT_TARGET_ID' AND entity_type = 'T';" | psql --dbname=hitvisc -qtA)
if [[ ! $TARGET_ID -gt 0 ]]; then
  log_msg_error "unable to get back_target_id by front_target_id ($FRONT_TARGET_ID)"; return $CODEARGERR; fi

FRONT_LIBRARY_ID="$7"
LIBRARY_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = '$FRONT_LIBRARY_ID' AND entity_type = 'L';" | psql --dbname=hitvisc -qtA)
if [[ ! $LIBRARY_ID -gt 0 ]]; then
  log_msg_error "unable to get back_library_id by front_library_id ($FRONT_LIBRARY_ID)"; return $CODEARGERR; fi

DOCKER_NAME="$8"

DOCKER_PARAMETERS_INPUT="$9"
DOCKER_PARAMETERS_FILES="${10}"
DOCKER_PARAMETERS="${11}"
SEARCH_PARAMETERS="${12}"

RESOURCE_TYPE="${13}"; if [[ ! $RESOURCE_TYPE =~ ^[TRP]$ ]]; then 
  log_msg_error "invalid value of RESOURCE_TYPE ($RESOURCE_TYPE)"; return $CODEARGERR; fi

SEARCH_PREFIX=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))
SEARCH_STATE='P' # initially the state 'preparing'

# TODO: Check if a search with the specified name does not exist
# TODO: Check if a search with the specified system name does not exist
# TODO: Check if the target with the specified id exists
# TODO: Check if the library with the specified id exists

if [[ "$DOCKER_NAME" != "cmdock" ]] && [[ "$DOCKER_NAME" != "autodockvina" ]]; then 
  log_msg_error "invalid value of DOCKER_NAME ($DOCKER_NAME)"; return $CODEARGERR; fi

case $RESOURCE_TYPE in
    T)
      boinc_app_name="test-$DOCKER_NAME";;
    R)
      boinc_app_name="private-$DOCKER_NAME";;
    P) 
      boinc_app_name="public-$DOCKER_NAME";;
esac

# TODO: Get docker id from database
if [[ "$DOCKER_NAME" == "cmdock" ]]; then DOCKER_ID=1; fi
if [[ "$DOCKER_NAME" == "autodockvina" ]]; then DOCKER_ID=2; fi

## Parse and validate docker parameters

  BOINC_IN_TEMPLATE_PATH="templates/${boinc_app_name}_in"
  BOINC_OUT_TEMPLATE_PATH="templates/${boinc_app_name}_out"
  BOINC_IN_TEMPLATE_NAME="${boinc_app_name}_in"
  BOINC_OUT_TEMPLATE_NAME="${boinc_app_name}_out"

## TODO: CmDock, manual input
#
#if [[ "$DOCKER_NAME" == "cmdock" && "$DOCKER_PARAMETERS_INPUT" == "M" ]]; then
#  DOCKER_PARAMETERS_TEMPLATE="CAV_RADIUS SMALL_SPHERE_RADIUS MAX_CAV MIN_VOL VOL_INC CENTER_X CENTER_Y CENTER_Z LARGE_SPHERE_RADIUS STEP"
#  template_parameters=($DOCKER_PARAMETERS_TEMPLATE)
#  array_parameters=($DOCKER_PARAMETERS)
#  if [ "${#array_parameters[@]}" -ne "${#template_parameters[@]}" ]; then
#    log_msg_error "Wrong number of DOCKER_PARAMETERS ($DOCKER_PARAMETERS)"; return $CODEARGERR; fi
#  read -r CAV_RADIUS SMALL_SPHERE_RADIUS MAX_CAV MIN_VOL VOL_INC CENTER_X CENTER_Y CENTER_Z LARGE_SPHERE_RADIUS STEP <<< "$DOCKER_PARAMETERS"
#  # TODO
#
#fi

## CmDock, file upload
if [[ "$DOCKER_NAME" == "cmdock" && "$DOCKER_PARAMETERS_INPUT" == "F" ]]; then
  DOCKER_PARAMETERS_FILES_TEMPLATE="PRM_FNAME PRM_ORIGINAL_FNAME PRM_EXT AS_FNAME AS_ORIGINAL_FNAME AS_EXT PTC_FNAME PTC_ORIGINAL_FNAME PTC_EXT"
  template_parameters=($DOCKER_PARAMETERS_FILES_TEMPLATE)
  array_parameters=($DOCKER_PARAMETERS_FILES)
  if [ "${#array_parameters[@]}" -ne "${#template_parameters[@]}" ]; then
    log_msg_error "Wrong number of DOCKER_PARAMETERS_FILES ($DOCKER_PARAMETERS_FILES)"; return $CODEARGERR; fi
  read -r PRM_FNAME PRM_ORIGINAL_FNAME PRM_EXT AS_FNAME AS_ORIGINAL_FNAME AS_EXT PTC_FNAME PTC_ORIGINAL_FNAME PTC_EXT <<< "$DOCKER_PARAMETERS_FILES"
  if [ ! -f "$TMPDIR/$PRM_FNAME" ] || [ ! -f "$TMPDIR/$AS_FNAME" ] || [ ! -f "$TMPDIR/$PTC_FNAME" ]; then
    log_msg_error "One or more of user-uploaded files not found ($TMPDIR/$PRM_FNAME $TMPDIR/$AS_FNAME $TMPDIR/$PTC_FNAME)"; return $CODEARGERR; fi

  TMP_NAME_PRM="search_$SEARCH_SYSTEM_NAME.prm" #"$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000)).prm"
  CONFIG_PATH_PRM="$SEARCH_DATA_DIR/$TMP_NAME_PRM"
  # Copy the parameters file to the final location
  cp "$TMPDIR/$PRM_FNAME" "$CONFIG_PATH_PRM"
  if [ ! -f "$CONFIG_PATH_PRM" ]; then log_msg_error "Unable to create docker configuration file ($CONFIG_PATH_PRM)"; return $CODEENVERR; fi
  CONFIG_NAME_PRM=$(basename $CONFIG_PATH_PRM)

  grep 'RECEPTOR_FILE' $CONFIG_PATH_PRM >/dev/null; if [ $? -ne 0 ]; then 
    echo "RECEPTOR_FILE target.mol2" >> $CONFIG_PATH_PRM
  else 
    # Correct the filename of target.mol2 for BOINC (RECEPTOR_FILE target.mol2)
    sed -i 's/RECEPTOR_FILE[[:blank:]]*.*.mol2/RECEPTOR_FILE target.mol2/' $CONFIG_PATH_PRM
  fi

  TMP_NAME_AS="search_$SEARCH_SYSTEM_NAME.as" #"$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000)).as"
  CONFIG_PATH_AS="$SEARCH_DATA_DIR/$TMP_NAME_AS"
  # Copy the parameters file to the final location
  cp "$TMPDIR/$AS_FNAME" "$CONFIG_PATH_AS"
  if [ ! -f "$CONFIG_PATH_AS" ]; then log_msg_error "Unable to create docker configuration file ($CONFIG_PATH_AS)"; return $CODEENVERR; fi
  CONFIG_NAME_AS=$(basename $CONFIG_PATH_AS)

  TMP_NAME_PTC="search_$SEARCH_SYSTEM_NAME.ptc" #"$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000)).ptc"
  CONFIG_PATH_PTC="$SEARCH_DATA_DIR/$TMP_NAME_PTC"
  # Copy the parameters file to the final location
  cp "$TMPDIR/$PTC_FNAME" "$CONFIG_PATH_PTC"
  if [ ! -f "$CONFIG_PATH_PTC" ]; then log_msg_error "Unable to create docker configuration file ($CONFIG_PATH_PTC)"; return $CODEENVERR; fi
  CONFIG_NAME_PTC=$(basename $CONFIG_PATH_PTC)

  DOCKER_PROTOCOL_NAME="Docker protocol for CmDock (search $SEARCH_SYSTEM_NAME)"
  DOCKER_PROTOCOL_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))
  DOCKER_PROTOCOL_DESC="Docker protocol for CmDock (search $SEARCH_SYSTEM_NAME)"
  DOCKER_PROTOCOL_ID=$(echo "SELECT registry.docker_cmdock_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH_PRM', '$CONFIG_NAME_PRM', '$CONFIG_PATH_AS', '$CONFIG_NAME_AS', '$CONFIG_PATH_PTC', '$CONFIG_NAME_PTC');" | psql --dbname=hitvisc -qtA)
  if [[ $DOCKER_PROTOCOL_ID -le 0 ]]; then
    log_msg_error "unable to create new docker protocol (cmd: SELECT registry.docker_cmdock_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH_PRM', '$CONFIG_NAME_PRM', '$CONFIG_PATH_AS', '$CONFIG_NAME_AS', '$CONFIG_PATH_PTC', '$CONFIG_NAME_PTC');"; return $CODEPSQLERR; fi
fi

## AutoDock Vina, manual input
if [[ "$DOCKER_NAME" == "autodockvina" && "$DOCKER_PARAMETERS_INPUT" == "M" ]]; then
  DOCKER_PARAMETERS_TEMPLATE="CENTER_X CENTER_Y CENTER_Z SIZE_X SIZE_Y SIZE_Z EXHAUSTIVENESS NMODES ERANGE"
  template_parameters=($DOCKER_PARAMETERS_TEMPLATE)
  array_parameters=($DOCKER_PARAMETERS)
  if [ "${#array_parameters[@]}" -ne "${#template_parameters[@]}" ]; then
    log_msg_error "Wrong number of DOCKER_PARAMETERS ($DOCKER_PARAMETERS)"; return $CODEARGERR; fi
  read -r CENTER_X CENTER_Y CENTER_Z SIZE_X SIZE_Y SIZE_Z EXHAUSTIVENESS NMODES ERANGE <<< "$DOCKER_PARAMETERS"

  TMP_NAME="search_${SEARCH_SYSTEM_NAME}_conf.txt" #"$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000)).txt"
  TMP_PARAM="$TMPDIR/$TMP_NAME"
  CONFIG_PATH="$SEARCH_DATA_DIR/$TMP_NAME"

  source "$DIR/validate_docker_parameters_autodockvina.sh"

  echo -e "center_x = $CENTER_X\ncenter_y = $CENTER_Y\ncenter_z = $CENTER_Z\n" >> $TMP_PARAM
  echo -e "size_x = $SIZE_X\nsize_y = $SIZE_Y\nsize_z = $SIZE_Z\n" >> $TMP_PARAM
  echo -e "energy_range = $ERANGE\nnum_modes = $NMODES\nexhaustiveness = $EXHAUSTIVENESS\n" >> $TMP_PARAM

  # Move the generated parameters file to the final location
  mv $TMP_PARAM $CONFIG_PATH
  if [ ! -f "$CONFIG_PATH" ]; then log_msg_error "unable to create docker configuration file ($CONFIG_PATH)"; return $CODEENVERR; fi

  CONFIG_NAME=$(basename $CONFIG_PATH)
  DOCKER_PROTOCOL_NAME="Docker protocol for AutoDock Vina (search $SEARCH_SYSTEM_NAME)"
  DOCKER_PROTOCOL_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))
  DOCKER_PROTOCOL_DESC="Docker protocol for AutoDock Vina (search $SEARCH_SYSTEM_NAME)"
  DOCKER_PROTOCOL_ID=$(echo "SELECT registry.docker_autodockvina_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH', '$CONFIG_NAME');" | psql --dbname=hitvisc -qtA)
  if [[ $DOCKER_PROTOCOL_ID -le 0 ]]; then
    log_msg_error "unable to create new docker protocol (cmd: SELECT registry.docker_autodockvina_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH', '$CONFIG_NAME');"; return $CODEPSQLERR; fi
fi

## AutoDock Vina, file upload
if [[ "$DOCKER_NAME" == "autodockvina" && "$DOCKER_PARAMETERS_INPUT" == "F" ]]; then
  DOCKER_PARAMETERS_FILES_TEMPLATE="CONFIG_FNAME CONFIG_ORIGINAL_FNAME CONFIG_EXT"
  template_parameters=($DOCKER_PARAMETERS_FILES_TEMPLATE)
  array_parameters=($DOCKER_PARAMETERS_FILES)
  if [ "${#array_parameters[@]}" -ne "${#template_parameters[@]}" ]; then
    log_msg_error "Wrong number of DOCKER_PARAMETERS_FILES ($DOCKER_PARAMETERS_FILES)"; return $CODEARGERR; fi
  read -r CONFIG_FNAME CONFIG_ORIGINAL_FNAME CONFIG_EXT <<< "$DOCKER_PARAMETERS_FILES"
  if [ ! -f "$TMPDIR/$CONFIG_FNAME" ]; then
    log_msg_error "User-uploaded config file for AutoDock Vina not found ($TMPDIR/$CONFIG_FNAME)"; return $CODEARGERR; fi
  
    # TODO: Parse docker parameters file and check its correctness
    #source "$DIR/../bio/parse_config_autodockvina.sh $TMPDIR/$CONFIG_FNAME"

    TMP_NAME="search_${SEARCH_SYSTEM_NAME}_conf.txt" #"$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000)).txt"
    CONFIG_PATH="$SEARCH_DATA_DIR/$TMP_NAME" 
    # Copy the parameters file to the final location
    cp "$TMPDIR/$CONFIG_FNAME" "$CONFIG_PATH"
    if [ ! -f "$CONFIG_PATH" ]; then log_msg_error "Unable to create docker configuration file ($CONFIG_PATH)"; return $CODEENVERR; fi

    CONFIG_NAME=$(basename $CONFIG_PATH)
    DOCKER_PROTOCOL_NAME="Docker protocol for AutoDock Vina (search $SEARCH_SYSTEM_NAME)"
    DOCKER_PROTOCOL_SYSTEM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 3; echo '')_$(($(date +%s%N)/1000000))
    DOCKER_PROTOCOL_DESC="Docker protocol for AutoDock Vina (search $SEARCH_SYSTEM_NAME)"
    DOCKER_PROTOCOL_ID=$(echo "SELECT registry.docker_autodockvina_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH', '$CONFIG_NAME');" | psql --dbname=hitvisc -qtA)
    if [[ $DOCKER_PROTOCOL_ID -le 0 ]]; then
      log_msg_error "unable to create new docker protocol (cmd: SELECT registry.docker_autodockvina_protocol_add('$DOCKER_PROTOCOL_NAME', '$DOCKER_PROTOCOL_SYSTEM_NAME', '$DOCKER_PROTOCOL_DESC', '$BOINC_IN_TEMPLATE_PATH', '$BOINC_IN_TEMPLATE_NAME', '$BOINC_OUT_TEMPLATE_PATH', '$BOINC_OUT_TEMPLATE_NAME', '$CONFIG_PATH', '$CONFIG_NAME');"; return $CODEPSQLERR; fi
fi


## Parse and validate search parameters
SEARCH_PARAMETERS_TEMPLATE="CRIT_HIT BIND_EN LIG_EFF CRIT_STOP PCENT_LIG_TESTED N_HITS_FOUND PCENT_HITS NOTIFY_HITS NOTIFY_LIGS NOTIFY_N_LIGS"
template_parameters=($SEARCH_PARAMETERS_TEMPLATE)
array_parameters=($SEARCH_PARAMETERS)
if [ "${#array_parameters[@]}" -ne "${#template_parameters[@]}" ]; then
  log_msg_error "Wrong number of SEARCH_PARAMETERS ($SEARCH_PARAMETERS)"; return $CODEARGERR; fi

read -r CRIT_HIT BIND_EN LIG_EFF CRIT_STOP PCENT_LIG_TESTED N_HITS_FOUND PCENT_HITS t_is_notify_hits t_is_notify_fr_ligs NOTIFY_N_LIGS <<< "$SEARCH_PARAMETERS"
source "$DIR/validate_search_parameters.sh"
EXITCODE=$?
if [ "$EXITCODE" -ne 0 ]; then log_msg_error "Invalid search parameters ($SEARCH_PARAMETERS)"; return $EXITCODE; fi

SEARCH_PROTOCOL_ID=$(echo "SELECT registry.hitvisc_search_protocol_add('$CRIT_HIT', $BIND_EN, $LIG_EFF, '$CRIT_STOP', $PCENT_LIG_TESTED, $N_HITS_FOUND, $PCENT_HITS, '$NOTIFY_HITS', '$NOTIFY_LIGS', $NOTIFY_N_LIGS);" | psql --dbname=hitvisc -qtA)
if [[ $SEARCH_PROTOCOL_ID -le 0 ]]; then
  # TODO: delete docker protocol
  log_msg_error "unable to create new search protocol (cmd: SELECT registry.hitvisc_search_protocol_add('$CRIT_HIT', $BIND_EN, $LIG_EFF, '$CRIT_STOP', $PCENT_LIG_TESTED, $N_HITS_FOUND, $PCENT_HITS, '$NOTIFY_HITS', '$NOTIFY_LIGS', $NOTIFY_N_LIGS);"; return $CODEPSQLERR; fi

## Create a new search with the obtained parameters

SEARCH_ID=$(echo "SELECT registry.hitvisc_search_add('$SEARCH_NAME', '$SEARCH_SYSTEM_NAME', '$SEARCH_DESC', $TARGET_ID, $LIBRARY_ID, $DOCKER_ID, $DOCKER_PROTOCOL_ID, $SEARCH_PROTOCOL_ID, '$RESOURCE_TYPE', '$SEARCH_PREFIX', '$SEARCH_STATE');" | psql --dbname=hitvisc -qtA)

if [[ $SEARCH_ID -gt 0 ]]; then
  PSQL_STATUS=$(echo "UPDATE registry.search SET state = 'U' WHERE id = $SEARCH_ID; UPDATE registry.target SET state = 'I' WHERE id = $TARGET_ID; UPDATE registry.library SET state = 'I' WHERE id = $LIBRARY_ID;" | psql --dbname=hitvisc -qtA)
  ENTITY_MAPPING_ID=$(echo "SELECT registry.hitvisc_entity_mapping_add($FRONT_SEARCH_ID, $SEARCH_ID, 'S');" | psql --dbname=hitvisc -qtA)
else
  # TODO: delete docker protocol and search protocol
  log_msg_error "unable to create new search (cmd: SELECT registry.hitvisc_search_add('$SEARCH_NAME', '$SEARCH_SYSTEM_NAME', '$SEARCH_DESC', $TARGET_ID, $LIBRARY_ID, $DOCKER_ID, $DOCKER_PROTOCOL_ID, $SEARCH_PROTOCOL_ID, '$RESOURCE_TYPE', '$SEARCH_PREFIX', '$SEARCH_STATE');)"; return $CODEPSQLERR; fi

if [[ $ENTITY_MAPPING_ID -le 0 ]]; then 
  log_msg_error "unable to create mapping between front_search (id $FRONT_SEARCH_ID) and back_search (id $SEARCH_ID)"; return $CODEPSQLERR; fi


