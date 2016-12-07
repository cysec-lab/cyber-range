<?php
ini_set('display_errors',1);

if (isset($_POST['submit'])) {
    $filename = $_POST['filename'];
    $file = "/public/" . $filename;

    if (file_exists($file) === true) {
	readfile($file);
    } else {
	print ("ファイルは存在しません");
    }
}
?>

<html>
<body>
  <h1>書類閲覧サイト</h1>
  <p>ファイル名を入力してください(拡張子込みで)</p>
  <form action="" method="post">
    <input type="text" name="filename" size="30"><br />
    <input type="submit" name="submit" value="submit">
  </form>
</body>
</html>
