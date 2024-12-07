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

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source "$DIR/../api/hitvisc_api_init.sh"

BASE_DIR="$boinc_results_dir"
TOP=100  # Maximal number of top hits to select

while IFS="|" read -r SEARCH_ID SEARCH_SYSTEM_NAME DOCKER_NAME
do
    if [[ ! $SEARCH_ID =~ ^[0-9]+$ ]]; then log_msg_error "Invalid SEARCH_ID ($SEARCH_ID)"; rm "$LOCKFILE"; return $CODEARGERR; fi
    LOCKFILE="$hitvisc_data_dir/check_stop_search_${SEARCH_ID}.lock"
    if [ -f "$LOCKFILE" ]; then log_msg_error "Stop check_stop_search.sh because lockfile is present"; return 0; fi
    touch "$LOCKFILE"
    IFS="|" read -r stop_criterion stop_fraction_ligands stop_count_hits stop_fraction_hits is_notify_hits is_notify_fraction_ligands value_notify_fraction_ligands <<< $(echo "SELECT stop_criterion, stop_fraction_ligands, stop_count_hits, stop_fraction_hits, is_notify_hits, 
               is_notify_fraction_ligands, value_notify_fraction_ligands, docker_id FROM registry.search, registry.search_protocol 
               WHERE registry.search.id = $SEARCH_ID AND registry.search.search_protocol_id = registry.search_protocol.id;" | psql --dbname=hitvisc -qtA)

    # stop_criterion: L - "% проверенных лигандов", H - "Число найденных хитов", F - "% хитов от числа лигандов"
    # stop_fraction_ligands: value or ''
    # stop_count_hits: value or ''
    # stop_fraction_hits: value or ''
    # is_notify_hits: t or f
    # is_notify_fraction_ligands: t or f
    # value_notify_fraction_ligands: value or ''

    # Общее число лигандов для данного поиска
    N_LIGANDS=$(echo "SELECT SUM(registry.package.ligand_count) FROM registry.search, registry.library, registry.package 
                      WHERE registry.search.id = $SEARCH_ID AND registry.search.library_id = registry.library.id 
                      AND registry.package.library_id = registry.library.id 
                      AND registry.package.docker_id = registry.search.docker_id;" | psql --dbname=hitvisc -qtA)

    if [ -z $N_LIGANDS ] && [[ ! $N_LIGANDS -gt 0 ]]; then N_LIGANDS=0; fi
    echo "--- $N_LIGANDS ligands exist for search $SEARCH_ID"
    if [[ ! $N_LIGANDS -gt 0 ]]; then log_msg_error "No ligands found for search $SEARCH_ID"; rm "$LOCKFILE"; return $CODEOTHERERR; fi

    # Число проверенных лигандов для данного поиска
    N_CHK_LIGANDS=$(echo "SELECT SUM(registry.package.ligand_count) FROM registry.workunit, registry.workunit_state, registry.search, registry.package 
                          WHERE registry.search.id = $SEARCH_ID AND registry.search.id = registry.workunit.search_id 
                          AND registry.workunit_state.id = registry.workunit.state_id 
                          AND registry.package.docker_id = registry.search.docker_id
                          AND registry.workunit_state.name IN ('COMPUTED', 'ERROR', 'FINISHED', 'NOT_NEEDED') 
                          AND registry.workunit.package_id = registry.package.id;" | psql --dbname=hitvisc -qtA)

    if [ -z $N_CHK_LIGANDS ] && [[ ! $N_CHK_LIGANDS -gt 0 ]]; then N_CHK_LIGANDS=0; fi
    echo "--- $N_CHK_LIGANDS ligands checked for search $SEARCH_ID"    

    STOP_SEARCH=0
    HITS_DIR="$hitvisc_data_dir/search/$SEARCH_SYSTEM_NAME/hits"

    if [[ "$DOCKER_NAME" == "cmdock" ]]; then EXT="sdf"; else if [[ "$DOCKER_NAME" == "autodockvina" ]]; then EXT="pdbqt"; fi; fi
    if [ -z "$EXT" ]; then log_msg_error "Unable to get hits extension for search $SEARCH_ID"; rm "$LOCKFILE"; return $CODEENVERR; fi

    ## Check stop criterion
    if [[ $N_CHK_LIGANDS -ge $N_LIGANDS ]]; then 
      STOP_SEARCH=1
      echo "------ Stop search $SEARCH_ID because $N_CHK_LIGANDS >= $N_LIGANDS (always stop in this case)"
    else
      # 1) Stop when the given fraction of ligands has been checked
      if [[ "$stop_criterion" = "L" ]] && [[ "$(echo $N_CHK_LIGANDS $N_LIGANDS $stop_fraction_ligands | awk '{if ($1/$2 >= $3) print 1}')" -eq "1" ]]; then
        STOP_SEARCH=1
        echo "------ Stop search $SEARCH_ID because $N_CHK_LIGANDS / $N_LIGANDS >= $stop_fraction_ligands (stop_fraction_ligands)"
      else
        if [ ! -d "$HITS_DIR" ]; then N_FOUND_HITS=0; else N_FOUND_HITS=$(find "$HITS_DIR" -name "*.$EXT" -maxdepth 1 -type f -print | wc -l); fi
        if [ ! -z $N_FOUND_HITS ]; then
          # 2) Stop when the given number of hits has been found
          if [[ "$stop_criterion" = "H" ]] && [[ $N_FOUND_HITS -ge $stop_count_hits ]]; then
            STOP_SEARCH=1
            echo "------ Stop search $SEARCH_ID because $N_FOUND_HITS >= $stop_count_hits (stop_count_hits)"
          fi
          # 3) Stop when the given fraction of hits has been reached
          if [[ "$stop_criterion" = "F" ]] && [[ "$(echo $N_FOUND_HITS $N_CHK_LIGANDS $stop_fraction_hits | awk '{if ($1/$2 >= $3) print 1}')" -eq "1" ]]; then
            STOP_SEARCH=1
            echo "------ Stop search $SEARCH_ID because $N_FOUND_HITS / $N_CHK_LIGANDS >= $stop_fraction_hits (stop_fraction_hits)"
          fi
        fi
      fi
    fi

    ## If stop criterion has been met:
    if [[ $STOP_SEARCH = 1 ]]; then
        if [ ! -d "$HITS_DIR" ]; then log_msg_error "HITS_DIR not found ($HITS_DIR)"; rm "$LOCKFILE"; return $CODEENVERR; fi

        # Mark workunits with unprocessed results as not needed
        PSQL_STATUS=$(echo "UPDATE registry.workunit SET state_id = (SELECT id FROM registry.workunit_state WHERE name = 'NOT_NEEDED') 
                            WHERE registry.workunit.search_id = $SEARCH_ID AND state_id IN (SELECT id FROM registry.workunit_state 
                            WHERE name IN ('GENERATED', 'IN_PROCESS'));" | psql --dbname=hitvisc -qtA)
          
        TEST=$(find "$HITS_DIR" -name "*.$EXT" -maxdepth 1 -type f -print -quit)
        if [ ! -z "$TEST" ]; then
          ENERGYFILE="$HITS_DIR/energies.dat"

          if [ -f "$ENERGYFILE.tmp" ]; then sort -n -t',' -k3,3 "$ENERGYFILE.tmp" > "$ENERGYFILE"; rm "$ENERGYFILE.tmp"
          else log_msg_error "File energies.dat.tmp not found ($ENERGYFILE.tmp)"; fi

          # All hits
          HITS_DIR_ALL="$HITS_DIR/all"; HITS_DIR_DIV="$HITS_DIR/div"; HITS_DIR_VIZ="$HITS_DIR/viz"
          for dir in "$HITS_DIR_ALL" "$HITS_DIR_DIV" "$HITS_DIR_VIZ"; do mkdir -p "$dir"; done

          find "$HITS_DIR" -maxdepth 1 -type f -name "*.$EXT" -print0 | xargs -0 zip -qju "$HITS_DIR_ALL/hitvisc_hits_all.zip" -@

          # Diverse hits and visualisation
          # TODO: detect TOP automatically
          source "$DIR/../main/select_div_hits.sh" $TOP

          # Results have been processed. Update search status
          PSQL_STATUS=$(echo "UPDATE registry.search SET status = 'F' WHERE registry.search.id = $SEARCH_ID;" | psql --dbname=hitvisc -qtA)
        else # if [ ! -z "$TEST" ] -- файлы хитов 
          echo -n "" > "$ENERGYFILE"; rm "$ENERGYFILE.tmp"
          echo "Stop search criteria has been met but no hits found for search $SEARCH_ID (dir $HITS_DIR)"
          PSQL_STATUS=$(echo "UPDATE registry.search SET status = 'F' WHERE registry.search.id = $SEARCH_ID;" | psql --dbname=hitvisc -qtA)
        fi # if [ ! -z "$TEST" ] -- файлы хитов
    fi # if [[ $STOP_SEARCH = 1 ]]

  rm "$LOCKFILE"
done < <(echo "SELECT registry.search.id, registry.search.system_name, registry.docker.system_name FROM registry.search, registry.docker 
         WHERE registry.search.docker_id = registry.docker.id AND registry.search.state = 'U' AND registry.search.status = 'A';" | psql --dbname=hitvisc -qtA)

