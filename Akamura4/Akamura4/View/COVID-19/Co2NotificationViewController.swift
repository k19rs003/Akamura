//
//  Co2Notification.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/12/17.
//

import Foundation
import UIKit

struct Notifications: Codable {
    let id: String
    let deviceToken: String
    let location: String
    let alert1: String
    let alert2: String
    let alert3: String
    let type: String
    let whatAlert: String
    let flag: String
    let modified: String
    let created: String
}

class Co2NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var locations = [String?]() 
    var co2NotificationLocation = [String]()
    var registeredNotificationData = [Notifications]()
    // 個別の通知設定をしている場所のすべてのデータ
    var individualNotificationValue = UserDefaults.standard.dictionary(forKey: "individualNotificationValue") as? [String: [[String]]] ?? [:]
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            // カスタムセルの登録
            tableView.register(UINib(nibName: "Co2NotificationCell", bundle: nil), forCellReuseIdentifier: "co2NotificationCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaultsContents()

        // UserDefaultsの形を前回と変更したため．後で消す．
        guard var defaultNotificationValue = UserDefaults.standard.array(forKey: "defaultNotificationValue") as? [[String]] else { return }
        
        if defaultNotificationValue[0].count != 6 {
            print("OLDdefaultNotificationValue: \(defaultNotificationValue)")
            for i in 0 ..< defaultNotificationValue.count {
                defaultNotificationValue[i].append("0")
            }
            print("NEWdefaultNotificationValue\(defaultNotificationValue)")
            
            for i in 0 ..< locations.count {
                guard let location = locations[i] else { return }
                for i in 0 ..< (individualNotificationValue[location]?.count ?? 0) {
                    individualNotificationValue[location]?[i].append("0")
                }
            }
            
            UserDefaults.standard.set(defaultNotificationValue, forKey: "defaultNotificationValue")
            UserDefaults.standard.set(individualNotificationValue, forKey: "individualNotificationValue")
        }
        // ここまで
    }
   
    func loadUserDefaultsContents() {
        do {
            guard let data = UserDefaults.standard.object(forKey: "registeredCo2Notification") as? Data else { return }
            registeredNotificationData = try JSONDecoder().decode([Notifications].self, from: data)
            print("loadUserDefaultsContents: \(registeredNotificationData)")
            
            co2NotificationLocation = registeredNotificationData.map{$0.location}
            co2NotificationLocation = Array(Set(co2NotificationLocation)) // 重複している要素を削除
            print("co2NotificationLocation\(co2NotificationLocation)")
        } catch {
            print("Error: JSONDecoder()")
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "co2NotificationCell") as? Co2NotificationCell {
            
//            // セルを押したときに，色を変えない
//            cell.selectedBackgroundView = {
//                let view = UIView()
//                view.backgroundColor = .clear
//                return view
//            }()
            
            if let location = locations[indexPath.row] {
                cell.locationLabel.text = location
                
                if  individualNotificationValue.keys.contains(location){ // 個別の通知設定をしてたら青文字
                    cell.locationLabel.textColor = .Co2IndividualNotification
                } else {
                    cell.locationLabel.textColor = .BlackWhite
                }
            }
            
            // 通知をオンにしている場所はスイッチオン
            let savedLocation = (registeredNotificationData.map{ $0.location }).filter({ $0 == cell.locationLabel.text})
            if !savedLocation.isEmpty {
                cell.notificationSwitch.isOn = true
            }
            
            cell.notificationSwitch.tag = indexPath.row
            cell.notificationSwitch.addTarget(self, action: #selector(self.notificationSwitchTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "Co2Notification", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "co2NotificationDetailViewController") as! Co2NotificationDetailViewController
        nextViewController.presentationController?.delegate = self // ここがポイント
        nextViewController.individualNotificationValue = individualNotificationValue
        nextViewController.registeredNotificationData = registeredNotificationData.filter{$0.location == locations[indexPath.row] ?? ""}
        nextViewController.location = locations[indexPath.row] ?? ""
        self.present(nextViewController, animated: true)
        
    }
    
    @objc private func notificationSwitchTapped(_ sender: UISwitch) {
        
        guard let location = locations[sender.tag] else { return }
        
        if  sender.isOn  {
            co2NotificationLocation.append(location)
        } else {
            co2NotificationLocation.removeAll(where: { location.contains($0) })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    @IBAction func decisionButton(_ sender: UIButton) {
        
        print("co2NotificationLocation\(co2NotificationLocation)")
        
        var co2Notifications: String = ""
        
        // 保存されている値を読み込む
        guard let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String else { failureToRegisterNotifications(type: "deviceToken"); return }
        if deviceToken == "0" {
            failureToRegisterNotifications(type: "deviceToken");
            return
        }
        
        guard var defaultNotificationValue = UserDefaults.standard.array(forKey: "registeredDefaultNotificationValue") as? [[String]] else { failureToRegisterNotifications(type: "none"); return }
        
        let flag = defaultNotificationValue[0].count - 1
        
        for i in 0 ..< defaultNotificationValue.count { // flagが1(無効)だったら，値を-1に
            if defaultNotificationValue[i][flag] == "1" {
                for j in 0 ..< 3 {
                    defaultNotificationValue[i][j] = "-1"
                }
            }
            defaultNotificationValue[i].remove(at: flag)
        }
        
        let flatValue = defaultNotificationValue.flatMap{ $0 }
        var defaultCo2NotificationsData = ""
        
        
        for i in 0 ..< flatValue.count { // デフォルトの値を送る形に
            if i != 0, i % 5 == 0 {
                defaultCo2NotificationsData += "/"
            }
            defaultCo2NotificationsData += flatValue[i]
            defaultCo2NotificationsData += ","
        }
        
        for i in 0 ..< co2NotificationLocation.count {
            if i != 0 {
                co2Notifications += "&"
            }
            co2Notifications += "co2Notifications[]="
            co2Notifications += "\(co2NotificationLocation[i]),"
            
            if individualNotificationValue.keys.contains(co2NotificationLocation[i]) { // 個別の通知設定があったら個別の通知の値を
//                var flatValue = (individualNotificationValue[co2NotificationLocation[i]].flatMap{ $0 }).flatMap{ $0 } ?? [] // できない．．
                var value = individualNotificationValue[co2NotificationLocation[i]].flatMap{ $0 } ?? []
                
                for i in 0 ..< value.count { // flagが1(無効)だったら，値を-1に
                    if value[i][flag] == "1" {
                        for j in 0 ..< 3 {
                            value[i][j] = "-1"
                        }
                    }
                    value[i].remove(at: flag)
                }
                
                print("value: \(value)")
                let flatValue = value.flatMap{$0}
                var individualCo2NotificationsData = ""
                
                for i in 0 ..< flatValue.count { // 個別の通知の値を送る形に
                    if i != 0, i % 5 == 0 {
                        individualCo2NotificationsData += "/"
                    }
                    individualCo2NotificationsData += flatValue[i]
                    individualCo2NotificationsData += ","
                }
                co2Notifications += individualCo2NotificationsData.replacingOccurrences(of: "/", with: "/\(co2NotificationLocation[i]),")
            } else { // 個別の通知設定がなかったらデフォルト値を
                co2Notifications += defaultCo2NotificationsData.replacingOccurrences(of: "/", with: "/\(co2NotificationLocation[i]),")
            }
            
        }
        print("co2Notifications:\(co2Notifications)")
        
        guard let encodeString = co2Notifications.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { failureToRegisterNotifications(type: "none"); return }
        var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/co2/co2Notification.php?deviceToken=\(deviceToken)&\(encodeString)")!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, error == nil, response != nil else {
                DispatchQueue.main.async {
                    
                    self.failureToRegisterNotifications(type: "none")
                    
                }
                
                return
                
            }
            
            do {
                self.registeredNotificationData = try JSONDecoder().decode([Notifications].self, from: data)
//                print("registeredNotificationData: \(self.registeredNotificationData)")
                print("JSONDecode: Success!")
                // データをローカルに保存
                print("data: \(data)")
                UserDefaults.standard.set(data, forKey: "registeredCo2Notification")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            } catch {
                print("JSONDecode: Error!")
            }
            
        })
            .resume()
    }
    
    func failureToRegisterNotifications(type: String) {
        var alert = UIAlertController(title: "エラー", message: "プッシュ通知の登録に失敗しました", preferredStyle: .alert)
        
        if type == "deviceToken" {
            alert = UIAlertController(title: "エラー", message: "アプリの通知を許可してください", preferredStyle: .alert)
        }
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func questionButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "💡ヒント💡", message: "半角カンマ（ , ）、アンド（ & ）、イコール（=）、クォーテーションマーク（''\"\"）またはスラッシュ（ / ）をCO2センサの名前に使用すると上手く通知を設定できません。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        // 画面遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "Co2Notification", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "co2NotificationDetailViewController") as! Co2NotificationDetailViewController
        nextViewController.presentationController?.delegate = self // ここがポイント
        self.present(nextViewController, animated: true)
    }
    
}

extension Co2NotificationViewController: UIAdaptivePresentationControllerDelegate { // 遷移先の画面をひっぱって閉じたとき
    // このメソッドを実装
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Modal画面から戻った際の画面の更新処理を行う。 (collectionView.reloadDataなど。)
        print("Screen is back on.")
        individualNotificationValue = UserDefaults.standard.dictionary(forKey: "individualNotificationValue") as? [String: [[String]]] ?? [:]
        tableView.reloadData()
    }
}
