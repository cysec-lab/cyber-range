<?php
  session_start();
?>
<html>
<body>
  <h1>ユーザ情報登録</h1>
  <form action="xss_confirm.php" method="get">
    名前:<input type="text" name="name"><br />
    パスワード:<input type="password" name="password"><br />
    <input type="submit" value="確認">
    <input type="reset" value="リセット">
  </form>
</body>
</html>
