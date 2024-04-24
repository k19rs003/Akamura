//
//  SettingViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/06.
//

import Foundation
import UIKit
import MediaPlayer
import AVKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var finishButton: UIButton! {
        didSet {
            finishButton.layer.cornerRadius = 30
        }
    }
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    let howToUseTitle = ["トップ", "レビュー", "観光マップ"]
    struct VideoData {
        let topDataName: String = "top"
        let topBundleDataType: String = "mp4"
        let reviewDataName: String = "review"
        let reviewBundleDataType: String = "mp4"
        let mapDataName: String = "map"
        let mapBundleDataType: String = "mp4"
    }
    let videoData = VideoData()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howToUseTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "howToUseCell", for: indexPath)
        cell.textLabel?.text  = howToUseTitle[indexPath.row]
        cell.textLabel?.font = UIFont(name: "KFhimaji", size: 24)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            videoPlay(bundleDataName: videoData.topDataName, bundleDataType: videoData.topBundleDataType)
        case 1:
            videoPlay(bundleDataName: videoData.reviewDataName, bundleDataType: videoData.reviewBundleDataType)
            
        case 2:
            videoPlay(bundleDataName: videoData.mapDataName, bundleDataType: videoData.mapBundleDataType)
        default:
            print()
        }
    }

    
    // urlを受け取り動画を再生
    func playMovieFromUrl(movieUrl: URL?) {
        if let movieUrl = movieUrl {
//            let videoPlayer = AVPlayer(url: movieUrl)
//            let playerController = AVPlayerViewController()
//            playerController.player = videoPlayer
//            self.present(playerController, animated: true, completion: {
//                videoPlayer.play()
//            })
            
            let player:AVPlayer = AVPlayer.init(url: movieUrl)
            let controller:AVPlayerViewController = AVPlayerViewController.init()
            
            controller.player = player
            controller.view.frame = videoLocation()
            
            controller.view.layer.cornerRadius = controller.view.frame.size.width * 0.0 // 元画像が正方形のとき，0.5だと円になる
            controller.view.clipsToBounds = true // 領域以外に表示させない
//            controller.view.backgroundColor = UIColor.white.withAlphaComponent(0) // Backgroundを透明に
            
            self.addChild(controller)
            videoView.addSubview(controller.view)
            controller.didMove(toParent: self)
            player.play()
        } else {
            print("cannot play")
        }
    }
    
    // パスを受け取り動画を再生
    func playMovieFromPath(moviePath: String?) {
        if let moviePath = moviePath {
            self.playMovieFromUrl(movieUrl: URL(fileURLWithPath: moviePath))
        } else {
            print("no such file")
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
        
        self.navigationItem.title = "設定"
        versionLabel.text = "\(version) (\(build))"
        
        videoView.isHidden = true
        finishButton.isHidden = true
        grayView.isHidden = true
        view.sendSubviewToBack(grayView)
    }
    
    func videoPlay(bundleDataName: String, bundleDataType: String) {
        videoView.isHidden = false
        finishButton.isHidden = false
        grayView.isHidden = false
        view.bringSubviewToFront(grayView)
        //MovieApp_iOS -> Build Phases -> Copy Bundle Resources 内にbundle.mp4を追加
        let moviePath: String? = Bundle.main.path(forResource: bundleDataName, ofType: bundleDataType)
        playMovieFromPath(moviePath: moviePath)
    }
    
    @IBAction func finishButton(_ sender: UIButton) {
        videoView.isHidden = true
        finishButton.isHidden = true
        grayView.isHidden = true
        view.sendSubviewToBack(grayView)
        let subViews = videoView.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
    }
    
    private func videoLocation() ->  CGRect{

        let width = self.videoView.bounds.size.width
        let height = self.videoView.bounds.size.height
        
        return CGRect(x:0, y:0, width:width, height: height)
    }
    
}
