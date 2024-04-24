//
//  ReviewViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/12.
//

import Foundation
import UIKit

class ReviewListViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var allReviewData = [Review]() {
        didSet {
            DispatchQueue.main.async {
                self.tableSetup()
                self.tableView.reloadData()
            }
        }
    }
    
    var review = [Review]()
    
    let sections = ["⭐⭐⭐⭐⭐","⭐⭐⭐⭐","⭐⭐⭐","⭐⭐","⭐"]
    var reviewTitle = [[String]]()
    var reviewDate = [[String]]()
    var reviewComment = [[String]]()
    var reviewAge = [[String]]()
    
    let heightForRow: CGFloat = 60.0 //セルの高さ
    let heightForHeader: CGFloat = 30.0 //ヘッダの高さ
    var date = [[String]]()
    
    var ageMinimumSetting = 0
    var ageMaximumSetting = 8
    var dayInterval = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ageSettingButton: UIButton!
    @IBOutlet weak var periodSettingButton: UIButton!
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "レビュー"
        searchSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadJSON()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func searchSetting() {
        let ageSettingButtonItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "全て", handler: { _ in self.ageSettingButton.setTitle(" 全て　　  ", for: .normal); self.searchSetting(ageSetting: 0) }),
            UIAction(title: "〜20代", handler: { _ in self.ageSettingButton.setTitle(" 〜20代　  ", for: .normal); self.searchSetting(ageSetting: 1) }),
            UIAction(title: "30〜50代", handler: { _ in self.ageSettingButton.setTitle(" 30〜50代　", for: .normal); self.searchSetting(ageSetting: 2) }),
            UIAction(title: "60代〜", handler: { _ in self.ageSettingButton.setTitle(" 60代〜　  ", for: .normal); self.searchSetting(ageSetting: 3) })
        ])
        ageSettingButton.menu = UIMenu(title: "", children: [ageSettingButtonItems])
        ageSettingButton.showsMenuAsPrimaryAction = true
        
        let periodSettingButtonItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "全て", handler: { _ in self.periodSettingButton.setTitle(" 全て　　　", for: .normal); self.searchSetting(periodSetting: 0); self.tableSetup(); self.tableView.reloadData() }),
            UIAction(title: "半年以内", handler: { _ in self.periodSettingButton.setTitle(" 半年以内　", for: .normal); self.searchSetting(periodSetting: 1); self.tableSetup(); self.tableView.reloadData() }),
            UIAction(title: "一年以内", handler: { _ in self.periodSettingButton.setTitle(" 一年以内　", for: .normal); self.searchSetting(periodSetting: 2); self.tableSetup(); self.tableView.reloadData() }),
            UIAction(title: "三年以内", handler: { _ in self.periodSettingButton.setTitle(" 三年以内　", for: .normal); self.searchSetting(periodSetting: 3); self.tableSetup(); self.tableView.reloadData() })
        ])
        periodSettingButton.menu = UIMenu(title: "", children: [periodSettingButtonItems])
        periodSettingButton.showsMenuAsPrimaryAction = true
    }
    
    func searchSetting( ageSetting: Int ) {
        switch ageSetting {
        case 0:
            ageMinimumSetting = 0
            ageMaximumSetting = 8
        case 1:
            ageMinimumSetting = 0
            ageMaximumSetting = 1
        case 2:
            ageMinimumSetting = 2
            ageMaximumSetting = 4
        case 3:
            ageMinimumSetting = 5
            ageMaximumSetting = 7
        default: break
        }
        
        tableSetup()
        tableView.reloadData()
    }
    
    func searchSetting( periodSetting: Int ) {
        let dateToday = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: dateToday)
        
        print(today)
        
        switch periodSetting {
        case 0:
            dayInterval = 0
        case 1:
            let halfAYearAgo = Calendar.current.date(byAdding: .month, value: -6, to: dateToday)!
            dayInterval = Int((Calendar.current.dateComponents([.day], from: halfAYearAgo, to: dateToday)).day!)
        case 2:
            let AYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: dateToday)!
            dayInterval = Int((Calendar.current.dateComponents([.day], from: AYearAgo, to: dateToday)).day!)
        case 3:
            let threeYearAgo = Calendar.current.date(byAdding: .year, value: -3, to: dateToday)!
            dayInterval = Int((Calendar.current.dateComponents([.day], from: threeYearAgo, to: dateToday)).day!)
        default: break
        }
        
        tableSetup()
        tableView.reloadData()
    }
    
    func calculateDayInterval( dataSeting: String ) -> Int {
        if dayInterval == 0 {
            return 0
        } else {
            let dateToday = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = Locale(identifier: "ja_JP")
            guard let date = dateFormatter.date(from: dataSeting) else { return 0 }
            
            return Int((Calendar.current.dateComponents([.day], from: date, to: dateToday)).day!)
        }
    }
    
    func tableSetup(){
        reviewTitle.removeAll()
        reviewDate.removeAll()
        reviewComment.removeAll()
        reviewAge.removeAll()
        
        for _ in 0 ..< sections.count{
            reviewTitle.append([])
            reviewDate.append([])
            reviewComment.append([])
            reviewAge.append([])
        }
        
        review = allReviewData.filter {
            Int($0.age)! >= ageMinimumSetting && Int($0.age)! <= ageMaximumSetting &&
            calculateDayInterval(dataSeting: $0.posted) <= dayInterval
        }
        
        for index in 0 ..< review.count{
            
            // 5は，スターのcountにしたいね．
            if let satisfied: Int = Int(review[index].satisfied),  satisfied < 6, satisfied >= 0 {
                reviewTitle[sections.count - satisfied] += [review[index].title]
                reviewDate[sections.count - satisfied] += [review[index].posted]
                reviewComment[sections.count - satisfied] += [review[index].comment]
                reviewAge[sections.count - satisfied] += [review[index].age]
            }
            
//            switch Int(review[index].satisfied){
//            case 1:
//                reviewTitle[4] += [review[index].title]
//                reviewDate[4] += [review[index].posted]
//                reviewComment[4] += [review[index].comment]
//                reviewAge[4] += [review[index].age]
//
//            case 2:
//                reviewTitle[3] += [review[index].title]
//                reviewDate[3] += [review[index].posted]
//                reviewComment[3] += [review[index].comment]
//                reviewAge[3] += [review[index].age]
//            case 3:
//                reviewTitle[2] += [review[index].title]
//                reviewDate[2] += [review[index].posted]
//                reviewComment[2] += [review[index].comment]
//                reviewAge[2] += [review[index].age]
//            case 4:
//                reviewTitle[1] += [review[index].title]
//                reviewDate[1] += [review[index].posted]
//                reviewComment[1] += [review[index].comment]
//                reviewAge[1] += [review[index].age]
//            case 5:
//                reviewTitle[0] += [review[index].title]
//                reviewDate[0] += [review[index].posted]
//                reviewComment[0] += [review[index].comment]
//                reviewAge[0] += [review[index].age]
//            default: break
//            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // 背景色を変更
        view.tintColor = UIColor.ThemeColor
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15,*){
            tableView.sectionHeaderTopPadding = 0.0
        }
        return heightForHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewTitle.count < sections.count {
            return 0
        } else {
            return reviewTitle[section].count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        cell.textLabel?.text  = reviewTitle[indexPath.section][indexPath.row]
        //        cell.detailTextLabel?.text = String(reviewDate[indexPath.section][indexPath.row].dropLast(8))
        cell.detailTextLabel?.text = japaneseCaleder(String(reviewDate[indexPath.section][indexPath.row]), type: "date")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "Review", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "reviewDetail") as! ReviewDetailViewController //遷移先のViewControllerを設定
        nextViewController.titleText = reviewTitle[indexPath.section][indexPath.row]
        nextViewController.bodyText = reviewComment[indexPath.section][indexPath.row]
        nextViewController.ageText = reviewAge[indexPath.section][indexPath.row]
//        nextViewController.dateAndTimeText = reviewDate[indexPath.section][indexPath.row]
        nextViewController.dateAndTimeText = japaneseCaleder(String(reviewDate[indexPath.section][indexPath.row]), type: "twoLines")
        self.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
        
    }
    
    private func japaneseCaleder (_ dateString: String, type: String) -> String {
        
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let date = dateFormatter.date(from: dateString)
        
        if type == "date" {
            // フォーマット設定
            dateFormatter.dateFormat = "yyyy/MM/dd"
            // カレンダー設定（西暦固定）
            dateFormatter.calendar = Calendar(identifier: .gregorian)
        } else if type == "twoLines"{
            // フォーマット設定
            dateFormatter.dateFormat = "Gy'年'M'月'd'日('E')\n'HH'時'mm'分'ss'秒'"
            // カレンダー設定（和暦固定）
            dateFormatter.calendar = Calendar(identifier: .japanese)
        }
        // ロケール設定（日本語・日本国固定）
        dateFormatter.locale = Locale(identifier: "ja_JP")
        // タイムゾーン設定（日本標準時固定）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let date = date else { return "" }
        
        return dateFormatter.string(from: date)
    }
    
    
    func loadJSON(){
        
        var postString = ""
        if let deviceId = UserDefaults.standard.string(forKey: "uuid") {
            postString = "deviceId=\(deviceId)"
        }
        
//        var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura/reviewWriting.php")!) // 練習
        var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura4/reviewWriting.php")!) // 本番
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, error == nil, response != nil else {return }
            let resultData = String(data: data, encoding: .utf8)!
            print("\(resultData)")
            
            do{
                self.allReviewData = try JSONDecoder().decode([Review].self, from: data)
                print("JSONDecode: OK!!!")
            } catch {
                print("Error: didRegisterForRemoteNotificationsWithDeviceToken")
            }
        })
        .resume()
    }
}

