<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['deviceToken'])
) {

    $pdo = connectDb();

    $sql = 'INSERT into tbl_iosDeviceToken (deviceId, deviceToken) VALUES(:deviceId, :deviceToken)';
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':deviceId'=>$_GET['deviceId'],
        ':deviceToken'=>$_GET['deviceToken']
    ]);
    
}

if (
    isset($_POST['deviceToken'])
) {

    $pdo = connectDb();

    $sql = 'INSERT into tbl_iosDeviceToken (deviceId, deviceToken) VALUES(:deviceId, :deviceToken)';
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([
        ':deviceId'=>$_POST['deviceId'],
        ':deviceToken'=>$_POST['deviceToken']
    ]);
    
}

$sql = 'SELECT * FROM tbl_iosDeviceToken';
header('Content-type: application/json');
echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));

?>

