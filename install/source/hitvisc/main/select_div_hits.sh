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

# ENERGYFILE="$HITS_DIR/energies.dat"  # Must have this value from parent script
TABLEFILE="$HITS_DIR/table.dat"        # Output file
TOP=$1                                 # Number of ligands to select
SETNAME="$SEARCH_ID"                   # Set name to display
DIAGRAMFILE="$HITS_DIR/table.png"      # Diagram output file
OUTPUT_DIV_ZIP="$HITS_DIR_DIV/hitvisc_hits_div.zip"
OUTPUT_VIZ_ZIP="$HITS_DIR_VIZ/hitvisc_hits_viz.zip"

if [ ! -f "$ENERGYFILE" ]; then log_msg_error "ENERGYFILE not found ($ENERGYFILE)"; return $CODEOTHERERR; fi
if [[ ! "$TOP" -gt 0 ]]; then log_msg_error "Wrong value of TOP parameter ($TOP)"; return $CODEARGERR; fi
if [ -f "$TABLEFILE" ]; then rm "$TABLEFILE"; fi
if [ -f "$DIAGRAMFILE" ]; then rm "$DIAGRAMFILE"; fi

LOCKFILE="$hitvisc_data_dir/select_div_hits.lock"
if [ -f "$LOCKFILE" ]; then log_msg_error "Stop executing select_div_hits.sh because lockfile is present"; return 0; fi
touch "$LOCKFILE"

FACT_HITS=$(wc -l < "$ENERGYFILE")
if [[ $FACT_HITS -eq 0 ]]; then 
  NCLUSTERS=0; NSELECTED=0;
  else 
    if [[ $FACT_HITS -eq 1 ]]; then
      NCLUSTERS=1; NSELECTED=1; fi
    if [[ $FACT_HITS -gt 1 ]]; then
      # Determine the number of clusters automatically
      NCLUSTERS=$(echo "$TOP" | awk '{x=sqrt($1); printf("%d\n", x+0.9)}')
      NSELECTED=1 
    fi
fi

if [[ $FACT_HITS -lt $TOP ]]; then let "TOP=FACT_HITS"; fi

echo "------ Search $SEARCH_ID ($SEARCH_SYSTEM_NAME): $FACT_HITS hits found, will select $TOP top hits ----"

## Выбор заданного числа хитов с наилучшими энергиями связывания
## и попарное вычисление их химического сходства (коэффициента Танимото).
  
if [[ $TOP -eq 0 ]] || [[ $FACT_HITS -eq 0 ]]; then
  hitdata=$(head -1 $ENERGYFILE)
  echo "$hitdata" > $TABLEFILE 
else
  if [[ $FACT_HITS -gt 0 ]]; then 
  echo "------ Start creating the table of $TOP best hits ----" 
    eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"
    conda activate hitvisc-bio
    declare -A arr; x=1
    for reflig in $(head -$TOP $ENERGYFILE)
    do
      IFS=',' read -r REFLIGNAME EFFICIENCY ENERGY <<< $reflig
      REF_LIG_FILE="$HITS_DIR/$REFLIGNAME.$EXT"
      if [ ! -f "$REF_LIG_FILE" ]; then log_msg_error "Ligand file not found ($REF_LIG_FILE)"; return $CODEOTHERERR; fi
      echo -n "$REFLIGNAME $EFFICIENCY $ENERGY " >> $TABLEFILE
      y=1
      for testlig in $(head -$TOP $ENERGYFILE)
      do
        if [ -z ${arr[${x},${y}]} ]; then
          TESTLIGNAME=$(echo $testlig | cut -d',' -f1)
          TEST_LIG_FILE="$HITS_DIR/$TESTLIGNAME.$EXT"
          TANIMOTO_COEFF=$(obabel $REF_LIG_FILE $TEST_LIG_FILE -e --errorlevel 1 -ofpt 2>/dev/null | awk -F' ' "match(\$0,\"Tanimoto from .+ = ([0-9.]+)\",a){print a[1]; exit 0 }")
          if [ -z $TANIMOTO_COEFF ]; then 
            log_msg_error "Failed to get Tanimoto coefficient ($REF_LIG_FILE and $TEST_LIG_FILE)"; 
            TANIMOTO_COEFF="NA"
            #return $CODEOTHERERR; 
          fi
          arr[${x},${y}]=$TANIMOTO_COEFF; arr[${y},${x}]=$TANIMOTO_COEFF
        fi
        let "y++"
      done
      for t in $(seq 1 $TOP); do echo -n ${arr[${x},${t}]}" " >> $TABLEFILE; done
      let "x++"
      echo "" >> $TABLEFILE
    done
    conda deactivate
  echo "------ The table of $TOP best hits has been created ----"
  fi
fi

if [ -f "$TABLEFILE" ]; then zip -qju "$OUTPUT_DIV_ZIP" "$TABLEFILE" 
else log_msg_error "Failed to zip results file ($TABLEFILE)"; return $CODEOTHERERR; fi
if [ ! -f "$OUTPUT_DIV_ZIP" ]; then log_msg_error "Failed to zip results file"; return $CODEOTHERERR; fi

## Генерация диаграммы, визуализирующей итоговое подмножество хитов
## с автоматической кластеризацией и выбора заданного числа хитов
## с наилучшими энергиями связывания из каждого кластера.
echo "------ Start hits visualisation ----"
Rscript plot_hits.R "$TABLEFILE" "$SETNAME" "$DIAGRAMFILE" $NCLUSTERS $NSELECTED "$hitvisc_log_dir/api.log"
echo "------ Stop hits visualisation ----"

if [ -f "$DIAGRAMFILE" ]; then 
  zip -qjum "$OUTPUT_VIZ_ZIP" "$DIAGRAMFILE" 
  if [ -f "selected_ligands.txt" ]; then zip -qjum "$OUTPUT_VIZ_ZIP" "selected_ligands.txt"; fi
else log_msg_error "Failed to zip results visualisation ($DIAGRAMFILE)"; return $CODEOTHERERR; fi 

if [ ! -f "$OUTPUT_VIZ_ZIP" ]; then log_msg_error "Failed to zip results visualisation"; return $CODEOTHERERR; fi

rm "$TABLEFILE" "$ENERGYFILE"
find "$HITS_DIR" -maxdepth 1 -type f -name "*.$EXT" -print0 | xargs -0 rm

rm -f "$LOCKFILE"

