<?php
ini_set('display_errors',1);

if(isset($_POST['submit'])){

    $address = $_POST['address'];
    $text = $_POST['text'];
    #$send_data = "echo \"$text\" | mail -s \"mail test\" $address";
    $send_data = "echo \"$text\" | mail -s \"send mail from website\" -r mail@centos.jp $address";


    #$send_data = "ls | grep \"php\"";
    #$send_data = "whoami";

    $cmd = shell_exec($send_data);
    #echo $send_data;
    #var_dump($send_data);
    #echo '<pre>'.$cmd.'</pre>';
    #exec($send_data, $output, $return_var);
    #echo $return_var;
    #echo $send_data;
}
?>

<html>
<body>
  <h1>Mail Site</h1>
  <p>Enter your Email below</p>
  <form action="" method="post">
    Input your mail address<br />
    <input type="text" name="address" size="30"><br />
    Input send text<br />
    <input type="text" name="text" size="50"><br />
    <input type="submit" name="submit" value="submit">
  </form>
</body>
</html>
