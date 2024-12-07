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

# Изменение статуса мишени при нажатии кнопки "Удалить мишень".
# Статусы, поддерживаемые системой: 'P' - preparing; 'U' - unlocked; 'L' - locked; 'A' - archived
# Мишень со статусом 'P' удаляется из базы данных окончательно.
# Мишень со статусом 'U' переводится в статус 'L', если она участвует хотя бы в одном активном поиске,
#                                             'A', если она участвует только в завершенных поисках,
#                        удаляется из базы данных окончательно, если она не участвует в поисках.
# Мишень со статусом 'L' переводится в статус 'A', если она участвует только в завершенных поисках.
# Мишень со статусом 'A' удаляется из базы данных окончательно, если она не участвует в поисках. 
# Во всех остальных случаях мишень не меняет свой статус.

# Usage: 
USAGE_TEMPLATE="hitvisc_delete_target.sh FRONT_TARGET_ID"

# Get the number of arguments from template:
NARGS="$(awk '{print NF-1}' <<< "$USAGE_TEMPLATE")"
if [ "$#" -ne $NARGS ]; then log_msg_error "Wrong number of arguments ($#)"; exit $CODEARGERR; fi

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

FRONT_TARGET_ID=$1
TARGET_ID=$(echo "SELECT back_entity_id FROM registry.entity_mapping WHERE front_entity_id = '$FRONT_TARGET_ID' AND entity_type = 'T';" | psql --dbname=hitvisc -qtA)
if [[ ! $TARGET_ID -gt 0 ]]; then
  log_msg_error "unable to get back_target_id by front_target_id ($FRONT_TARGET_ID)"; return $CODEARGERR; fi

## Get current state of the target
TARGET_STATE=$(echo "SELECT state FROM registry.target WHERE id=$TARGET_ID;" | psql --dbname=hitvisc -qtA)

case $TARGET_STATE in
    P)
      #boinc_app_name="test-$DOCKER_NAME";;
    U)
      #boinc_app_name="private-$DOCKER_NAME";;
    L)
      #boinc_app_name="public-$DOCKER_NAME";;
    A)

esac


