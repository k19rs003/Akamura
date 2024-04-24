//
//  Co2NotificationSettingViewController.swift
//  Akamura4-Swift
//
//  Created by Abe on R 4/05/30.
//

import UIKit
import CloudKit

class Co2NotificationDetailViewController: UIViewController, UITextFieldDelegate {
    
    var locationNotificationValue = [[String]]()
    // 個別の通知設定をしている場所のすべてのデータ
    var individualNotificationValue = [String: [[String]]]()
    var location = "" { // デフォルト変更画面か判定できる
        didSet {
            // 今開いているlocationの個別通知のデータ
            locationNotificationValue = individualNotificationValue.filter{$0.key == location}[location] ?? []
            print("individualNotificationValue: \(individualNotificationValue)")
            print("locationNotificationValue: \(locationNotificationValue)")
        }
    }
    var whatAlert = 0 // 上のラベル
    var alertType = 0 // 通知タイプ
    var registeredDefaultNotificationValue = UserDefaults.standard.array(forKey: "registeredDefaultNotificationValue") as? [[String]] ?? [] // 登録されているデフォルト通知の値
    var defaultValue = UserDefaults.standard.array(forKey: "defaultNotificationValue") as? [[String]] ?? [] { // デフォルトの通知の値
        didSet {
            if defaultValue.isEmpty {
                defaultValue = registeredDefaultNotificationValue
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            if !locationNotificationValue.isEmpty { // 個別に通知設定をしてたら青文字
                self.titleLabel.textColor = .Co2IndividualNotification
            }
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertTitleView: UIView!
    @IBOutlet var alertBackgroundView: [UIView]! {
        didSet {
            for i in 0..<alertBackgroundView.count {
                if i % 2 == 0 {
                    alertBackgroundView[i].backgroundColor = .clear
                } else {
                    alertBackgroundView[i].backgroundColor = .lightGray
                }
            }
        }
    }
    @IBOutlet weak var typeRegisteredNotificationView: UIView!
    
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel.isHidden = true
        }
    }
    @IBOutlet weak var bulkChangeButton: UIButton!
    @IBOutlet weak var decisionButton: UIButton! {
        didSet {
            decisionButton.isHidden = true
        }
    }
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var defaultSwitch: UISwitch! {
        didSet {
            defaultSwitch.isHidden = true
            if locationNotificationValue.isEmpty {
                defaultSwitch.isOn = true
            } else {
                defaultSwitch.isOn = false
            }
        }
    }
    @IBOutlet weak var onOffSwitch: UISwitch! {
        didSet {
            let flag = (registeredDefaultNotificationValue[whatAlert].count) - 1
            
            if !locationNotificationValue.isEmpty { // 個別の設定をしてたら
                
                if locationNotificationValue[whatAlert][flag] == "0" {
                    onOffSwitch.isOn = true
                } else {
                    onOffSwitch.isOn = false
                }
            } else {
                
                if defaultValue[whatAlert][flag] == "0" {
                    onOffSwitch.isOn = true
                } else {
                    onOffSwitch.isOn = false
                }
            }
            
        }
    }
    
    var registeredNotificationData = [Notifications]() // 受け取るだけ
    var registeredNotificationValue = [[],[],[],[],[]] // 実際に使う方
    
    @IBOutlet var registeredValueLabel: [UILabel]! {
        didSet {
            if location.isEmpty { // デフォルト設定画面
                
                print("registeredNotificationValue: \(registeredDefaultNotificationValue)")
                _ = registeredValueLabel.map{ $0.text = registeredDefaultNotificationValue[whatAlert][$0.tag]}
                
                for i in 0 ..< registeredValueLabel.count {
                    if registeredValueLabel[i].text == "-1" {
                        registeredValueLabel[i].text = "登録なし"
                    }
                }
                registeredValueLabel[3].text = alertType(type: registeredValueLabel[3].text ?? "")
                
            } else if !registeredNotificationData.isEmpty { // 個別設定の値があれば
                for i in 0 ..< registeredNotificationData.count {
                    registeredNotificationValue[i].append(contentsOf: [registeredNotificationData[i].alert1, registeredNotificationData[i].alert2, registeredNotificationData[i].alert3, registeredNotificationData[i].type, registeredNotificationData[i].whatAlert, registeredNotificationData[i].flag])
                }
                print("registeredNotificationValue: \(registeredNotificationValue)")
                _ = registeredValueLabel.map{ $0.text = registeredNotificationValue[whatAlert][$0.tag] as? String}
                
                for i in 0 ..< registeredValueLabel.count {
                    if registeredValueLabel[i].text == "-1" {
                        registeredValueLabel[i].text = "登録なし"
                    }
                }
                registeredValueLabel[3].text = alertType(type: registeredValueLabel[3].text ?? "")
                
            } else {
                _ = registeredValueLabel.map{ $0.text = "登録なし" }
            }
        }
    }
    
    

    @IBOutlet var alertTextField: [UITextField]! {
        didSet {
            for i in 0 ..< (defaultValue.count ) { // 文字列-1は空の意味
                for j in 0 ..< 3 {
                    if defaultValue[i][j] == "-1" {
                        defaultValue[i][j] = ""
                    }
                }
            }
            
            if !locationNotificationValue.isEmpty{ // 個別の通知の値があれば
                for i in 0 ..< (locationNotificationValue.count ) {
                    for j in 0 ..< 3 {
                        if locationNotificationValue[i][j] == "-1" {
                            locationNotificationValue[i][j] = ""
                        }
                    }
                }
            }
            
            _ = alertTextField.map{$0.delegate = self}
            
            if defaultValue.isEmpty {
                defaultValue = registeredDefaultNotificationValue
            }
            
            if location.isEmpty || locationNotificationValue.isEmpty { // デフォルト変更画面，または個別の通知の値がない
                _ = alertTextField.map{$0.text = defaultValue[whatAlert][$0.tag]}
            } else { // 個別の通知の値がある
                _ = alertTextField.map{$0.text = locationNotificationValue[whatAlert][$0.tag]}
            }
            
        }
    }
    @IBOutlet weak var typeButton: UIButton! {
        didSet {
            typeButton.setTitle(judgeTypeButtonText(), for: .normal)
            
            let typeButtonItems = UIMenu(options: .displayInline, children: [
                UIAction(title: "両方", handler: { _ in self.typeButton.setTitle("両方", for: .normal); self.alertType = 0 }),
                UIAction(title: "上がったとき", handler: { _ in self.typeButton.setTitle("上がったとき", for: .normal); self.alertType = 1}),
                UIAction(title: "下がったとき", handler: { _ in self.typeButton.setTitle("下がったとき", for: .normal); self.alertType = 2})
            ])
            typeButton.menu = UIMenu(title: "", children: [typeButtonItems])
            typeButton.showsMenuAsPrimaryAction = true
        }
    }
    
    @IBOutlet var tabButton: [UIButton]! {
        didSet {
            tabButton[whatAlert].titleLabel?.tintColor = .white
            tabButton[whatAlert].backgroundColor = .ThemeColor
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setTapGesture()
    }
    
    func setUp() {
        let flag = (self.defaultValue[self.whatAlert].count) - 1
        
        if !location.isEmpty { // 個別設定画面のとき
            titleLabel.text = location
//            decisionButton.setTitle("決定", for: .normal) フォントが変になる
            bulkChangeButton.isHidden = true
            saveButton.isHidden = true
            defaultSwitch.isHidden = false
            decisionButton.isHidden = false
        }
        
        if !locationNotificationValue.isEmpty { // 個別で通知の値を設定しているとき
            for i in 0 ..< locationNotificationValue.count {
                if locationNotificationValue[i][flag] == "1" {
                    tabButton[i].titleLabel?.tintColor = .gray
                }
            }
            if locationNotificationValue[whatAlert][flag] == "1" {
                alertTitleView.backgroundColor = .gray
            }
        } else { // デフォルト値を使用しているとき
            for i in 0 ..< (defaultValue.count) {
                if defaultValue[i][flag] == "1" {
                    tabButton[i].titleLabel?.tintColor = .gray
                }
            }
            if defaultValue[whatAlert][flag] == "1" {
                alertTitleView.backgroundColor = .gray
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        alertTextField[sender.tag].text = ""
        defaultSwitch.isOn = false
        if !location.isEmpty {
            titleLabel.textColor = .Co2IndividualNotification
        }
        if !location.isEmpty,locationNotificationValue.isEmpty { // 個別の通知の値が空だったら，とりあえずいれる．
            locationNotificationValue = defaultValue
        }
    }
    
    @IBAction func tabButtonTapped(_ sender: UIButton) {
        
        let flag = (self.defaultValue[self.whatAlert].count) - 1
        
        // タブを移動する前にTextFieldに入れた値を保存
        if location.isEmpty {
            _ = alertTextField.map{defaultValue[whatAlert][$0.tag] = $0.text ?? "-1"}
            defaultValue[0][3] = String(alertType)
            if onOffSwitch.isOn == true { // 各項目の通知設定オン
                
                defaultValue[whatAlert][flag] = "0"
                print("defaultValue: \(String(describing: defaultValue))")
            } else { // 各項目の通知設定オフ
                defaultValue[whatAlert][flag] = "1"
                print("defaultValue: \(String(describing: defaultValue))")
            }
        } else if !locationNotificationValue.isEmpty{
            _ = alertTextField.map{locationNotificationValue[whatAlert][$0.tag] = $0.text ?? "-1"}
            locationNotificationValue[0][3] = String(alertType)
            
            if onOffSwitch.isOn == true { // 各項目の通知設定オン
                
                locationNotificationValue[whatAlert][flag] = "0"
                print("locationNotificationValue: \(String(describing: locationNotificationValue))")
            } else { // 各項目の通知設定オフ
                locationNotificationValue[whatAlert][flag] = "1"
                print("locationNotificationValue: \(String(describing: locationNotificationValue))")
            }
        }
        
        // ボタンの色設定
        tabButton[whatAlert].backgroundColor = .none
        tabButton[sender.tag].backgroundColor = .ThemeColor
        
        if !locationNotificationValue.isEmpty { // 個別の通知の値がある
            if locationNotificationValue[whatAlert][flag] == "0" { // 移動する前のタブ
                tabButton[whatAlert].titleLabel?.tintColor = .ThemeColor
            }
            if locationNotificationValue[sender.tag][flag] == "0" { // 移動先のタブ
                tabButton[sender.tag].titleLabel?.tintColor = .white
                alertTitleView.backgroundColor = .ThemeColor
            } else {
                tabButton[sender.tag].titleLabel?.tintColor = .gray
                alertTitleView.backgroundColor = .gray
            }
        } else {
            if defaultValue[whatAlert][flag] == "0" { // 移動する前のタブ
                tabButton[whatAlert].titleLabel?.tintColor = .ThemeColor
            }
            if defaultValue[sender.tag][flag] == "0" { // 移動先のタブ
                tabButton[sender.tag].titleLabel?.tintColor = .white
                alertTitleView.backgroundColor = .ThemeColor
            } else {
                tabButton[sender.tag].titleLabel?.tintColor = .gray
                alertTitleView.backgroundColor = .gray
            }
        }
       
        whatAlert = sender.tag
        
        // タブごとの表示設定
        if sender.tag == 0 {
            alertBackgroundView[1].isHidden = false
            alertBackgroundView[2].isHidden = false
            alertBackgroundView[3].backgroundColor = .lightGray
            typeButton.isHidden = false
            typeLabel.isHidden = true
        } else {
            if sender.tag == 4 {
                alertBackgroundView[1].isHidden = true
                alertBackgroundView[3].backgroundColor = .lightGray
            } else {
                alertBackgroundView[1].isHidden = false
                alertBackgroundView[3].backgroundColor = .clear
            }
            alertBackgroundView[2].isHidden = true
            typeButton.isHidden = true
            typeLabel.isHidden = false
        }
        
        alertTitleLabel.text = sender.titleLabel?.text
        
        // TextFieldに文字を設定
        if locationNotificationValue.isEmpty {
            _ = alertTextField.map{ $0.text = defaultValue[whatAlert][$0.tag] }
            
            if defaultValue[whatAlert][flag] == "0" {
                onOffSwitch.isOn = true
            } else {
                onOffSwitch.isOn = false
            }
            
            if location.isEmpty ||  !registeredNotificationData.isEmpty{ // デフォルト画面
                if registeredDefaultNotificationValue[whatAlert][flag] == "0" {
                    _ = registeredValueLabel.map{ $0.text = registeredDefaultNotificationValue[whatAlert][$0.tag] }
                    registeredValueLabel[3].text = alertType(type: registeredValueLabel[3].text ?? "")
                } else {
                    _ = registeredValueLabel.map { $0.text = "登録なし" }
                }
            } else {
                _ = registeredValueLabel.map { $0.text = "登録なし" }
            }
            
            
        } else {
            if !registeredNotificationData.isEmpty { // 登録されている個別設定の値があれば
                _ = registeredValueLabel.map{ $0.text = registeredNotificationValue[whatAlert][$0.tag] as? String }
                registeredValueLabel[3].text = alertType(type: registeredValueLabel[3].text ?? "")
            } else {
                _ = registeredValueLabel.map{ $0.text = "登録なし" }
            }
            _ = alertTextField.map{$0.text = locationNotificationValue[whatAlert][$0.tag]}
            
            for i in 0 ..< registeredValueLabel.count {
                if registeredValueLabel[i].text == "-1" {
                    registeredValueLabel[i].text = "登録なし"
                }
            }
            
            if locationNotificationValue[whatAlert][flag] == "0" {
                onOffSwitch.isOn = true
            } else {
                onOffSwitch.isOn = false
            }
        }
        
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        errorCheck(type: "save")
    }
    
    
    @IBAction func bulkChangeButtonTapped(_ sender: UIButton) {
       errorCheck(type: "decision")
    }
    
    @IBAction func decisionButtonTapped(_ sender: UIButton) {
        errorCheck(type: "decision")
    }
    
    func errorCheck(type: String) {
        var intCheck = true
        var nullCheck = true
        var numberSizeCheck = true
        var value = [[String]]()
        let flag = (defaultValue[whatAlert].count) - 1
        
        if location.isEmpty { // デフォルト値変更画面
            
            // 値保存
            _ = alertTextField.map{defaultValue[whatAlert][$0.tag] = $0.text ?? "-1"}
            defaultValue[0][3] = String(alertType)
            
            if onOffSwitch.isOn == true { // 各項目の通知設定オン
                
                defaultValue[whatAlert][flag] = "0"
                print("defaultValue?: \(String(describing: defaultValue))")
            } else { // 各項目の通知設定オフ
                defaultValue[whatAlert][flag] = "1"
                print("defaultValue?: \(String(describing: defaultValue))")
            }
           
            value = defaultValue
            
        } else if !locationNotificationValue.isEmpty { // 個別変更画面
            // 値保存
            _ = alertTextField.map{locationNotificationValue[whatAlert][$0.tag] = $0.text ?? "-1"}
            locationNotificationValue[0][3] = String(alertType)
            
            if onOffSwitch.isOn == true { // 各項目の通知設定オン
                
                locationNotificationValue[whatAlert][flag] = "0"
                print("locationNotificationValue?: \(String(describing: locationNotificationValue))")
            } else { // 各項目の通知設定オフ
                locationNotificationValue[whatAlert][flag] = "1"
                print("locationNotificationValue?: \(String(describing: locationNotificationValue))")
            }
           
            value = locationNotificationValue
            
        } else if defaultSwitch.isOn == true { // 個別変更画面，デフォルト値設定
            self.dismiss(animated: true)
        }
        
        if value.isEmpty { return }
       
        
        for_loop: for i in 0 ..< value.count {
            for j in 0 ..< value[i].count {
                
                if value[i][j] == "-1" {
                    value[i][j] = ""
                }
                
                if j < 4, !value[i][j].isAlphanumeric() { // defaultValueがすべてIntかどうか判定
                    intCheck = false
                    print("intCheck is false!!")
                    break for_loop
                }
                
                if Int(value[i][3])! >= 0, Int(value[i][3])! <= 2, j < 2, value[i][j] == "", value[i][j+1] != "" { // CO2みたいな通知タイプのときだけ判定
                    nullCheck = false
                    print("nullCheck is false!!")
                    break for_loop
                }
            }
        }
        
        if !intCheck {
            let alert = UIAlertController(title: "エラー", message: "半角数字のみを入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        } else if !nullCheck {
            let alert = UIAlertController(title: "エラー", message: "アラート１，アラート２を設定せずにアラート２，アラート３を設定することはできません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        } else { // すべてIntだったらアラート１よりアラート２，アラート２よりアラート３が大きいか判定
            for_loop: for i in 0 ..< value.count {
                for j in 0 ..< 2 {
                    if value[i][j] != "" , value[i][j+1] != "" {
                        if Int(value[i][j])! >= Int(value[i][j+1])! {
                            numberSizeCheck = false
                            print("numberSizeCheck is false!!")
                            break for_loop
                        }
                    }
                }
            }
        }
        
        if !numberSizeCheck {
            let alert = UIAlertController(title: "エラー", message: "アラート１よりアラート２，アラート２よりアラート３を大きな数字にしてください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)

            self.present(alert, animated: true, completion: nil)
        }
        
        // オールオッケーだったらする処理
        if intCheck, numberSizeCheck, nullCheck {
            if location.isEmpty, type == "decision" { // 一括変更決ボタン
                let alert = UIAlertController(title: "確認", message: "個別で設定しているアラートも全て変更されます。本当に変更しますか？", preferredStyle: .alert)
                let ok = UIAlertAction(title: "はい", style: .default) { (action) in
                    for i in 0 ..< (self.defaultValue.count) {
                        for j in 0 ..< self.defaultValue[i].count {
                            if self.defaultValue[i][j] == "" {
                                self.defaultValue[i][j] = "-1"
                            }
                        }
                    }
                    print("defaultValue: \(String(describing: self.defaultValue))")
                    UserDefaults.standard.set(self.defaultValue, forKey: "defaultNotificationValue")
                    UserDefaults.standard.set(self.defaultValue, forKey: "registeredDefaultNotificationValue")
                    //　個別の通知設定全削除
                    self.individualNotificationValue = [:]
                    UserDefaults.standard.set(self.individualNotificationValue, forKey: "individualNotificationValue")
                    
                    self.dismiss(animated: true)
                }
                let cancel = UIAlertAction(title: "キャンセル", style: .default)
                alert.addAction(cancel)
                alert.addAction(ok)

                self.present(alert, animated: true, completion: nil)
            } else if location.isEmpty, type == "save" { // デフォルト値保存ボタン
                for i in 0 ..< self.defaultValue.count {
                    for j in 0 ..< (self.defaultValue[i].count ) {
                        if self.defaultValue[i][j] == "" {
                            self.defaultValue[i][j] = "-1"
                        }
                    }
                }
                print("defaultValue: \(String(describing: self.defaultValue))")
                UserDefaults.standard.set(self.defaultValue, forKey: "defaultNotificationValue")
                UserDefaults.standard.set(self.defaultValue, forKey: "registeredDefaultNotificationValue")
    
                self.dismiss(animated: true)
            } else if !location.isEmpty { // 個別変更ボタン
                
                if !locationNotificationValue.isEmpty {
                    for i in 0 ..< (self.locationNotificationValue.count) {
                        for j in 0 ..< (self.locationNotificationValue[i].count) {
                            if self.locationNotificationValue[i][j] == "" {
                                self.locationNotificationValue[i][j] = "-1"
                            }
                        }
                    }
                }
                
                individualNotificationValue.updateValue(locationNotificationValue, forKey: location)
                print("individualNotificationValue: \(individualNotificationValue)")
                UserDefaults.standard.set(individualNotificationValue, forKey: "individualNotificationValue")
                
                self.dismiss(animated: true)
            }
            
        }
    }
    
    
    func judgeTypeButtonText() -> String{
        if location.isEmpty || locationNotificationValue.isEmpty{
            switch defaultValue[whatAlert][3] {
            case "0": alertType = 0; return "両方"
            case "1": alertType = 1; return "上がったとき"
            case "2": alertType = 2; return "下がったとき"
            default: return ""
            }
        } else {
            switch locationNotificationValue[whatAlert][3] {
            case "0": alertType = 0; return "両方"
            case "1": alertType = 1; return "上がったとき"
            case "2": alertType = 2; return "下がったとき"
            default: return ""
            }
        }
    }

    
    // scrollViewの中のtextField以外の部分をタップしたとき
    func setTapGesture() {
        let stackViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(othersViewTapped))
        stackView.addGestureRecognizer(stackViewTapGestureRecognizer)
    }
    // return時にキーボード閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // textField以外の部分ををタップしたときにキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // textField以外の部分タッチ時にキーボード閉じる
    @objc func othersViewTapped() {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        defaultSwitch.isOn = false
        titleLabel.textColor = .Co2IndividualNotification
        if !location.isEmpty, locationNotificationValue.isEmpty {
            locationNotificationValue = defaultValue
        }
    }
    
    @IBAction func defaultSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            let alert = UIAlertController(title: "確認", message: "この場所のすべての通知をデフォルトの値に変更しますか？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "はい", style: .default) { (action) in
                self.locationNotificationValue = [] // このロケーションの個別の通知の値を消す
                self.individualNotificationValue.removeValue(forKey: self.location) // 全部の個別の通知が入ったものからこのロケーションを消す
                UserDefaults.standard.set(self.individualNotificationValue, forKey: "individualNotificationValue")
                _ = self.alertTextField.map{$0.text = self.defaultValue[self.whatAlert][$0.tag]} // TextFieldに値を入れ直す
                
                let flag = (self.defaultValue[self.whatAlert].count) - 1
                // onOffSwitchもデフォルトに
                if self.defaultValue[self.whatAlert][flag] == "0" {
                    self.onOffSwitch.isOn = true
                    self.tabButton[self.whatAlert].titleLabel?.textColor = .white
                    self.alertTitleView.backgroundColor = .ThemeColor
                } else {
                    self.onOffSwitch.isOn = false
                    self.tabButton[self.whatAlert].titleLabel?.textColor = .gray
                    self.alertTitleView.backgroundColor = .gray
                }
                
                self.titleLabel.textColor = .BlackWhite
                
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                self.defaultSwitch.isOn = false
            }
            alert.addAction(cancel)
            alert.addAction(ok)

            self.present(alert, animated: true, completion: nil)
        } else {
            titleLabel.textColor = .Co2IndividualNotification
            if !location.isEmpty, locationNotificationValue.isEmpty {
                locationNotificationValue = defaultValue
            }
        }
    }
    
    @IBAction func onOffSwitchChanged(_ sender: UISwitch) {
        if !location.isEmpty {
            titleLabel.textColor = .Co2IndividualNotification
            defaultSwitch.isOn = false
            if locationNotificationValue.isEmpty {
                locationNotificationValue = defaultValue
            }
        }
        if onOffSwitch.isOn == false {
            tabButton[whatAlert].titleLabel?.tintColor = .gray
            alertTitleView.backgroundColor = .gray
        } else {
            tabButton[whatAlert].titleLabel?.tintColor = .white
            alertTitleView.backgroundColor = .ThemeColor
        }
    }
    
    func alertType(type: String) -> String {
        switch type {
        case "0": return "両方"
        case "1": return "上がったとき"
        case "2": return "下がったとき"
        case "3": return "アラート１以下\nアラート2以上"
        case "4": return "アラート１以下\nアラート1以上"
        default: return ""
        }
    }
    
    
}

extension String {
    // 半角数字の判定
    func isAlphanumeric() -> Bool {
//        return self.range(of: "[^0-9]+", options: .regularExpression) == nil
        return self.range(of: "[^0-9]+", options: .regularExpression) == nil
    }
}

extension Co2NotificationDetailViewController { // 決定ボタンなどでdismissしたときに遷移元に通知
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}

