<?php
ini_set('display_errors',1);

if (isset($_POST['submit'])) {
    $filename = $_POST['filename'];
    $file = "/public/" . $filename;

    if (file_exists($file) === true) {
	readfile($file);
    } else {
	print ("Dosen't exist file");
    }
}
?>

<html>
<body>
  <h1>Read File</h1>
  <p>Enter file name</p>
  <form action="" method="post">
    <input type="text" name="filename" size="30"><br />
    <input type="submit" name="submit" value="submit">
  </form>
</body>
</html>
