//
//  Web.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/04.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var webButton: UIBarButtonItem!
    
    var webView: WKWebView!
    var url: String = ""
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(url)
        
        // WKWebViewを生成
        webView = WKWebView(frame:  view.frame)
        view.addSubview(webView)
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        
        view.bringSubviewToFront(topView)
    }
    
    @IBAction func webButtonTapped(_ sender: UIBarButtonItem) {
        let url = URL(string: url)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
