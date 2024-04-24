<?php

require_once 'config.php';
require_once 'functions.php';

$keyfile = 'AuthKey_7GWV7ZC45H.p8';               # <- Your AuthKey file
$keyid = '7GWV7ZC45H';                            # <- Your Key ID
$teamid = 'QU5MY7WAK3';                           # <- Your Team ID (see Developer Portal)
$bundleid = 'jp.ac.kyusan-u.ISICAkamura';       # <- Your Bundle ID // ここ
$url = 'https://api.push.apple.com'; # <- development url, or use http://api.push.apple.com for production environment
$token = '567d08d4bd53d9f4de3d75b3eb88d2fc04f68464d79e1aee4f5f6a7d83315a29';          # <- Device Token // ここ
// $locaation, $co2, $$deviceTokens はinsert.phpから

$title = 'CO2';
$subTitle = '';
$body = "{$location}のCO2値が{$co2}に{$upDown['co2']}ました";

$message = '{"aps":{
  "alert": {
        "title": "'.$title.'",
        "subtitle": "'.$subTitle.'",
        "body": "'.$body.'"
      },
  "badge": 1,
  "sound":"default"}}';

$key = openssl_pkey_get_private('file://'.$keyfile);

$header = ['alg'=>'ES256','kid'=>$keyid];
$claims = ['iss'=>$teamid,'iat'=>time()];

$header_encoded = base64($header);
$claims_encoded = base64($claims);

$signature = '';
openssl_sign($header_encoded . '.' . $claims_encoded, $signature, $key, 'sha256');
$jwt = $header_encoded . '.' . $claims_encoded . '.' . base64_encode($signature);

// only needed for PHP prior to 5.5.24
if (!defined('CURL_HTTP_VERSION_2_0')) {
  define('CURL_HTTP_VERSION_2_0', 3);
}

$sql = 'SELECT co2 FROM tbl_co2 ORDER BY id DESC LIMIT 1';
$stmt = connectDb()->prepare($sql);
$stmt->execute([]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$latestReviewId = $result['id'];
$stmt = null;

print("\n");
print("alertData: ");
print_r($alertData);
print("\n");

for ($i = 0; $i < count($alertData[0]); $i++) {
    
    $title = whatAlert($alertData[1][$i]);
    $subTitle = '';
    
    switch ($alertData[1][$i]) {
        case "co2": $body = "{$location}の{$title}が{$alertData[2][$i]}ppmに{$upDown['co2']}ました"; break;
        case "temperature": $body = "{$location}の{$title}が{$alertData[2][$i]}℃に{$upDown['temperature']}ました"; break;
        case "humidity": $body = "{$location}の{$title}が{$alertData[2][$i]}％に{$upDown['humidity']}ました"; break;
        case "pressure": $body = "{$location}の{$title}が{$alertData[2][$i]}hPaに{$upDown['pressure']}ました"; break;
        case "voc": $body = "{$location}の{$title}が{$alertData[2][$i]}ppmCに{$upDown['voc']}ました"; break;
        default: $body = "{$location}の{$title}が{$alertData[2][$i]}になりました"; break;
    }
    
    $token = $alertData[0][$i];
    print("\n{$token}\n");

    $badge = 0;
  //  print("\n{$$latestReviewId}-{$content['reviewId']}={$badge}\n");

    $message = '{"aps":{
      "alert": {
            "title": "'.$title.'",
            "subtitle": "'.$subTitle.'",
            "body": "'.$body.'"
          },
      "badge": '.$badge.',
      "sound":"default"}}';

    $http2ch = curl_init();
    curl_setopt_array($http2ch, array(
      CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
      CURLOPT_URL => "$url/3/device/$token",
      CURLOPT_PORT => 443,
      CURLOPT_HTTPHEADER => array(
        "apns-topic: {$bundleid}",
        "content-available: 1",
        "apns-push-type: alert",
        "authorization: bearer $jwt"
      ),
      CURLOPT_POST => TRUE,
      CURLOPT_POSTFIELDS => $message,
      CURLOPT_RETURNTRANSFER => TRUE,
      CURLOPT_TIMEOUT => 30,
      CURLOPT_HEADER => 1
    ));

    $result = curl_exec($http2ch);
    if ($result === FALSE) {
      throw new Exception("Curl failed: ".curl_error($http2ch));
    }

  $status = curl_getinfo($http2ch, CURLINFO_HTTP_CODE);
  //echo $status;
    if ($status == 410) {
      $sql = "UPDATE tbl_users SET flag = 1 WHERE deviceToken = '".$token."'";
      connectDb()->query($sql);
    }
    
}

function whatAlert($whatAlert) {
    switch ($whatAlert) {
            case "co2": return "CO2";
            case "temperature": return "気温";
            case "humidity": return "湿度";
            case "pressure": return "気圧";
            case "voc": return "VOC";
            default: return "{$whatAlert}";
    }
}

function base64($data) {
  return rtrim(strtr(base64_encode(json_encode($data)), '+/', '-_'), '=');
}

?>
