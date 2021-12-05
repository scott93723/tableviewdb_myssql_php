<?PHP
    header("Content-type: text/html; charset=utf-8");
    //製作儲存上傳檔案的路徑（包含檔案名稱） PS.basename取得檔名（不含實際的完整路徑）
    $uploadfile = 'images/' . basename($_FILES['userfile']['name']);
    //將檔案從暫存區複製到上傳路徑（使用原來檔案名稱存放在希望的路徑）
    if (move_uploaded_file($_FILES['userfile']['tmp_name'],$uploadfile))
    {
        echo "success";
    }
    else
    {
        echo "error";
    }
?>
