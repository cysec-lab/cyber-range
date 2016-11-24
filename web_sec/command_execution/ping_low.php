<?php
ini_set('display_errors', 1);
if(isset( $_POST['submit'])){

   $ip = $_POST['ip'];
   #$ip = $_REQUEST[ 'ip' ];

   if(stristr(php_uname('s'), 'Windows NT')){
       $cmd = shell_exec('ping ' . $ip );
       echo '<pre>'.$cmd.'</pre>';
   } else {
       #$cmd = shell_exec("ping -c 3 $ip 2>&1");
       system("ping -c 3 $ip 2>&1", $cmd);
       #$cmd = shell_exec('ping  -c 3 ' . $ip);
       #print ($ip);
       #print ('print'.strlen($cmd));
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
    <input type="submit" name="submit" value="Submit">
  </form>
</body>
</html>

