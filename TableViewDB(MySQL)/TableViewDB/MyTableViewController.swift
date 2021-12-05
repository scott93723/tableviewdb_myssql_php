import UIKit
//深色模式與淺色模式的顏色設定教學：https://www.appcoda.com.tw/dark-mode-ios13/
//定義單筆學生資料的結構（結構引入Codable協定，為了對應Json的Key值）
struct Student:Codable
{
    var no = ""
    var name = ""
    var gender = "0"    //注意：因為JSon資料轉出的性別為文字，對應型別為文字（但資料庫端為tinyint(1)）
    var picture = ""    //圖片僅記錄相對路徑
    var phone = ""
    var address = ""
    var email = ""
    var myclass = ""
}

class MyTableViewController: UITableViewController,XMLParserDelegate
{
    //紀錄單一資料行
    var structRow = Student()
    //宣告學生陣列，存放從資料庫查詢到的資料（此陣列即『離線資料集』）
    var arrTable = [Student]()
    //---------------------MySQL增加-----------------------
    //記錄主要提供web service的網址
    let webDomain = "http://192.168.1.113/"
//    let webDomain = "http://studio-pj.com/class_exercise/"
    //紀錄目前處理中的網路服務
    var strURL = ""     //ex.select_data.php
    //紀錄目前處理中的網路物件
    var url:URL!
    //取得預設的網路串流物件
    var session = URLSession.shared
    //宣告網路資料傳輸任務（可同時適用於上傳和下載）
    var dataTask:URLSessionDataTask!
    //紀錄目前正在處理的XML標籤名稱
    var tagName = ""
    //紀錄目前正在處理的XML標籤內容
    var tagContent = ""
    //----------------------------------------------------
    
    //MARK: - 自定函式
    //從網路服務讀取XML資料
    func getDataFromXML()
    {
        //指定提供XML網路服務的網址
        strURL = "select_data.php"
        //將web service的網址形成URL實體
        url = URL(string: webDomain + strURL)
        //由網路串流物件來"準備"資料傳輸任務
        dataTask = session.dataTask(with: url, completionHandler: {
            xmlData, response, error
            in
            //當web service存取成功時
            if error == nil
            {
//                print("XML資料：\(String(data: xmlData!, encoding: .utf8)!)")
                //先清空離線資料集
                self.arrTable.removeAll()
                //以XML資料來產生XML解析器
                let xmlParser = XMLParser(data: xmlData!)
                //指定將XML解析過程的代理事件實作在此類別
                xmlParser.delegate = self
                //開始解析XML文件（此時會觸發XMLParserDelegate相關的代理事件）
                xmlParser.parse()
            }
            else
            {
                print("沒有拿到XML資料！！！")
            }
        })
        //啟動資料傳輸任務
        dataTask.resume()
    }
    
