<?php

require_once 'config.php';
require_once 'functions.php';
$sql = 'SELECT deviceToken, reviewId FROM tbl_users WHERE flag = 0 ORDER BY count DESC';
$contents = connectDb()->query($sql);
//foreach ($deviceTokens as $token) { print($token['deviceToken']); }

$keyfile = 'AuthKey_7GWV7ZC45H.p8';               # <- Your AuthKey file
$keyid = '7GWV7ZC45H';                            # <- Your Key ID
$teamid = 'QU5MY7WAK3';                           # <- Your Team ID (see Developer Portal)
$bundleid = 'jp.ac.kyusan-u.ISICAkamura';       # <- Your Bundle ID
$url = 'https://api.push.apple.com'; # <- development url, or use http://api.push.apple.com for production environment
$token = 'fe5f1028a877927ee36f0e4b19621f6c1adc68bbf543eff8a551d05a9934a021';          # <- Device Token

$title = 'お知らせ';
$subTitle = '';
$body = '新しいレビューが投稿されました．';

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

$sql = 'select count(*) from tbl_review where flag = 0';
$stmt = connectDb()->prepare($sql);
$stmt->execute([]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$latestReviewId = $result['count(*)'];
$stmt = null;

foreach ($contents as $content) {

  $token = $content['deviceToken'];
  print("\n{$token}\n");

  //$badge = 1;

  //$sql = 'SELECT newsId FROM tbl_users WHERE flag = 0 AND deviceToken = :deviceToken';
  //$stmt = connectDb()->prepare($sql);
  //$stmt->execute([ ':deviceToken' => $token ]);
  //$result = $stmt->fetch(PDO::FETCH_ASSOC);

  $badge = $latestReviewId - $content['reviewId'];
  //$stmt = null;

  //usleep(100000);

  //if ($userNewsId != 0) {
  //  $badge = $latestNewsId - $userNewsId;
  print("\n{$$latestReviewId}-{$content['reviewId']}={$badge}\n");
  //}

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

function base64($data) {
  return rtrim(strtr(base64_encode(json_encode($data)), '+/', '-_'), '=');
}

?>
