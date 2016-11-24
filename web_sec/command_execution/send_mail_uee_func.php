<?php

mb_language("Japanese");
mb_internal_encoding("UTF-8");

$to      = 'crowizard@gmail.com';
$subject = 'test mail';
$message = 'test';
$headers = 'From: from@hoge.co.jp' . "\r\n";

mb_send_mail($to, $subject, $message, $headers);


