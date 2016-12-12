<?php
ini_set('display_errors',1);

if(isset($_POST['submit'])){

    $address = $_POST['address'];
    $text = $_POST['text'];
    $send_data = "echo \"$text\" | mail -s \"send mail from website\" -r mail@centos.jp $address";

    $cmd = shell_exec($send_data);
    if ($cmd !== null) {
        var_dump($cmd);
    }
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
