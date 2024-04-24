//
//  ReviewDetailViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/18.
//

import Foundation
import UIKit

class ReviewDetailViewController: UIViewController {
    
    var titleText = ""
    var bodyText = ""
    var ageText = "40代"
    var dateAndTimeText = ""
    
    @IBOutlet weak var titleView: UIView! {
        didSet {
            titleView.layer.borderWidth = 0.4
            titleView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var bodyView: UIView! {
        didSet {
            bodyView.layer.borderWidth = 0.4
            bodyView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = titleText
        }
    }
    @IBOutlet weak var bodyLabel: UILabel! {
        didSet {
            bodyLabel.text = bodyText
        }
    }
    @IBOutlet weak var ageLabel: UILabel! {
        didSet {
            ageLabel.text = ageJudge(age: Int(ageText)!)
        }
    }
    
    @IBOutlet weak var dateAndTimeLabel: UILabel! {
        didSet {
            dateAndTimeLabel.text = dateAndTimeText
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
        print(bodyLabel.text!.count)
    }
    
    func ageJudge(age: Int) -> String{
        switch age {
        case 0:
            return "10代以下"
        case 7:
            return "80代以上"
        case 8:
            return "非公開"
        default:
            return "\(age+1)0代"
        }
    }
}
