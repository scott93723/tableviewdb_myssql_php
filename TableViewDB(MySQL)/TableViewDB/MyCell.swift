import UIKit

class MyCell: UITableViewCell
{
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        //<方法二>取大頭照的四邊圓角為圖片的一半寬度，即形成圓形圖片 PS.<方法ㄧ>在MyTableViewController類別的tableView datasource事件
        imgPicture.layer.cornerRadius = imgPicture.bounds.width / 2
        self.contentView.backgroundColor = .systemGray
    }

}
