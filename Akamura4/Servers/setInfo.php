<?php
require_once 'config.php';
require_once 'functions.php';

ob_start();
print_r($_POST);
  $all = $_POST;

  $buffer = ob_get_contents();
  ob_end_clean();

  $fp = fopen("print_setInfo","w");
  fputs($fp,$buffer);
  fclose($fp);

if (isset($_POST['userId'])) {

//  $deviceToken = $_POST['deviceToken'];
//  $deviceId = $_POST['uuid'];
//  $storedDeviceToken = $_POST['storedDeviceToken'];
//  $storedDeviceId= $_POST['storedUuid'];
  $userId = intval($_POST['userId']);
  $notification = intval($_POST['notification']);
  $build = intval($_POST['build']);
  $point = intval($_POST['point']);
  $modelName= $_POST['modelName'];
  $hostName= $_POST['hostName'];
  $systemVersion= $_POST['systemVersion'];


  $sql = "";

  if ($userId > 0) {

    // Device Tokenが更新（Device IDも更新されてても良い）
//    $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE flag = 0 AND deviceToken = '{$storedDeviceToken}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";
    // Device IDが更新（Device Tokenも更新されてても良い）
//    $sql .= "UPDATE tbl_users SET deviceId = '{$deviceId}' WHERE flag = 0 AND deviceId = '{$storedDeviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";

    // $sql .= "UPDATE tbl_users SET flag = 0 WHERE flag = 1 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";

  }

  // Device IDが登録されていなければ登録
//  $sql .= "INSERT INTO tbl_users (deviceId) SELECT * FROM (SELECT '{$deviceId}') AS TMP WHERE NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";
  // Device IDが登録されていて，User IDが登録されていなければ，User IDを登録
//  $sql .= "UPDATE tbl_users SET userId = id WHERE userId is NULL AND deviceId = '{$deviceId}';";
  // Device Tokenが登録されていなければ登録
//  $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE deviceId = '{$deviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";
  // Count：アクセス数をインクリメント
  $sql .= "UPDATE tbl_users SET count = count + 1 WHERE userId = '{$userId}';";
  // Build番号を登録
  if (!is_null($_POST['build'])) { $sql .= "UPDATE tbl_users SET build = '{$build}' WHERE userId = '{$userId}';"; }
  // Notificationを登録
  if (!is_null($_POST['notification'])) { $sql .= "UPDATE tbl_users SET notification = '{$notification}' WHERE userId = '{$userId}';"; }
  // Pointを登録
  if (!is_null($_POST['point'])) { $sql .= "UPDATE tbl_users SET point = '{$point}' WHERE userId = '{$userId}';"; }
  // Model Nameを登録
  if (!is_null($modelName)) { $sql .= "UPDATE tbl_users SET modelName = '{$modelName}' WHERE userId = '{$userId}';"; }
  // Host Nameを登録
  if (!is_null($hostName)) { $sql .= "UPDATE tbl_users SET hostName = '{$hostName}' WHERE userId = '{$userId}';"; }
  // System Versionを登録
  if (!is_null($systemVersion)) { $sql .= "UPDATE tbl_users SET systemVersion = '{$systemVersion}' WHERE userId = '{$userId}';"; }
  // if ($deviceId != $storedDeviceId) {
  //   $sql .= "UPDATE tbl_users SET flag = 1 WHERE deviceId = '{$storedUuid}';";
  // }
  //
  // if ($deviceToken != $storedDeviceToken) {
  //   $sql .= "UPDATE tbl_users SET flag = 1 WHERE deviceToken = '{$storedDeviceToken}';";
  // }

  $dbh = connectDb();
  $sth = $dbh->query($sql);
  $sth = null;
  $dbh = null;


//  $sql = "SELECT userId FROM tbl_users WHERE flag = 0 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";
//  header('Content-type: application/json');
//  echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));
}
?>
