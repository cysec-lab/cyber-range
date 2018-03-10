<?php
session_start();

// ログイン状態のチェック
if (!isset($_SESSION["NAME"])) {
  header("Location: logout.php");
  exit;
}

?>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>メイン画面</title>
  </head>
  <body>
  <h1>メイン機能</h1>
  <!-- ユーザIDにHTMLタグが含まれても良いようにエスケープする -->
  <p>ようこそ<?=htmlspecialchars($_SESSION["NAME"], ENT_QUOTES); ?>さん</p>
  <ul>
  <li><a href="logout.php">ログアウト</a></li>
  </ul>
  </body>
</html>
