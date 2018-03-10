<?php
  session_start();
  $name = $_GET['name'];
  $password = $_GET['password'];
?>
<html>
<body>
  <h1>ユーザ情報登録確認</h1>
  <form action="xss_regist.php" method="post">
    名前:<?php echo $name; ?><br />
    パスワード:<?php echo $password; ?><br />
    <input type="hidden" name="name" value="<?php echo $name; ?>">
    <input type="hidden" name="password" value="<?php echo $password; ?>">
    <input type="submit" value="登録">
    <input type="button" value="戻る" onclick="javascript:histry.back();">
  </form>
</body>
</html>
