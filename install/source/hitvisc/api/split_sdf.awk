function ceil(val) { return (val == int(val)) ? val : int(val)+1; }

BEGIN {
  a = ceil(log(N/P)/log(10))+1;
  lig = 0; ligcount = 0; packagecount = 1; LIG_ENDED = 0; PACKAGE_STARTED = 1;
  zipfile = DIRCMDOCK"/package_"LIBSYSTEMNAME"_cmdock_" sprintf("%0*d", a, packagecount) ".zip";
  outfile = "ligands.sdf"
}

{
  if(lig > N) exit 1

  if ($0 == "$$$$" || (FNR == 1 && packagecount > 1 && LIG_ENDED == 0)) {
    lig++;
    ligcount++;
    LIG_ENDED = 1;
    if (ligcount % P == 0) {
      close(outfile);
      system("zip -qjm " zipfile " " outfile);
      packagecount++;
      ligcount = 0;
      PACKAGE_STARTED = 1;
      zipfile = DIRCMDOCK"/package_"LIBSYSTEMNAME"_cmdock_" sprintf("%0*d", a, packagecount) ".zip";
    } else { PACKAGE_STARTED = 0 }
  }
  if ($0 != "$$$$") { LIG_ENDED = 0 }
  if (!( $0 == "$$$$" && PACKAGE_STARTED == 1 )) print $0 >> outfile;
}

END {
      close(outfile);
      system("if [ -f " outfile " ]; then zip -qjm " zipfile " " outfile "; fi");
}   

