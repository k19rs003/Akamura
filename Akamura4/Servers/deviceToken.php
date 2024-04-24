<?php
require_once 'config.php';
require_once 'functions.php';

ob_start();
print_r($_POST);
  $all = $_POST;

  $buffer = ob_get_contents();
  ob_end_clean();

  $fp = fopen("print_r","w");
  fputs($fp,$buffer);
  fclose($fp);

if (isset($_POST['deviceToken'])) {

  $deviceToken = $_POST['deviceToken'];
  $deviceId = $_POST['uuid'];
  $storedDeviceToken = $_POST['storedDeviceToken'];
  $storedDeviceId= $_POST['storedUuid'];
  $userId = intval($_POST['userId']);
  $build = intval($_POST['build']);
  $modelName= $_POST['modelName'];
  $systemVersion= $_POST['systemVersion'];


  $sql = "";

  if ($userId > 0) {

    // Device Tokenが更新（Device IDも更新されてても良い）
    $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE flag = 0 AND deviceToken = '{$storedDeviceToken}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";
    // Device IDが更新（Device Tokenも更新されてても良い）
    $sql .= "UPDATE tbl_users SET deviceId = '{$deviceId}' WHERE flag = 0 AND deviceId = '{$storedDeviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";

    // $sql .= "UPDATE tbl_users SET flag = 0 WHERE flag = 1 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";

  } else {

  // Device IDが登録されていなければ登録
  $sql .= "INSERT INTO tbl_users (deviceId) SELECT * FROM (SELECT '{$deviceId}') AS TMP WHERE NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";
  // Device IDが登録されていて，User IDが登録されていなければ，User IDを登録
  $sql .= "UPDATE tbl_users SET userId = id WHERE userId is NULL AND deviceId = '{$deviceId}';";
  // Device Tokenが登録されていなければ登録
  $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE deviceId = '{$deviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";

  }
  // Count：アクセス数をインクリメント
  // $sql .= "UPDATE tbl_users SET count = count + 1 WHERE deviceId = '{$deviceId}';";
  // Build番号を登録
  if (!is_null( $build)) { $sql .= "UPDATE tbl_users SET build = '{$build}' WHERE deviceId = '{$deviceId}';"; }
  // Model Nameを登録
  if (!is_null( $modelName)) { $sql .= "UPDATE tbl_users SET modelName = '{$modelName}' WHERE deviceId = '{$deviceId}';"; }
  // System Versionを登録
  if (!is_null( $systemVersion)) { $sql .= "UPDATE tbl_users SET systemVersion = '{$systemVersion}' WHERE deviceId = '{$deviceId}';"; }

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


    if ($deviceToken == "NULL") {
        $sql = "SELECT userId FROM tbl_users WHERE flag = 0 AND deviceId = '{$deviceId}' AND deviceToken is null;";
    } else {
        $sql = "SELECT userId FROM tbl_users WHERE flag = 0 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";
    }
  header('Content-type: application/json');
  echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));
}

if (isset($_GET['deviceToken'])) {
    
  $deviceToken = $_GET['deviceToken'];
  $deviceId = $_GET['uuid'];
  $storedDeviceToken = $_GET['storedDeviceToken'];
  $storedDeviceId= $_GET['storedUuid'];
  $userId = intval($_GET['userId']);
  $build = intval($_GET['build']);
  $modelName= $_GET['modelName'];
  $systemVersion= $_GET['systemVersion'];


  $sql = "";

  if ($userId > 0) {

    // Device Tokenが更新（Device IDも更新されてても良い）
    $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE flag = 0 AND deviceToken = '{$storedDeviceToken}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";
    // Device IDが更新（Device Tokenも更新されてても良い）
    $sql .= "UPDATE tbl_users SET deviceId = '{$deviceId}' WHERE flag = 0 AND deviceId = '{$storedDeviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";

    // $sql .= "UPDATE tbl_users SET flag = 0 WHERE flag = 1 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";

  } else {

  // Device IDが登録されていなければ登録
  $sql .= "INSERT INTO tbl_users (deviceId) SELECT * FROM (SELECT '{$deviceId}') AS TMP WHERE NOT EXISTS (SELECT * FROM tbl_users WHERE deviceId = '{$deviceId}');";
  // Device IDが登録されていて，User IDが登録されていなければ，User IDを登録
  $sql .= "UPDATE tbl_users SET userId = id WHERE userId is NULL AND deviceId = '{$deviceId}';";
  // Device Tokenが登録されていなければ登録
  $sql .= "UPDATE tbl_users SET deviceToken = '{$deviceToken}' WHERE deviceId = '{$deviceId}' AND NOT EXISTS (SELECT * FROM tbl_users WHERE deviceToken = '{$deviceToken}');";

  }
  // Count：アクセス数をインクリメント
  // $sql .= "UPDATE tbl_users SET count = count + 1 WHERE deviceId = '{$deviceId}';";
  // Build番号を登録
  if (!is_null( $build)) { $sql .= "UPDATE tbl_users SET build = '{$build}' WHERE deviceId = '{$deviceId}';"; }
  // Model Nameを登録
  if (!is_null( $modelName)) { $sql .= "UPDATE tbl_users SET modelName = '{$modelName}' WHERE deviceId = '{$deviceId}';"; }
  // System Versionを登録
  if (!is_null( $systemVersion)) { $sql .= "UPDATE tbl_users SET systemVersion = '{$systemVersion}' WHERE deviceId = '{$deviceId}';"; }

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


    if ($deviceToken == "NULL") {
        $sql = "SELECT userId FROM tbl_users WHERE flag = 0 AND deviceId = '{$deviceId}' AND deviceToken is null;";
    } else {
        $sql = "SELECT userId FROM tbl_users WHERE flag = 0 AND deviceId = '{$deviceId}' AND deviceToken = '{$deviceToken}';";
    }
  header('Content-type: application/json');
  echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));
}
?>