    //從網路服務讀取JSon資料
    func getDataFromJson()
    {
        //指定提供XML網路服務的網址
        strURL = "select_to_json.php"
        //將web service的網址形成URL實體
        url = URL(string: webDomain + strURL)
        //由網路串流物件來"準備"資料傳輸任務
        dataTask = session.dataTask(with: url, completionHandler: {
            jsonData, response, error
            in
            //當web service存取成功時
            if error == nil
            {
                //先清空離線資料集
                self.arrTable.removeAll()
                //初始化JSon資料的解碼器
                let decoder = JSONDecoder()
                //讓JSon解碼器開始解碼JSon資料到Student結構的陣列中
                if let jdata = jsonData,let studentResults = try? decoder.decode([Student].self, from: jdata)
                {
//                    print("解碼後的JSon資料\(studentResults)！")
                    //離線資料集取得解碼過後的資料
                    self.arrTable = studentResults
                    //轉回主執行緒，重整表格資料
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            else
            {
                print("沒有拿到JSon資料！！！")
            }
        })
        
        //執行資料傳輸任務
        dataTask.resume()
        
    }
    
    //MARK: - Target Action
    //導覽列的編輯按鈕
    @objc func buttonEditAction(_ sender:UIBarButtonItem)
    {
//        print("編輯按鈕被按下！")
        if self.tableView.isEditing //如果表格在編輯狀態
        {
            //讓表格取消編輯狀態
            self.tableView.isEditing = false
            //更改按鈕文字
            self.navigationItem.leftBarButtonItem?.title = "編輯"
        }
        else    //如果表格不在編輯狀態
        {
            //讓表格進入編輯狀態
            self.tableView.isEditing = true
            //更改按鈕文字
            self.navigationItem.leftBarButtonItem?.title = "取消"
        }
    }
    
    //導覽列的新增按鈕
    @objc func buttonAddAction(_ sender:UIBarButtonItem)
    {
        if let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController
        {
            addVC.myTableVC = self
            
            self.show(addVC, sender: nil)
        }
    }
    
    //由下拉更新元件呼叫的觸發事件
    @objc func handleRefresh()
    {
        //Step1.重新讀取實際的資料庫資料，並且填入離線資料集（arrTable）
        getDataFromJson()
        
        //Step2.執行表格資料更新（重新執行tableview datasource三個事件）
        self.tableView.reloadData()
        
        //Step3.停止下拉的動畫特效
        self.tableView.refreshControl?.endRefreshing()
        
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //從XML資料取得離線資料集
//        getDataFromXML()
        //從JSon資料取得離線資料集
        getDataFromJson()
        
        //在導覽列的左右側增加按鈕
        let strEdit = NSLocalizedString("Edit", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "")
        let strAddNew = NSLocalizedString("AddNew", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: strEdit, style: .plain, target: self, action: #selector(buttonEditAction(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: strAddNew, style: .plain, target: self, action: #selector(buttonAddAction(_:)))
        
        //設定導覽列的背景色<方法一>或<方法二>
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "title"), for: .default)       //PS.此語法在iOS15失效！
        //<方法一>設定背景圖（需配合storyboard介面navigationbar屬性scrollEdgeAppearance勾選）
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundImage = UIImage(named: "title")
        //<方法二>設定背景顏色
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .systemCyan
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        //準備下拉更新元件
        self.tableView.refreshControl = UIRefreshControl()
        //當下拉更新元件出現時（觸發valueChanged事件），綁定執行事件
        self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        //提供下拉更新元件的提示文字
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
    }
    
    // MARK: - Table view data source
    //表格有幾段
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        //表格只有一段
        return 1
    }
    //每一段表格有幾列
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        print("詢問第\(section)段表格有幾列")
//        if section == 0
//        {
//            return 3
//        }
//        else if section == 1
//        {
//            return 1
//        }
//        return 0
        //以陣列個數作為表格的列數
        return arrTable.count
    }
    
    //提供每一段每一列的儲存格樣式
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("詢問第\(indexPath.section)段,第\(indexPath.row)列的儲存格")
        //注意：使用自訂儲存格，必須完成自訂儲存格類別的轉型
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
        //<方法一>取大頭照的四邊圓角為圖片的一半寬度，即形成圓形圖片 PS.<方法二>在MyCell類別
//        cell.imgPicture.layer.cornerRadius = cell.imgPicture.bounds.width / 2
        
        print("網址：\(webDomain + arrTable[indexPath.row].picture)")
        //準備取得大頭照的URL物件
        url = URL(string: webDomain + arrTable[indexPath.row].picture)
        //準備大頭照的資料傳輸任務
        if url != nil
        {
            dataTask = session.dataTask(with: url, completionHandler: {
                imgData, response, error
                in
                if error == nil
                {
                    //轉回主要執行緒顯示大頭照
                    DispatchQueue.main.async {
                        if let picData = imgData
                        {
                            cell.imgPicture.image = UIImage(data: picData)
                        }
                    }
                }
                else
                {
                    print("無法取得大頭照：\(error!.localizedDescription)")
                }
            })
            //執行取得大頭照的傳輸任務
            dataTask.resume()
        }
        
        cell.lblNo.text = arrTable[indexPath.row].no
        cell.lblName.text = arrTable[indexPath.row].name
        if arrTable[indexPath.row].gender == "0"
        {
            cell.lblGender.text = "女"
        }
        else
        {
            cell.lblGender.text = "男"
        }
        return cell
    }
    
    
    
    //MARK: - Table View Delegate
    //回傳儲存格高度
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 120
//    }
    
    
    //<方法一>哪一個儲存格被點選
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("『\(arrTable[indexPath.row].name)』被點選")
    }

    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    //================================儲存格刪除相關作業（7-5舊版）=============================================
    //提交編輯狀態（通常只用於刪除，若需更換按鈕文字，需配合下一個事件：titleForDeleteConfirmationButtonForRowAt）
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
//        if editingStyle == .delete
//        {
            //Step1.先刪除資料庫資料
            //--To Do--
            //Step2.刪除陣列資料
            arrTable.remove(at: indexPath.row)
