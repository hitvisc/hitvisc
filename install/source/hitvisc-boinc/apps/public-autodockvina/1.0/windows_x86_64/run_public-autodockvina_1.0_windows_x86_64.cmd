
REM Parse command line args
set RECEPTOR="receptor.pdbqt"
set CONFIG="conf.txt"

for %%L in (*.pdbqt) do (public-autodockvina.exe --receptor %RECEPTOR% --config %CONFIG% --ligand %%L --out %%L_out.pdbqt > %%L_out.txt)
