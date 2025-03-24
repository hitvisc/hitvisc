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

# Usage:
USAGE_TEMPLATE="hitvisc_archive_library.sh FRONT_LIBRARY_ID"

# Get the number of arguments from template:
NARGS="$(awk '{print NF-1}' <<< "$USAGE_TEMPLATE")"
if [ "$#" -ne $NARGS ]; then log_msg_error "Wrong number of arguments ($#)"; exit $CODEARGERR; fi

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

source "$DIR/archive_library.sh" "$@"
EXITCODE=$?
if [ $EXITCODE -ne $CODESUCCESS ]; then
  let ERRCODE=$EXITCODE-256; echo $ERRCODE; exit $EXITCODE; fi

#if [ -z $LIBRARY_ID ] || [ $LIBRARY_ID -le 0 ]; then echo $CODEOTHERERR; exit $CODEOTHERERR; fi
