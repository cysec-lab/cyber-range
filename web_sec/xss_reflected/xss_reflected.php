<?php



############################
# 以下の文を変更してください
if(!array_key_exists ("name", $_GET) || $_GET['name'] == NULL || $_GET['name'] == ''){
  $isempty = true;
} else {
  echo '<pre>';
  echo 'Hello ' . $_GET['name'];
  echo '</pre>';
}
############################



?>
<html>
<body>
  <h1>XSS Reflected</h1>
  <p>Please Input your name</p>
  <form action="" method="get">
    <input type="text" name="name"><br />
    <input type="submit" value="実行">
  </form>
</body>
</html>
