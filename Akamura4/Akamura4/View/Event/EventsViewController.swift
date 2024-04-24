//
//  ViewController.swift
//  PBL_event
//
//  Created by Yasutaka on 2021/10/09.
//

import UIKit
import SafariServices

final class EventsViewController: UIViewController {
    @IBOutlet weak var topView: UIView! {
        didSet {
            //topViewをNavigationbarの色に設定
            topView.backgroundColor = .ThemeColor
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UIView! {
        didSet {
            buttonView.backgroundColor = UIColor(red: 252/255, green: 243/255, blue: 222/255, alpha: 1.0)
            buttonView.layer.borderWidth = 1.0
            buttonView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var detailLabel: UILabel! {
        didSet {
            //textViewの枠色、枠線の太さ、枠の形、テキストの色設定
            detailLabel.backgroundColor = .clear
//            detailLabel.layer.borderWidth = 1.0
            //detailLabel.layer.cornerRadius = 20.0
            detailLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            detailLabel.lineBreakMode = .byWordWrapping
            detailLabel.adjustsFontSizeToFitWidth = true
            detailLabel.minimumScaleFactor = 0.3
            detailLabel.sizeToFit()
        }
    }
    @IBOutlet weak var videoShowButton: UIButton! {
        didSet {
            videoShowButton.backgroundColor = .ThemeColor
            videoShowButton.setTitle("動画はこちらから", for: .normal)
            videoShowButton.setTitleColor(UIColor.white, for: .normal)
            videoShowButton.titleLabel?.font = UIFont(name: "KFhimaji", size: 32)
        }
    }
    
    var titleName: String = ""
    var detail: String = ""
    var videoUrl: String = ""
    var month: String = ""
    var picture: String = ""
    var events: Events?
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //AppDelegateでNavigationbarの色と文字のフォントはまとめて設定
/*        //Navigationbarのタイトルのフォントを指定
        self.navigationController?.navigationBar.titleTextAttributes
        = [NSAttributedString.Key.font: UIFont(name: "KFhimaji", size: 15)!]
*/
        buttonHidden()
        showEvents()
        
    }
    
    private func buttonHidden() {
        //videoが無いときボタンを非表示
        if videoUrl != "" {
            videoShowButton.isHidden = false
        } else {
            videoShowButton.isHidden = true
        }
    }
    
    private func showEvents() {
        self.navigationItem.title = titleName
        detailLabel.text = detail
        
        settingImage()
    }
    
    // DocumentディレクトリのfileURLを取得
    private func getDocumentsURL() -> NSURL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentsURL
    }
    
    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
    private func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    }
    
    private func loadImageFromPath(imagePath: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: imagePath)
        if image == nil {
            print("missing image at: \(imagePath)")
        }
        return image
    }
    
    private func settingImage() {
        Task {
            print("Loaded")
            let url = "http://133.17.165.154:8086/akamura4/Pictures/\(picture).png"
            let getImage = try await AkamuraAPIService.shared.fetchImage(with: url)
            let image = UIImage(data: getImage)
            Task { @MainActor in
                imageView.image = image
            }
        }
    }
    
    @IBAction func videoButton(_ sender: UIButton) {
        
        let url = NSURL(string: videoUrl)
        
        if UIApplication.shared.canOpenURL(url! as URL) {
          UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
}

