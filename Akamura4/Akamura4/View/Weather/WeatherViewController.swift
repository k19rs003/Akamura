//
//  WeatherViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/10/17.
//


import UIKit
import WebKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var WeatherButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var topView: UIView!
    
//    let red = UIColor(hex:"7D0100")//赤村 色
    
    // ※TopからSegueを通ったときに本来は送る
    let url = URL(string: "https://weather.yahoo.co.jp/weather/jp/40/8230/40609.html")!
    var progressView = UIProgressView()//進行のバー
    
    
    private func webLoad(){
        let request = URLRequest(url: url)
        webView.load(request)
        //スワイプで遷移できる
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    private func setupUI(){
        //プログレスバー
        progressView = UIProgressView(frame: CGRect(x:0,y: self.navigationController!.navigationBar.frame.size.height , width: self.view.frame.size.width, height: 10))
        progressView.progressViewStyle = .bar
        self.navigationController?.navigationBar.addSubview(progressView)
        //プログレスバー色
        let progressRgba = UIColor(red: 128/255, green: 0, blue: 128/255, alpha: 1.0)
        progressView.progressTintColor = progressRgba
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "estimatedProgress") {
            // alphaを1にして(表示)
            self.progressView.alpha = 1.0
            // estimatedProgressが変更されたときにプログレスバーの値を変更
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            
            // estimatedProgressが1.0になったらアニメーションを使って非表示にしアニメーション完了時0.0にする
            if (self.webView.estimatedProgress >= 1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseOut], animations: { [weak self] in
                    self?.progressView.alpha = 0.0
                    }, completion: {
                        (finished : Bool) in
                        self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //KVO監視
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
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
        
        self.navigationItem.title = "天気"
//        self.navigationController?.navigationBar.tintColor = red
        self.topView.backgroundColor = .ThemeColor
        
        webLoad()
        self.setupUI()
        
    }
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
    }
    @IBAction func openSafari(_ sender: UIBarButtonItem) {
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
 
}

