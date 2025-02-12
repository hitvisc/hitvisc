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

BOINCPROJECTDIR="$1"

if [ ! -d "$BOINCPROJECTDIR" ]; then 
  echo "BOINC project dir \"$BOINCPROJECTDIR\" not found!"; exit -1; fi

sed -i $'/<\/daemons>/{e cat add_config.xml\n}' "$BOINCPROJECTDIR"/config.xml
sed -i $'/<\/boinc>/{e cat add_project.xml\n}' "$BOINCPROJECTDIR"/project.xml

sed -i "s/define('APP_SELECT_PREFS', false);/define('APP_SELECT_PREFS', true);/g" "$BOINCPROJECTDIR"/html/project/project.inc

# Copy newly built sample_assimilator and sample_trivial_validator for all our apps
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/cmdock_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/test-cmdock_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/private-cmdock_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/public-cmdock_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/autodockvina_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/test-autodockvina_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/private-autodockvina_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_assimilator "$BOINCPROJECTDIR"/bin/public-autodockvina_assimilator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/cmdock_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/test-cmdock_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/private-cmdock_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/public-cmdock_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/autodockvina_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/test-autodockvina_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/private-autodockvina_validator
cp "$BOINCPROJECTDIR"/bin/sample_trivial_validator "$BOINCPROJECTDIR"/bin/public-autodockvina_validator

cp -r apps/* "$BOINCPROJECTDIR"/apps/

cp templates/* "$BOINCPROJECTDIR"/templates/ 

mkdir "$BOINCPROJECTDIR"/results
mkdir "$BOINCPROJECTDIR"/sample_results

# Generate signature files for the version's files
cd "$BOINCPROJECTDIR"

for APP in cmdock test-cmdock private-cmdock public-cmdock 
do
	# CmDock version files for Linux x64
	for FILE in ${APP}_0.2.0_1.0_x86_64-pc-linux-gnu ${APP}_job_1.0_x86_64-pc-linux-gnu.xml ${APP}_docking_out_1.0_x86_64-pc-linux-gnu ${APP}_wrapper_1.0_x86_64-pc-linux-gnu
	do
		./bin/crypt_prog -sign ./apps/${APP}/1.0/x86_64-pc-linux-gnu/$FILE ./keys/code_sign_private > ./apps/${APP}/1.0/x86_64-pc-linux-gnu/$FILE.sig
	done

	# CmDock version files for Windows x64
	for FILE in ${APP}_0.2.0_1.0_windows_x86_64.zip ${APP}_wrapper_1.0_windows_x86_64.exe ${APP}_job_1.0_windows_x86_64.xml ${APP}_docking_out_1.0_windows_x86_64
	do
		./bin/crypt_prog -sign ./apps/${APP}/1.0/windows_x86_64/$FILE ./keys/code_sign_private > ./apps/${APP}/1.0/windows_x86_64/$FILE.sig
	done
done

for APP in autodockvina test-autodockvina private-autodockvina public-autodockvina
do
	# AutoDock Vina version files for Linux x64
	for FILE in ${APP}_1.2.5_1.0_x86_64-pc-linux-gnu ${APP}_job_1.0_x86_64-pc-linux-gnu.xml run_${APP}_1.0_x86_64-pc-linux-gnu.sh ${APP}_wrapper_x86_64-pc-linux-gnu
	do
	  ./bin/crypt_prog -sign ./apps/${APP}/1.0/x86_64-pc-linux-gnu/$FILE ./keys/code_sign_private > ./apps/${APP}/1.0/x86_64-pc-linux-gnu/$FILE.sig
	done

	# AutoDock Vina version files for Windows x64
	for FILE in ${APP}_1.2.5_1.0_windows_x86_64.exe ${APP}_job_1.0_windows_x86_64.xml run_${APP}_1.0_windows_x86_64.cmd ${APP}_wrapper_26016_windows_x86_64.exe
	do
	  ./bin/crypt_prog -sign ./apps/${APP}/1.0/windows_x86_64/$FILE ./keys/code_sign_private > ./apps/${APP}/1.0/windows_x86_64/$FILE.sig
	done
done

