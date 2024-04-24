//
//  PostViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/12.
//

import Foundation
import UIKit

class PostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var satisfiedButton: [UIButton]!
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet var errorMessageCollection: [UILabel]! {
        didSet {
            _ = errorMessageCollection.map { $0.isHidden = true }
        }
    }
    @IBOutlet weak var countLabel: UILabel! {
        didSet {
            countLabel.isHidden = true
        }
    }
    
    var pickerView = UIPickerView()
    let ageData = ["10代以下","20代","30代","40代","50代","60代","70代","80代以上","非公開"]
    var ageSelect = "10代以下"
    var ageSelectNumber = 0
    var satisfiedNumber = 0
    var ageNumber = 0
    
    struct Check {
        var emptyTitle = true // titleが空の場合 true
        var emptyBody = true // bodyが空の場合　true
        
        var titleError = true
        var bodyError = true
        var ageError = true
        var satisfiedError = true
    }
    var check = Check()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ageData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageSelect = ageData[row]
        ageSelectNumber = row
    }
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.delegate = self
        createPickerView()
        setTapGesture()
    }
    
    func createPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        ageTextField.inputView = pickerView
        // toolbar
        let toolbar = UIToolbar()
//        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
//        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PostViewController.donePicker))
//        toolbar.setItems([doneButtonItem], animated: true)
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(PostViewController.cancelPicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(PostViewController.donePicker))
        toolbar.items = [cancelButton, space,  doneButton]
        toolbar.sizeToFit()
        ageTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        check.ageError = false
        ageTextField.textAlignment = .center
        ageTextField.textColor = .black
        ageTextField.text = ageSelect
        ageNumber = ageSelectNumber
        print(ageNumber)
        ageTextField.endEditing(true)
    }
    
    @objc func cancelPicker() {
        ageTextField.endEditing(true)
    }
    
    @IBAction func titleTextFieldEditingDidBegin(_ sender: UITextField) {
        if check.emptyTitle { // 10文字以内で入力してくださいの文字を消す
            check.emptyTitle = false
            defaultText(area: "title")
        }
    }
    
    
    
    
    @IBAction func satisfiedButtonTapped(_ sender: UIButton) {
        check.satisfiedError = false
        if sender.tag != 4 {
            for i in sender.tag+1...4 {
                satisfiedButton[i].setImage(UIImage(named: "star"), for: .normal)
            }
        }
        for i in 0...sender.tag {
            satisfiedButton[i].setImage(UIImage(named: "star.fill"), for: .normal)
        }
        satisfiedNumber = sender.tag+1
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        errorCheck()
    
        if !check.titleError, !check.bodyError, !check.ageError, !check.satisfiedError {
            print("ErrorCheck: OK!!")
            let alert = UIAlertController(title: "確認", message: "以上の内容で投稿しますか？", preferredStyle: .alert)
            let alertYes = UIAlertAction(title: "はい", style: .default) { (action) in
                // ２個以上連続している改行は改行１個に　正規表現
                let bodyText = self.bodyTextView.text.replacingOccurrences(of: "(\n){2,}", with: "$1$1", options: NSString.CompareOptions.regularExpression, range: nil)
                
                // 情報収集
                guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else { return }
                let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
                let modelName = UIDevice.modelName
                let systemVersion = UIDevice.current.systemVersion
                
                // POST送信の準備
                let searchPostString = "userId=\(userId)&build=\(build)&modelName=\(modelName)&systemVersion=\(systemVersion)&title=\(self.titleTextField.text!)&comment=\(String(describing: bodyText))&age=\(self.ageNumber)&satisfied=\(self.satisfiedNumber)"
//                var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura/reviewWriting.php")!) // 練習
                 var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura4/reviewWriting.php")!) // 本番
                 request.httpMethod = "POST"
                 request.httpBody = searchPostString.data(using: .utf8)

                 URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    guard let data = data, error == nil, response != nil else {return }
                     let resultData = String(data: data, encoding: .utf8)!
                     print("\(resultData)")
                 })
                .resume()
                
                self.navigationController?.popViewController(animated: true)
            }
            let alertNo = UIAlertAction(title: "いいえ", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertNo)
            alert.addAction(alertYes)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "投稿できません", message: "正しく入力してください", preferredStyle: .alert)
            let alertOk = UIAlertAction(title: "OK", style: .default) {
                 (action) in self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertOk)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    //return時にキーボード閉じる(storyboardベース)
    @IBAction func closeKeyboard(_ sender: UITextField) {
    }
    
    @IBAction func titleTextFieldEditingDidEnd(_ sender: UITextField) {
        // 空白，改行を除いて判定
        let provisionalTitle = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if provisionalTitle == "" {
            check.emptyTitle = true
            defaultText(area: "title")
        }
    }
    
    
    // textField以外の部分タッチ時にキーボード閉じる
    @objc func othersViewTapped() {
        // 空白，改行を除いて判定
        let provisionalTitle = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if provisionalTitle == "" {
            check.emptyTitle = true
            defaultText(area: "title")
        }
        // 空白，改行を除いて判定
        let provisionalBody = bodyTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if provisionalBody == "" {
            check.emptyBody = true
            defaultText(area: "body")
        }
        self.view.endEditing(true)
    }
    
    func defaultText(area: String) { // 灰色の文字を出すかどうか
        
        switch area {
        case "title":
            if check.emptyTitle {
                titleTextField.textColor = .lightGray
                titleTextField.text = "10文字以内で入力してください"
            } else { // 入力する際に"10文字以内で入力してください"を消す
                titleTextField.textColor = .black
                titleTextField.text = ""
            }
        case "body":
            if check.emptyBody {
                bodyTextView.textColor = .lightGray
                bodyTextView.text = "140文字以内で入力してください"
                countLabel.isHidden = true
            } else { // 入力する際に"140文字以内で入力してください"を消す
                bodyTextView.textColor = .black
                bodyTextView.text = ""
            }
        default:
            print()
        }
    }
    
    func errorCheck() { // エラーが有るかどうか
        if check.emptyTitle {
            check.titleError = true
            errorMessageCollection[0].text = "※入力してください"
            errorMessageCollection[0].isHidden = false
        } else if titleTextField.text!.count > 10 {
            check.titleError = true
            errorMessageCollection[0].text = "※10文字以内で\n入力してください"
            errorMessageCollection[0].isHidden = false
        } else {
            check.titleError = false
            errorMessageCollection[0].isHidden = true
        }
        
        if check.emptyBody {
            check.bodyError = true
            errorMessageCollection[1].text = "※入力してください"
            errorMessageCollection[1].isHidden = false
        } else {
            check.bodyError = false
            errorMessageCollection[1].isHidden = true
        }
        
        if check.ageError {
            errorMessageCollection[2].isHidden = false
        } else {
            errorMessageCollection[2].isHidden = true
        }
        
        if check.satisfiedError {
            errorMessageCollection[3].isHidden = false
        } else {
            errorMessageCollection[3].isHidden = true
        }
    }
    
    func setTapGesture() {
        // 一個ずつ宣言しないと反応しない...
        let stackViewTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(othersViewTapped))
        stackView.addGestureRecognizer(stackViewTapGestureRecognizer)
        
    }

//    //textField以外の部分のタッチ時にキーボード閉じる
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touch!")
//        self.view.endEditing(true)
//        print("touch!")
//    }
}

extension PostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if check.emptyBody {
            check.emptyBody = false
            defaultText(area: "body")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 空白，改行を除いて判定
        let provisionalBody = bodyTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if provisionalBody == "" {
            check.emptyBody = true
            defaultText(area: "body")
        }
    }
    
    // 文字数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
    }
    
    // 残り文字カウント
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(140 - textView.text.count)/140"
        if (140 - textView.text.count) == 0 {
            countLabel.textColor = .red
        } else {
            countLabel.textColor = .black
        }
        countLabel.isHidden = false
        errorMessageCollection[1].isHidden = true
    }
    
}
