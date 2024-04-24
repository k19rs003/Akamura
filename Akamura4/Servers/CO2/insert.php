<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['co2'])
    ) {
        
        $pdo = connectDb();
        
        $location = $_GET['location'];
        $co2 = $_GET['co2'];
        $temperature = $_GET['temperature'];
        $humidity = $_GET['humidity'];
        $pressure = $_GET['pressure'];
        $voc = $_GET['voc'];
        $deviceTokens = array();
        $whatAlerts = array();
        $alertValue = array();
        $alertData = array();
        $upDown = array('co2' => 'なり', 'temparature' => 'なり', 'humidity' => 'なり', 'pressure' => 'なり', 'voc' => 'なり' );
        
        $sql = "SELECT co2, temperature, humidity, pressure, voc FROM tbl_co2 WHERE location = '{$location}' ORDER BY id DESC LIMIT 1;";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $previousData = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt = null;
        
        $sql = "INSERT into tbl_co2 (
      co2,
      temperature,
      humidity,
      pressure,
      voc,
      build,
      systemVersion,
      co2Version,
      deviceId,
      ssid,
      location,
      iPhone,
      lowPower,
      autoCalibration,
      wifiEnd,
      co2Sensor,
      temperatureSensor
    ) VALUES (
      :co2,
      :temperature,
      :humidity,
      :pressure,
      :voc,
      :build,
      :systemVersion,
      :co2Version,
      :deviceId,
      :ssid,
      :location,
      :iPhone,
      :lowPower,
      :autoCalibration,
      :wifiEnd,
      :co2Sensor,
      :temperatureSensor
    );";
        
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
                                 ':co2'=>$_GET['co2'],
                                 ':temperature'=>$_GET['temperature'],
                                 ':humidity'=>$_GET['humidity'],
                                 ':pressure'=>$_GET['pressure'],
                                 ':voc'=>$_GET['voc'],
                                 ':build'=>$_GET['build'],
                                 ':systemVersion'=>$_GET['systemVersion'],
                                 ':co2Version'=>$_GET['co2Version'],
                                 ':deviceId'=>$_GET['deviceId'],
                                 ':ssid'=>$_GET['ssid'],
                                 ':location'=>$_GET['location'],
                                 ':iPhone'=>$_GET['iPhone'],
                                 ':lowPower'=>$_GET['lowPower'],
                                 ':autoCalibration'=>$_GET['autoCalibration'],
                                 ':wifiEnd'=>$_GET['wifiEnd'],
                                 ':co2Sensor'=>$_GET['co2Sensor'],
                                 ':temperatureSensor'=>$_GET['temperatureSensor']
                                 ]);
        
        $sql = "SELECT deviceToken, location, alert1, alert2, alert3, type, whatAlert FROM tbl_notification WHERE location = '{$location}' AND flag = 0;";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt = null;
        
        // 値が上がったか下がったか　nullはIntの0と一緒の判定
        if ( $previousData['co2'] > $co2 ) { $upDown['co2'] = '下がり';}
        if ( (!is_null($previousData['temperature'])) AND
            ($previousData['temperature'] > $temperature) ) { $upDown['temperature'] = '下がり';} // マイナスの可能性？
        if ( $previousData['humidity'] > $humidity ) { $upDown['humidity'] = '下がり';}
        if ( $previousData['pressure'] > $pressure ) { $upDown['pressure'] = '下がり';}
        if ( $previousData['voc'] > $voc ) { $upDown['voc'] = '下がり';}
        
        if ( $previousData['co2'] < $co2 ) { $upDown['co2'] = '上がり';}
        if ( (!is_null($previousData['temperature'])) AND ($previousData['temperature'] < $temperature) ) { $upDown['temperature'] = '上がり';}
        if ( (!is_null($previousData['humidity'])) AND ($previousData['humidity'] < $humidity) ) { $upDown['humidity'] = '上がり';}
        if ( (!is_null($previousData['pressure'])) AND ($previousData['pressure'] < $pressure) ) { $upDown['pressure'] = '上がり';}
        if ( (!is_null($previousData['voc'])) AND ($previousData['voc'] < $voc) ) { $upDown['voc'] = '上がり';}

        print_r($upDown);
        
        foreach ( $results as $result ) { // nullはIntの0判定になるので除外
            
            switch ($result['whatAlert']) {
                case "co2":
                    switch ($result['type']) {
                        case 0: //　全部
                            if ( (($previousData['co2'] < $result['alert1']) AND ($co2 >= $result['alert1']))
                                OR (($previousData['co2'] < $result['alert2']) AND ($co2 >= $result['alert2']))
                                OR (($previousData['co2'] < $result['alert3']) AND ($co2 >= $result['alert3']))
                                
                                OR (($previousData['co2'] >= $result['alert1']) AND ($co2 < $result['alert1']))
                                OR (($previousData['co2'] >= $result['alert2']) AND ($co2 < $result['alert2']))
                                OR (($previousData['co2'] >= $result['alert3']) AND ($co2 < $result['alert3']))     ) {
                                
                                array_push($deviceTokens, $result['deviceToken']);
                                array_push($whatAlerts, $result['whatAlert']);
                                array_push($alertValue, $co2);
                                print("<br>");
                                print("CO2Alert!");
                                
                            }
                            break;
                        case 1: // 上がったとき
                            if ( ($previousData['co2'] < $result['alert1'] AND $co2 >= $result['alert1'])
                                OR ($previousData['co2'] < $result['alert2'] AND $co2 >= $result['alert2'])
                                OR ($previousData['co2'] < $result['alert3'] AND $co2 >= $result['alert3'])     ) {
                                
                                array_push($deviceTokens, $result['deviceToken']);
                                array_push($whatAlerts, $result['whatAlert']);
                                array_push($alertValue, $co2);
                                print("<br>");
                                print("CO2Alert!");
                            }
                            break;
                        case 2: // 下がったとき
                            if ( ($previousData['co2'] >= $result['alert1'] AND $co2 < $result['alert1'])
                                OR ($previousData['co2'] >= $result['alert2'] AND $co2 < $result['alert2'])
                                OR ($previousData['co2'] >= $result['alert3'] AND $co2 < $result['alert3'])     ) {
                                
                                array_push($deviceTokens, $result['deviceToken']);
                                array_push($whatAlerts, $result['whatAlert']);
                                array_push($alertValue, $co2);
                                print("<br>");
                                print("co2Alert!");
                            }
                            break;
                        default:
                            break;
                    }
                    
                case "temperature":
                    if ( is_null($previousData['temperature']) ) { // 一個前のデータ空のとき
                        if (( !is_null($temperature) AND ($temperature <= $result['alert1']) OR ($temperature >= $result['alert2']))) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $temperature);
                            print("<br>");
                            print("temperatureAlert!");
                            
                        }
                    } else {
                        if ( !is_null($temperature) AND
                            ((($result['alert1'] != -1) AND ($previousData['temperature'] > $result['alert1']) AND ($temperature <= $result['alert1']))
                            OR (($result['alert2'] != -1) AND ($previousData['temperature'] < $result['alert2']) AND ($temperature >= $result['alert2']))) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $temperature);
                            print("<br>");
                            print("temperatureAlert!");
                            
                        }
                    }
                    break;
                
                case "humidity":
                    if ( is_null($previousData['humidity']) ) { // 一個前のデータ空のとき
                        if ( !is_null($humidity) AND (($humidity <= $result['alert1']) OR ($humidity >= $result['alert2'])) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $humidity);
                            print("<br>");
                            print("humidityAlert!");
                            
                        }
                    } else {
                        if ( !is_null($humidity) AND
                            ((($result['alert1'] != -1) AND ($previousData['humidity'] > $result['alert1']) AND ($humidity <= $result['alert1']))
                            OR (($result['alert2'] != -1) AND ($previousData['humidity'] < $result['alert2']) AND ($humidity >= $result['alert2']))) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $humidity);
                            print("<br>");
                            print("humidityAlert!");
                            
                        }
                    }
                    break;
                    
                case "pressure":
                    if ( is_null($previousData['pressure']) ) { // 一個前のデータ空のとき
                        if ( !is_null($pressure) AND (($pressure <= $result['alert1']) OR ($pressure >= $result['alert2'])) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $pressure);
                            print("<br>");
                            print("pressureAlert!");
                            
                        }
                    } else {
                        if ( !is_null($pressure) AND
                            ((($result['alert1'] != -1) AND ($previousData['pressure'] > $result['alert1']) AND ($pressure <= $result['alert1']))
                            OR (($result['alert2'] != -1) AND ($previousData['pressure'] < $result['alert2']) AND ($pressure >= $result['alert2']))) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $pressure);
                            print("<br>");
                            print("pressureAlert!");
                        }
                    }
            
                    break;
                    
                case "voc":
                    if ( is_null($previousData['voc']) ) { // 一個前のデータ空のとき
                        if ( !is_null($voc) AND (($voc <= $result['alert1']) OR ($voc >= $result['alert2'])) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $voc);
                            print("<br>");
                            print("vocAlert!");
                            
                        }
                    } else {
                        if ( !is_null($voc) AND
                            ((($result['alert1'] != -1) AND ($previousData['voc'] > $result['alert1']) AND ($voc <= $result['alert1']))
                            OR (($result['alert2'] != -1) AND ($previousData['voc'] < $result['alert1']) AND ($voc >= $result['alert1']))) ) {
                            
                            array_push($deviceTokens, $result['deviceToken']);
                            array_push($whatAlerts, $result['whatAlert']);
                            array_push($alertValue, $voc);
                            print("<br>");
                            print("vocAlert!");
                        }
                    }
                    
                    break;
                    
                default:
                    break;
            }
            
            
            print("<br>");
            print('deviceToken: ');
            print($result['deviceToken']);
            print('previousData: ');
            print_r($previousData);
            print(' Alert1: ');
            print($result['alert1']);
            print(' Alert2: ');
            print($result['alert2']);
            print(' Alert3: ');
            print($result['alert3']);
        }
        
        print_r("\n{$deviceTokens}\n");
        
        
        if (!empty($deviceTokens)) {
            $alertData = array($deviceTokens, $whatAlerts, $alertValue);
            
            //            exec("cd /var/www/html/co2; /bin/php ./push.php > /dev/null &");
            include("push.php");
            
        }
    }

if (
    isset($_GET['deviceId'])
    ) {
        $deviceId = $_GET['deviceId'];
        
        $sql = "
    SELECT
    *
    FROM tbl_co2 WHERE deviceId = '{$deviceId}'
    ORDER BY id DESC
    LIMIT 1
    ;
    ";
        header('Content-type: application/json');
        echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));
        
    }
?>
