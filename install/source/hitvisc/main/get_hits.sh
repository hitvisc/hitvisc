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

unset log_msg_error

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

source "$DIR/../api/hitvisc_error_codes.sh"
source "$DIR/../api/hitvisc_set_env.sh"
source "$DIR/../main/hitvisc_parse_config.sh"

if [ ! -d "$hitvisc_log_dir" ]; then log_msg_error "hitvisc_log_dir ($hitvisc_log_dir) does not exist"; return $CODEENVERR; fi
if [ ! -d "$boinc_results_dir" ]; then log_msg_error "boinc_results_dir ($boinc_results_dir) does not exist"; return $CODEENVERR; fi
if [ ! -d "$hitvisc_data_dir" ]; then log_msg_error "hitvisc_data_dir ($hitvisc_data_dir) does not exist"; return $CODEENVERR; fi

BASE_DIR="$boinc_results_dir"
MAX_WORKUNITS=20
MAX_THR=100

echo "--- Getting new hits ----------"

while IFS="|" read -r SEARCH_SYSTEM_NAME HITVISC_WU_NAME DOCKER_NAME HIT_CRIT HIT_THR_ENG HIT_THR_EFF
do
    SUCCESS=0
    HITS_DIR="$hitvisc_data_dir/search/$SEARCH_SYSTEM_NAME/hits"
    if [ ! -d "$HITS_DIR" ]; then mkdir -p "$HITS_DIR"; fi
    if [ ! -d "$HITS_DIR" ]; then log_msg_error "Hits dir not found for search $SEARCH_SYSTEM_NAME"; break; fi
    ENERGYFILE="$HITS_DIR/energies.dat"
    touch "$ENERGYFILE.tmp"

    if [ "$HIT_CRIT" == "F" ]; then HIT_THR="$HIT_THR_EFF"; else HIT_THR="$HIT_THR_ENG"; fi
    if [[ "$DOCKER_NAME" != "cmdock" ]] && [[ "$DOCKER_NAME" != "autodockvina" ]]; then
      log_msg_error "invalid value of DOCKER_NAME ($DOCKER_NAME)"; return $CODEARGERR; fi

    if [ "$DOCKER_NAME" == "autodockvina" ] && [ -f "$BASE_DIR/${HITVISC_WU_NAME}_0" ] && [ -f "$BASE_DIR/${HITVISC_WU_NAME}_1" ]; then
          eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
          conda activate hitvisc-bio
          ## Get hits for AutoDock Vina results
          OUT_DIR="$HITS_DIR/tmp_$HITVISC_WU_NAME"; mkdir -p "$OUT_DIR"
          unzip -oq "$BASE_DIR/${HITVISC_WU_NAME}_0" -d "$OUT_DIR/" && rm "$BASE_DIR/${HITVISC_WU_NAME}_0"
          mv "$BASE_DIR/${HITVISC_WU_NAME}_1" "$OUT_DIR/"
          DOCKING_OUT="$OUT_DIR/${HITVISC_WU_NAME}_1"
          dos2unix "$DOCKING_OUT" &>/dev/null # Fixes encoding in-place
          LIGAND_STR=$(awk -v n=2 '/Ligand: / { ligand = $2 } /(kcal\/mol) | rmsd l.b.| rmsd u.b./ { for (i = 1; i <= n; i++) getline; if($2~/^[-+]?[0-9\.]+$/) { print ligand, $2 }}' "$DOCKING_OUT")
          while read -r LIGAND_NAME LIG_ENG #<<< $LIGAND_STR
          do
            LIGAND_FILE="$OUT_DIR/${LIGAND_NAME}_out.pdbqt"
            if [ -f "$LIGAND_FILE" ]; then
              LIGAND_BASENAME=$(basename $LIGAND_NAME .pdbqt)
              dos2unix "$LIGAND_FILE" &>/dev/null
              while read -ra line
              do
               if [ "${line[0]}" == "num_atoms" ]; then ligand_num_atoms=${line[1]}; fi
              done <<< $(obprop "$LIGAND_FILE" 2>/dev/null)

              if [[ $ligand_num_atoms -gt 0 ]]; then LIG_EFF=$(printf '%.4f' "$(echo "$LIG_ENG/$ligand_num_atoms" | bc -l)")
              else LIG_EFF="NA"; fi
      
              ## Filter hits
              if [[ "$HIT_CRIT" == "N" && "$(echo $LIG_ENG $HIT_THR | awk '{if ($1 != "NA" && $1 <= $2) print 1}')" -eq "1" ]] || [[ "$HIT_CRIT" == "F" && "$(echo $LIG_EFF $HIT_THR | awk '{if ($1 != "NA" && $1 <= $2) print 1}')" -eq "1" ]]; then
                mv "$LIGAND_FILE" "$HITS_DIR/$LIGAND_BASENAME.pdbqt"  
                echo "$LIGAND_BASENAME,$LIG_EFF,$LIG_ENG" >> "$ENERGYFILE.tmp" 
              fi
            else 
		log_msg_error "Ligand file not found ($LIGAND_FILE)"; return $CODEOTHERERR; 
            fi
          done <<< $LIGAND_STR
          rm -rf "$OUT_DIR"
          conda deactivate
          SUCCESS=1
    fi

    if [ "$DOCKER_NAME" == "cmdock" ] && [ -f "$BASE_DIR/${HITVISC_WU_NAME}_0" ] && [ -f "$BASE_DIR/${HITVISC_WU_NAME}_1" ]; then
      ## Get hits for CmDock results
      OUT_DIR="$HITS_DIR/tmp_$HITVISC_WU_NAME"; mkdir -p "$OUT_DIR"
      cp "$BASE_DIR/${HITVISC_WU_NAME}_0" "$OUT_DIR/"
      cp "$BASE_DIR/${HITVISC_WU_NAME}_1" "$OUT_DIR/"
      dos2unix "$OUT_DIR/${HITVISC_WU_NAME}_0" &>/dev/null # Fixes encoding in-place
      dos2unix "$OUT_DIR/${HITVISC_WU_NAME}_1" &>/dev/null # Fixes encoding in-place
                                                           
      awk -v DIR="$OUT_DIR" '/\$\$\$\$/{ getline; ligand = $0 }; { if($0 != "$$$$") print $0 > DIR"/"ligand".sdf" }' "$OUT_DIR/${HITVISC_WU_NAME}_0"

      DOCKING_OUT="$OUT_DIR/${HITVISC_WU_NAME}_0"
      LIGAND_STR=$(awk -v n=1 '/<Name>/ { for (i = 1; i <= n; i++) getline; ligand = $0 }; (NF == 10 && $4 != "H") { num_atoms++ }; /<SCORE.INTER>/ { for (i = 1; i <= n; i++) getline; if(num_atoms == 0) { eff = "NA" } else { eff = $0/num_atoms }; print ligand, $0, eff; num_atoms = 0 }' "$DOCKING_OUT")
      while read -r LIGAND_NAME LIG_ENG LIG_EFF #<<< $LIGAND_STR
      do
        ## Filter hits
        if [[ "$HIT_CRIT" == "N" && "$(echo $LIG_ENG $HIT_THR | awk '{if ($1 != "NA" && $1 <= $2) print 1}')" -eq "1" ]] || [[ "$HIT_CRIT" == "F" && "$(echo $LIG_EFF $HIT_THR | awk '{if ($1 != "NA" && $1 <= $2) print 1}')" -eq "1" ]]; then
          LIGAND_FILE="$OUT_DIR/${LIGAND_NAME}.sdf"
          if [ -f "$LIGAND_FILE" ]; then
            mv "$LIGAND_FILE" "$HITS_DIR/"
            echo "$LIGAND_NAME,$LIG_EFF,$LIG_ENG" >> "$ENERGYFILE.tmp"
          else 
            log_msg_error "Ligand file not found ($LIGAND_FILE)"; return $CODEOTHERERR; 
          fi
        fi
      done <<< $LIGAND_STR
      rm -rf "$OUT_DIR"
      SUCCESS=1
    fi

    if [[ "$SUCCESS" -eq 1 ]]; then
      PSQL_STATUS=$(echo "UPDATE registry.workunit SET state_id = 5 WHERE name = '$HITVISC_WU_NAME'" | psql --dbname=hitvisc -qtA)
    fi

done < <(echo "SELECT registry.search.system_name, registry.workunit.name, registry.docker.system_name, registry.search_protocol.hit_criterion, 
               COALESCE(registry.search_protocol.hit_threshold_energy, $MAX_THR), COALESCE(registry.search_protocol.hit_threshold_efficiency, $MAX_THR) 
               FROM registry.search, registry.workunit, registry.workunit_state, registry.docker, registry.search_protocol
               WHERE registry.search.status = 'A' AND registry.workunit.search_id = registry.search.id 
               AND registry.workunit.state_id = registry.workunit_state.id AND registry.workunit_state.name LIKE 'COMPUTED' 
               AND registry.search.docker_id = registry.docker.id AND registry.search.search_protocol_id = registry.search_protocol.id 
               LIMIT $MAX_WORKUNITS;" | psql --dbname=hitvisc -qtA)
   
echo "--- End of getting new hits ---"
 
