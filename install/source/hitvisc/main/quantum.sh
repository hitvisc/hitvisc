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

# Main modules of HiTViSc <-> BOINC Server interaction script

# Print start banner
now=$(date "+%Y-%m-%d %H:%M:%S")
#echo "------------------------------------------------------------------------------------------------------"
echo "--- $now : Starting module for quantum interaction of HiTViSc main module and BOINC server module. ---"
#echo "------------------------------------------------------------------------------------------------------"

HITVISC_MAIN_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

# Marking completed workunits in HiTViSc registry database
source "$HITVISC_MAIN_DIR/complete.sh"

# Hits collection for the computed workunits
source "$HITVISC_MAIN_DIR/get_hits.sh"

# Check search stop criterion and stop the search if needed
source "$HITVISC_MAIN_DIR/check_stop_search.sh"

# Generating new HiTViSc workunits if needed
source "$HITVISC_MAIN_DIR/generate_hitvisc_workunits.sh"

# Generating new BOINC workunits if needed
source "$HITVISC_MAIN_DIR/generate_boinc_workunits.sh"

# Synchronization of hosts from BOINC server database to HiTViSc registry database
source "$HITVISC_MAIN_DIR/sync_host.sh"

#echo "------------------------------------------------------------------------------------------------------"
echo "--- Quantum interaction is finished ---"
#echo "------------------------------------------------------------------------------------------------------"
