<?php
$user = 'root';
$password = 'cysec.lab';
try {
    $pdo = new PDO(
        'mysql:host=localhost;
        dbname=csrf_db;
        charset=utf8',
        $user,
        $password
    );
} catch(PDOException $e) {
    print ('Error:'.$e->getMessage());
}
if (isset($_POST['change'])) {

    $pass_new = $_POST['password_new'];
    $pass_conf = $_POST['password_confirm'];


    if (($pass_new == $pass_conf)){
        #$pass_new = mysql_real_escape_string($pass_new);
        $pass_new = md5($pass_new);

        $sql="UPDATE `users` SET password = '$pass_new' WHERE user = 'admin';";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        
        #$result=mysql_query($insert) or die('<pre>' . mysql_error() . '</pre>' );

        echo "<pre> Password Changed </pre>";
        $pdo = null;
    }

    else{
        echo "<pre> Passwords did not match. </pre>";
    }

}
?>

<html>
<body>
  <h1>Change your password</h1>
  <form action="" method="post">
    <p>New password</p>
    <input type="password" name="password_new"><br />
    <p>Confirm new password</p>
    <input type="password" name="password_confirm"><br />
    <input type="submit" name="change" value="change">
  </form>
</body>
</html>
