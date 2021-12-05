<?php
    //update student set name='testname',gender=0,phone='123455',address='這是地址',email='xyz@jj.kk',myclass='手機程式開發' where no='K668'
    //http://192.168.1.113/update_data.php?name=測試&gender=1&phone=096699999&address=住址&email=xyz@kkk&myclass=網頁程式設計&no=S105
    //指定網頁的中文格式
    header("Content-type: text/html; charset=utf-8");
    //連接資料庫
    $user = "perkin";      //資料庫IP
    $password = "mytest";    //資料庫帳號
    $host = "192.168.1.113";        //資料庫密碼
    $db = "mydatabase";        //資料庫名稱
    $conn=mysqli_connect($host, $user,$password) or die("資料庫連線錯誤！");
    //指定連線的資料庫
    mysqli_select_db($conn,$db);
    //指定資料庫使用的編碼
    mysqli_query($conn,"SET NAMES utf8");

    //============先檢查資料庫資料是否存在============
    $selectSQL = sprintf("select * from student where no='%s'",$_GET['no']);
    //執行select指令
    $result=mysqli_query($conn,$selectSQL) or die(mysqli_error());
    if ($row_array=mysqli_fetch_row($result))
    {
        //該筆資料存在
        $dataExist = 1;
    }
    else
    {
        //找不到該筆資料
        $dataExist = 0;
    }
    
    //準備update指令
    $updateSQL = sprintf("update student set name='%s',gender=%d,phone='%s',address='%s',email='%s',myclass='%s' where no='%s'",$_GET['name'],$_GET['gender'],$_GET['phone'],$_GET['address'],$_GET['email'],$_GET['myclass'],$_GET['no']);
    //執行update指令
    $result=mysqli_query($conn,$updateSQL) or die(mysqli_error());
    //關閉資料庫連結
    mysqli_close($conn);
    
    //回傳執行狀態
    if ($dataExist == 1 && $result == 1)
    {
        //回傳執行成功
        echo "1";
    }
    else
    {
        //回傳執行失敗
        echo "0";
    }
?>