<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['deviceToken'])
    ) {

        $pdo = connectDb();

        $deviceToken = $_GET['deviceToken'];
        $co2Notifications = (array) ($_GET['co2Notifications']);
        
//        print("co2Notifications: ");
//        print_r($co2Notifications);
        // 最初にフラグを全部１(無効)にする
        $sql = "UPDATE tbl_notification SET flag = 1 WHERE deviceToken = '{$deviceToken}';";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $stmt = null;

        // ここで選択されたものだけをフラグ0(有効にする)
        foreach ($co2Notifications as $co2Notification) {
            
            $co2Notification = explode("/", $co2Notification);
//            print_r($co2Notification);
            foreach ($co2Notification as $co2Notification) {
                
                $co2Notification = explode(",", $co2Notification);
//                print("co2Notification: ");
//                print_r($co2Notification);
                
                $location = $co2Notification[0];
                $alert1 = $co2Notification[1];
                $alert2 = $co2Notification[2];
                $alert3 = $co2Notification[3];
                $type = $co2Notification[4];
                $whatAlert = $co2Notification[5];

                $sql = "SELECT * FROM tbl_notification WHERE deviceToken = '{$deviceToken}' AND location = '{$location}' AND whatAlert = '{$whatAlert}' ORDER BY id DESC LIMIT 1;";
                $stmt = $pdo->prepare($sql);
                $stmt->execute();
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt = null;

//                if ($flag == 0){
                    if (!empty($result)) {
                        $sql = "UPDATE tbl_notification SET alert1 = $alert1, alert2 = {$alert2}, alert3 = $alert3, type = $type, whatAlert = '{$whatAlert}', flag = 0 WHERE id = {$result['id']};";
                        $stmt = $pdo->prepare($sql);
                        $stmt->execute();
                        //                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                        $stmt = null;
                    } else {
                        $sql = "INSERT INTO tbl_notification (deviceToken, location, alert1, alert2, alert3, type, whatAlert, flag)
                                VALUES ('{$deviceToken}', '{$location}', $alert1, $alert2, $alert3, $type, '{$whatAlert}', 0);";
                        $stmt = $pdo->prepare($sql);
                        $stmt->execute();
                        //                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                        $stmt = null;

                    }
//                }
            }
        }
//        $sql = "SELECT * FROM tbl_notification WHERE deviceToken = '{$deviceToken}' AND whatAlert = 'co2' AND flag = 0";
        $sql = "SELECT * FROM tbl_notification WHERE deviceToken = '{$deviceToken}' AND flag = 0";
        header('Content-type: application/json');
        echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));
    }
?>
