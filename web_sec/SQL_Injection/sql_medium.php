<?php
$user = 'root';
$password = 'cysec.lab';
try {
    $pdo = new PDO(
        'mysql:host=localhost;
        dbname=sql_db;
        charset=utf8',
        $user,
        $password
    );
    if (isset($_POST['submit'])) {

    	$id = $_POST['id'];

    	$sql = "SELECT name,password FROM users WHERE id = $id";
    	$stmt = $pdo->query($sql);
   	while($result = $stmt->fetch(PDO::FETCH_ASSOC)) {
    	    print ('Name: '.$result['name'].'<br />');
    	    print ('Password: '.$result['password'].'<br /><br />');
    	}
    	$pdo = null;
    }
} catch(PDOException $e) {
    print ('Error:'.$e->getMessage());
}

?>

<html>
<body>
  <h1>Vulnerability: SQL Injection</h1>
  <form action="" method="post">
    <p>User ID:</p>
    <input type="text" name="id"><br />
    <input type="submit" name="submit" value="submit">
  </form>
</body>
</html>

