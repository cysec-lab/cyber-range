<?php
session_start();

// ログイン状態のチェック
if (!isset($_SESSION['NAME'])) {
  header("Location: logout.php");
  exit;
}
?>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>掲示板サイト</title>
  </head>
  <body>
    <h1>掲示板</h1>
    <!-- ユーザIDにHTMLタグが含まれても良いようにエスケープする -->
    <p>ようこそ<?=htmlspecialchars($_SESSION['NAME'], ENT_QUOTES); ?>さん</p>
    自由に投稿してください
    <form action="" method="post">
      <p>メッセージ</p>
      <textarea type="text" name="message" size="50"></textarea><br />
      <input type="submit" name="submit" value="submit">
    </form>
    <br /><a href="logout.php">ログアウト</a><br /><br />
  </body>
</html>

<?php
$user = 'root';
$password = 'cysec.lab';

try {
  $pdo = new PDO(
    'mysql:host=localhost;
    dbname=stored_db;
    charset=utf8',
    $user,
    $password
  );

  $sql = 'SELECT * FROM guestbook';
  $stmt = $pdo->query($sql);
  while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    print ('Name: '.$row['name'].'<br />');
    print ('Comment: '.$row['comment'].'<br /><br />');
  }

} catch(PDOException $e) {
  print ('Error:'.$e->getMessage());
}

if(isset($_POST['submit'])) {

  $name    = $_SESSION['NAME'];
  $message = trim($_POST['message']);

  $message = stripslashes($message);
  #$message = mysql_real_escape_string($message);

  $sql = "INSERT INTO guestbook (name, comment) VALUES ('$name', '$message')";
  $stmt = $pdo->prepare($sql);
  $stmt->execute();

  $pdo = null;
  echo '<script type="text/javascript">window.location.href=location;</script>';
}
?>
