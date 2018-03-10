<?php

if( isset( $_POST[ 'submit'] ) ) {

   $target = $_REQUEST[ 'ip' ];

   // Remove any of the charactars in the array (blacklist).
   $substitutions = array(
       '&&' => '',
       ';' => '',
   );

   $target = str_replace( array_keys( $substitutions ), $substitutions, $target );

   // Determine OS and execute the ping command.
   if (stristr(php_uname('s'), 'Windows NT')) {

       $cmd = shell_exec( 'ping  ' . $target );
       echo '<pre>'.$cmd.'</pre>';

   } else {

       $cmd = shell_exec( 'ping  -c 3 ' . $target );
       echo '<pre>'.$cmd.'</pre>';

   }
}

?> 

<html>
<body>
  <h1>Ping Site</h1>
  <p>Enter an IP address below</p>
  <form action="" method="post">
    <input type="text" name="ip" size="30"><br />
    <input type="submit" name="submit" value="実行">
  </form>
</body>
</html>
