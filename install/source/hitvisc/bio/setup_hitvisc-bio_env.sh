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

eval "$(/app/third-party/anaconda/bin/conda 'shell.bash' 'hook' 2>/dev/null)"

#conda create -y -n hitvisc-bio openbabel mgltools -c bioconda
conda create -y -n hitvisc-bio -c conda-forge -c bioconda openbabel mgltools

# Заменить python на python2 в prepare_receptor4.py и prepare_ligand4.py,
# так как MGLTools использует Python 2.
sed -i 's/\#\!\/usr\/bin\/env python/\#\!\/usr\/bin\/env python2/' /app/third-party/anaconda/pkgs/mgltools-*/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py
sed -i 's/\#\!\/usr\/bin\/env python/\#\!\/usr\/bin\/env python2/' /app/third-party/anaconda/pkgs/mgltools-*/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py

sed -i 's/\#\!\/usr\/bin\/env python/\#\!\/usr\/bin\/env python2/' /app/third-party/anaconda/envs/hitvisc-bio/bin/prepare_ligand4.py
sed -i 's/\#\!\/usr\/bin\/env python/\#\!\/usr\/bin\/env python2/' /app/third-party/anaconda/envs/hitvisc-bio/bin/prepare_receptor4.py
