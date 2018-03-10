<?php
session_start();

if (isset($_SESSION["NAME"])) {
  $errorMessage = "ログアウトしました。";
}
else {
  $errorMessage = "セッションがタイムアウトしました。";
}
// セッション変数のクリア
$_SESSION = array();
// クッキーの破棄は不要
//if (ini_get("session.use_cookies")) {
//    $params = session_get_cookie_params();
//    setcookie(session_name(), '', time() - 42000,
//        $params["path"], $params["domain"],
//        $params["secure"], $params["httponly"]
//    );
//}
// セッションクリア
@session_destroy();
?>

<!doctype html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>ログアウト画面</title>
  </head>
  <body>
  <h1>ログアウト機能</h1>
  <div><?php echo $errorMessage; ?></div>
  <ul>
  <li><a href="login.php">ログイン画面に戻る</a></li>
  </ul>
  </body>
</html>
