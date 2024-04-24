//
//  contactViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/05.
//

import Foundation
import UIKit

class ContactViewController: UIViewController {
    
    var header: String = ""
    var address: String = ""
    var phoneNumber: String = ""
    var siteUrl: String  = ""
    var facebook: String = ""
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = header
        }
    }
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.text = address
        }
    }
    @IBOutlet weak var callButton: UIButton! {
        didSet {
            callButton.setTitle(phoneNumber, for: .normal)
        }
    }
    @IBOutlet weak var siteButton: UIButton! {
        didSet {
            siteButton.setTitle(siteUrl, for: .normal)
//            siteButton.titleLabel?.font = UIFont(name: "KFhimaji",size: 22)
        }
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
        self.navigationItem.title = "お問い合わせ"
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        let number = phoneNumber.replacingOccurrences(of: "-", with: "")
        print(number)
        let url = NSURL(string: "tel://\(number)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }

    @IBAction func siteButtonTapped(_ sender: UIButton) {
        // 画面遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "Facility", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "webView") as! WebViewController//遷移先のViewControllerを設定
        nextViewController.url = siteUrl
        self.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
    }
    
    
    @IBAction func facebookIconTapped(_ sender: UIBarButtonItem) {
        let url = URL(string: facebook)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
