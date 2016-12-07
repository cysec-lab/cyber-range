<?php
ini_set('display_errors', 1);
// セッション開始
session_start();

$db_user = 'root';
$db_password = 'cysec.lab';

// エラーメッセージの初期化
$errorMessage = "";

// ログインボタンが押された場合
if (isset($_POST["login"])) {
  // １．ユーザIDの入力チェック
  if (empty($_POST["userid"])) {
    $errorMessage = "ユーザIDが未入力です。";
  } else if (empty($_POST["password"])) {
    $errorMessage = "パスワードが未入力です。";
  }

  // ２．ユーザIDとパスワードが入力されていたら認証する
  if (!empty($_POST["userid"]) && !empty($_POST["password"])) {
    $userid   = trim($_POST["userid"]);
    $password = trim($_POST["password"]);
    // mysqlへの接続
    try {
      $pdo = new PDO(
        'mysql:host=localhost;
        dbname=login_db;
        charset=utf8',
        $db_user,
        $db_password
      );

      $sql = "SELECT * FROM login_users WHERE userid = '$userid'";
      $stmt = $pdo->query($sql);
      while($result = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $name = $result['name'];
        $db_hashed_pwd = $result['password'];
      }

      $salt = $userid . $password
      $order = "SHA1('$salt')";
      $sql = "SELECT $order";
      $stmt = $pdo->query($sql);
      while($result = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $hashed_pwd = $result[$order];
      }
      // データベースの切断
      $pdo = null;

    } catch(PDOException $e) {
      print ('Error:'.$e->getMessage());
    }


    // ３．画面から入力されたパスワードのハッシュとデータベースから取得したパスワードのハッシュを比較します。
    if ($hashed_pwd == $db_hashed_pwd) {
      // ４．認証成功なら、セッションIDを新規に発行する
      session_regenerate_id(true);
      $_SESSION["NAME"] = $name
      header("Location: main.php");
      exit;
    }
    else {
      // 認証失敗
      $errorMessage = "ユーザIDあるいはパスワードに誤りがあります。";
    }
  } else {
    // 未入力なら何もしない
  }
}

?>
<!doctype html>
<html>
  <head>
  <meta charset="UTF-8">
  <title>ログインフォーム</title>
  </head>
  <body>
  <h1>ログイン機能</h1>
  <!-- $_SERVER['PHP_SELF']はXSSの危険性があるので、actionは空にしておく -->
  <!--<form id="loginForm" name="loginForm" action="<?//php print($_SERVER['PHP_SELF']) ?>" method="POST">-->
  <form id="loginForm" name="loginForm" action="" method="POST">
  <fieldset>
    <legend>ログインフォーム</legend>
    <div><?php echo $errorMessage ?></div>
    <label for="userid">ユーザID</label><input type="text" id="userid" name="userid" value="">
    <br />
    <label for="password">パスワード</label><input type="password" id="password" name="password" value="">
    <br />
    <input type="submit" id="login" name="login" value="ログイン">
  </fieldset>
  </form>
  </body>
</html>
