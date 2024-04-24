<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['location'])
) {
   
    $limit = '';
 
    if (
        isset($_GET['limit'])
    ) {
        $limit = 'LIMIT ' . $_GET['limit'];
//        echo $limit;
    }
 
    $location = $_GET['location'];
    
    $sql = "
    SELECT
    *
    FROM tbl_co2 
    WHERE location = '{$location}'
    ORDER BY id DESC
    ${limit}
    ; 
    ";

} else {

   $sql = "SELECT * FROM tbl_co2 as t1 INNER JOIN tbl_serial ON t1.deviceId = tbl_serial.deviceId WHERE t1.modified > CURRENT_TIMESTAMP + INTERVAL -10 MINUTE AND t1.id = ( SELECT MAX(id) FROM tbl_co2 WHERE location=t1.location ) ORDER BY location;";

}
 //   echo $sql;
    header('Content-type: application/json');
    echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));

?>