//            print("刪除後的陣列：\(arrTable)")
            //Step3.刪除儲存格
            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        else if editingStyle == .insert
//        {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }

    //更換刪除按鈕的文字
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "不要了"
    }
    //==================================================================================================
    
    //================================儲存格刪除相關作業（7-9新版）==========================================
    //以下事件會取代7-5舊版的刪除事件
    //儲存格向左滑動事件
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //準備『更多』按鈕
        let goAction = UIContextualAction(style: .normal, title: "更多") { action, view, completionHadler in
            //按鈕按下去要做的事情
//            completionHadler(true)
            print("更多按鈕被按下！！！")
        }
        //設定更多按鈕的背景色
        goAction.backgroundColor = .blue
        //準備『刪除』按鈕
        let delAction = UIContextualAction(style: .destructive, title: "刪除") { action, view, completionHanler in
            //刪除資料
            print("刪除按鈕被按下！！！")
            //Step1.先刪除資料庫資料
            //--To Do--
            //Step2.刪除陣列資料
            self.arrTable.remove(at: indexPath.row)
//            print("刪除後的陣列：\(arrTable)")
            //Step3.刪除儲存格
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        //設定按鈕組合
        let config = UISwipeActionsConfiguration(actions: [goAction,delAction])
        //設定是否可以滑動到底（true可以滑到底只顯示一個按鈕）
        config.performsFirstActionWithFullSwipe = false
        //回傳按鈕組合
        return config
    }
    
    //==================================================================================================
    
    

    //=====================================儲存格拖移相關作業===================================================
    //儲存拖移時
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath)
    {
        //Step1.參數一：移除陣列原始位置的元素，直接加在新的位置
        arrTable.insert(arrTable.remove(at: fromIndexPath.row), at: to.row)

//        //確認交換過後的陣列位置
//        for (index,item) in arrTable.enumerated()
//        {
//            print("\(index)：\(item)")
//        }
        
        //Step2.更新資料庫中資料表的排序（如果有排序欄位的話）
        //--to do--
    }

    //哪一個儲存格允許拖移
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the item to be re-orderable.
        //所有儲存格都可以拖移
        return true
    }
    //==================================================================================================

//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
//    {
//        //如果不允許特定儲存格進行編輯
//        if indexPath.row == 1
//        {
//            //回傳none
//            return .none
//        }
//        else
//        {
//            //允許編輯回傳delete或insert(通常不使用insert在儲存格上)
//            return .delete
//        }
//    }
    


    // MARK: - Navigation

    //即將由導覽線換頁時
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("即將由導覽線換頁")
        //由導覽線取得下一頁的執行實體
        let detailVC = segue.destination as! DetailViewController
        //通知下一頁目前本頁的執行實體所在位置
        detailVC.myTableVC = self
    }

    //MARK: - XMLParserDelegate
    //讀到開始標籤時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        print("開始標籤：\(elementName)")
        //紀錄目前處理中的開始標籤
        tagName = elementName
    }
    //讀到標籤內容時
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        print("標籤內容：\(string)")
        //紀錄目前處理中的標籤內容
        tagContent = string
    }
    //讀到結束標籤時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        print("結束標籤：\(elementName)")
        switch elementName
        {
            case "no":  //當讀取得各個欄位的結束時
                //將欄位資料填入單筆結構成員中
                structRow.no = tagContent
            case "name":
                structRow.name = tagContent
            case "gender":
                structRow.gender = tagContent
            case "picture":
                structRow.picture = tagContent
            case "phone":
                structRow.phone = tagContent
            case "address":
                structRow.address = tagContent
            case "myclass":
                structRow.myclass = tagContent
            case "student": //當單筆學生資料結束時
                //將資料加入陣列
                arrTable.append(structRow)
            default:    //讀到xmlTable結束標籤時
                break
        }
    }
    //解析完整份XML文件時
    func parserDidEndDocument(_ parser: XMLParser)
    {
        //轉回主執行緒更新表格資料
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
