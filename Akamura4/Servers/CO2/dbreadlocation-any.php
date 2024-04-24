<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['location'])
) {

    $period = 3;
    if ( isset($_GET['period']) ) { $period = $_GET['period']; }
    $period *= -1;
   
    $location = $_GET['location'];
    
    $sql = "
    SELECT
    *
    FROM tbl_co2 
    WHERE location = '{$location}'
    AND modified > CURRENT_TIMESTAMP + INTERVAL '{$period}' HOUR
    ORDER BY id
    ; 
    ";

} else {

    $sql = "
    SELECT 
    * 
    FROM tbl_co2 
    WHERE modified > CURRENT_TIMESTAMP + INTERVAL -10 MINUTE
    ORDER BY location
    ;
    ";

}
 //   echo $sql;
    header('Content-type: application/json');
    echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));

?>

