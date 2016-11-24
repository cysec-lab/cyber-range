<?php

  // 実行する前にデータベースを作成します
  // XAMPPとMAMPの人は、データベースをphpmyadminで作成したほうが楽かも
  // エラー出たらググるか質問してください

  // 参考までに、websecデータベースの作成 [端末での操作]
  // $ mysql -u root -p
  // パスワード入力
  // mysql> create database websec;
  // OK が出たら成功
  // mysql> exit;

  // webサーバとmysqlサーバを立ち上げて
  // mysqlサーバでwebsecデータベースを作成してから実行

  // 接続テスト
  // めんどくさいからrootのユーザ名とパスワード名を入れる
  $user = 'root';
  $passwd = 'cysec.lab';

  try{
    $pdo = new PDO(
      'mysql:host=localhost;
      dbname=websec;
      charset=utf8',
      $user,
      $passwd
    );
  }catch(PDOException $e){
    exit('fail to connect database<br>'.$e->getMessage());
  }

  echo('success to connect database');

?>
