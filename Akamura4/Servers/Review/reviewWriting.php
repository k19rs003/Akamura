<?php
ini_set("display_errors", 1);
error_reporting(E_ALL);
require_once 'config.php';
require_once 'functions.php';

if (
    isset($_GET['title'])
    ) {
        
        $pdo = connectDb();
        
        $sql = 'INSERT into tbl_review (userId, build, modelName, systemVersion, title, comment, age, satisfied) VALUES(:userId, :build, :modelName, :systemVersion, :title, :comment, :age, :satisfied)';
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
                                 ':userId'=>$_GET['userId'],
                                 ':build'=>$_GET['build'],
                                 ':modelName'=>$_GET['modelName'],
                                 ':systemVersion'=>$_GET['systemVersion'],
                                 ':title'=>$_GET['title'],
                                 ':comment'=>$_GET['comment'],
                                 ':age'=>$_GET['age'],
                                 ':satisfied'=>$_GET['satisfied']
                                 ]);
        
        // レビューを投稿したらpush.phpを実行
        exec("cd /var/www/push/akamura4; /bin/php ./push.php > /dev/null &");
    }

if (
    isset($_POST['title'])
    ) {
        
        $pdo = connectDb();
        
        $sql = 'INSERT into tbl_review (userId, build, modelName, systemVersion, title, comment, age, satisfied) VALUES(:userId, :build, :modelName, :systemVersion, :title, :comment, :age, :satisfied)';
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
                                 ':userId'=>$_POST['userId'],
                                 ':build'=>$_POST['build'],
                                 ':modelName'=>$_POST['modelName'],
                                 ':systemVersion'=>$_POST['systemVersion'],
                                 ':title'=>$_POST['title'],
                                 ':comment'=>$_POST['comment'],
                                 ':age'=>$_POST['age'],
                                 ':satisfied'=>$_POST['satisfied']
                                 ]);
        
        // レビューを投稿したらpush.phpを実行
        exec("cd /var/www/push/akamura4; /bin/php ./push.php > /dev/null &");
        
    }

if ( isset($_POST['deviceId']) ) {
    
    // レビュー画面を開いたときにreviewIdを更新
    
    $sql = 'select count(*) from tbl_review where flag = 0';
    $stmt = connectDb()->prepare($sql);
    $stmt->execute([]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    //  $sql = 'UPDATE tbl_users SET newsId = :newsId WHERE flag = 0 AND deviceId = :deviceId';
    $sql = 'UPDATE tbl_users SET reviewId = :reviewId, count = count + 1 WHERE flag = 0 AND deviceId = :deviceId';
    $stmt = connectDb()->prepare($sql);
    $result = $stmt->execute([
                             ':deviceId'=>$_POST['deviceId'],
                             ':reviewId'=>$result['count(*)']
                             ]);
    
}

$sql = 'SELECT id, userId, title, comment, age, satisfied, modified, posted, flag FROM tbl_review WHERE flag = 0 ORDER BY id DESC';
header('Content-type: application/json');
echo json_encode(connectDb()->query($sql)->fetchAll(PDO::FETCH_ASSOC));

?>
