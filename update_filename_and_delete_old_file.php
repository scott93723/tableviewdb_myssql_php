<?PHP
//此服務僅處理檔名更新，以及刪除舊檔，不提供檔案上傳（檔案上傳服務需另外呼叫 photo_upload.php）
    //update student set picture='images/s101-12334r.jpg' where no='s101'
//http://studio-pj.com/class_exercise/update_filename_and_delete_old_file.php?fileid=12334r&no=s101
    
    //指定網頁的中文格式
    header("Content-type: text/html; charset=utf-8");
    //連接資料庫
    $user = "ClassExercise";      //資料庫IP
    $password = "Student#100";    //資料庫帳號
    $host = "sg2nlmysql57plsk.secureserver.net";        //資料庫密碼
    $db = "ClassExercise";        //資料庫名稱
    $conn=mysqli_connect($host, $user,$password) or die("資料庫連線錯誤！");
    //指定連線的資料庫
    mysqli_select_db($conn,$db);
    //指定資料庫使用的編碼
    mysqli_query($conn,"SET NAMES utf8");
    //取得學號（addslashes函式會在字串中單引號、雙引號、反斜線的前面加上反斜線，以防止SQL指令入侵）
    $no = addslashes($_GET['no']);
    //============先檢查資料庫資料是否存在============
    $selectSQL = sprintf("select picture from student where no='%s'",$no);
    //執行select指令
    $result=mysqli_query($conn,$selectSQL) or die(mysqli_error());
    if ($row_array=mysqli_fetch_row($result))
    {
        //該筆資料存在
        $dataExist = 1;
        //刪除舊檔（注意：picture欄位已包含相對路徑images/）
        @unlink($row_array[0]);
    }
    else
    {
        //找不到該筆資料
        $dataExist = 0;
    }
    //組合新檔名
    $newFileName = 'images/'.$no.'-'.$_GET['fileid'].'.jpg';
    //準備update指令(僅更新檔名！新檔名為：images/學號-fileid.jpg)
    $updateSQL = sprintf("update student set picture='%s' where no='%s'",$newFileName,$no);
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
