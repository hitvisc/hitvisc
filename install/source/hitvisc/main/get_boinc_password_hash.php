<?php

  if($argc == 3) {
    $passwd = $argv[1]; 
    $email  = strtolower($argv[2]);  
    $passwdhash = md5($passwd.$email);
    echo password_hash($passwdhash, PASSWORD_DEFAULT);
  } else exit(1);

?>

