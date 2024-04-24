//
//  TopViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/10/09.
//

import AVKit
import Foundation
import MediaPlayer
import UIKit

class FirstLaunchViewController: UIViewController {
    @IBOutlet var howToUseView: UIView!
    @IBOutlet var pageLabel: UILabel! {
        didSet {
            pageLabel.text = "1/4"
        }
    }

    @IBOutlet var welcomeView: UIView!
    @IBOutlet var welcomeLabel: UILabel! {
        didSet {
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                welcomeLabel.font = welcomeLabel.font.withSize(28)
            }
        }
    }

    @IBOutlet var explanationLabel: UILabel! {
        didSet {
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                explanationLabel.font = explanationLabel.font.withSize(26)
            }
        }
    }

    @IBOutlet var asteriskLabel: UILabel! {
        didSet {
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                asteriskLabel.font = asteriskLabel.font.withSize(18)
            }
        }
    }

    @IBOutlet var videoView: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var speechBalloon: UIView! {
        didSet {
            speechBalloon.layer.cornerRadius = speechBalloon.frame.width * 0.15
        }
    }

    @IBOutlet var backButton: UIButton!
    @IBOutlet var genjiWordsLabel: UILabel!
    @IBOutlet var genjiImageView: UIImageView!
    @IBOutlet var genjiLabel: UILabel!
    @IBOutlet var yesButton: UIButton! {
        didSet {
            yesButton.layer.cornerRadius = 24
        }
    }

    @IBOutlet var noButton: UIButton! {
        didSet {
            noButton.layer.cornerRadius = 24
        }
    }

    struct VideoData {
        let topDataName: String = "top"
        let topBundleDataType: String = "mp4"
        let reviewDataName: String = "review"
        let reviewBundleDataType: String = "mp4"
        let mapDataName: String = "map"
        let mapBundleDataType: String = "mp4"
    }

    let videoData = VideoData()

    var pageNumber = 1

    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Akamura"

        view.bringSubviewToFront(howToUseView)
        howToUse()
        pageByPage()
    }

    func howToUse() {
        howToUseView.layer.cornerRadius = 20
    }

    @IBAction func nextButton(_ sender: UIButton) {
        if pageNumber < 4 {
            pageNumber += 1
        }
        pageByPage()
    }

    @IBAction func backButton(_ sender: UIButton) {
        if pageNumber > 1 {
            pageNumber -= 1
        }
        pageByPage()
    }

    @IBAction func finishButton(_ sender: UIButton) {
        if pageNumber < 4 {
            pageNumber += 5
            pageByPage()
        } else if pageNumber == 4 {
            UserDefaults.standard.set(true, forKey: "firstLaunch")
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func yesButton(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "firstLaunch")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func noButton(_ sender: UIButton) {
        pageNumber -= 5
        pageByPage()
    }

    func pageByPage() {
        switch pageNumber {
        case 1:
            pageLabel.text = "1/4"
            let subViews = videoView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            videoPlay(bundleDataName: videoData.topDataName, bundleDataType: videoData.topBundleDataType)

            explanationLabel.text = "まずアプリの使い方を説明するよ"
            welcomeLabel.isHidden = false
            welcomeView.isHidden = false
            genjiWordsLabel.isHidden = true
            speechBalloon.isHidden = true
            genjiImageView.isHidden = true
            genjiLabel.isHidden = true
            backButton.isHidden = true
            pageLabel.isHidden = false
            nextButton.isHidden = false
            finishButton.isHidden = false
            yesButton.isHidden = true
            noButton.isHidden = true
        case 2:
            pageLabel.text = "2/4"
            let subViews = videoView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            videoPlay(bundleDataName: videoData.reviewDataName, bundleDataType: videoData.reviewBundleDataType)

            explanationLabel.text = "まずアプリの使い方を説明するよ"
            welcomeLabel.isHidden = false
            welcomeView.isHidden = false
            backButton.isHidden = false
            pageLabel.isHidden = false
            genjiImageView.isHidden = true
            nextButton.isHidden = false
            finishButton.isHidden = false
            yesButton.isHidden = true
            noButton.isHidden = true
        case 3:
            pageLabel.text = "3/4"
            let subViews = videoView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            videoPlay(bundleDataName: videoData.mapDataName, bundleDataType: videoData.mapBundleDataType)
            explanationLabel.text = "まずアプリの使い方を説明するよ"
            nextButton.isHidden = false
            videoView.isHidden = false
            welcomeLabel.isHidden = false
            welcomeView.isHidden = false
            genjiWordsLabel.isHidden = true
            speechBalloon.isHidden = true
            genjiImageView.isHidden = true
            genjiLabel.isHidden = true
            backButton.isHidden = false
            pageLabel.isHidden = false
            nextButton.isHidden = false
            finishButton.isHidden = false
            yesButton.isHidden = true
            noButton.isHidden = true
        case 4:
            pageLabel.text = "4/4"

            explanationLabel.text = "アプリの使い方はわかったかな？"

            let subViews = videoView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            nextButton.isHidden = true
            //            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            videoView.isHidden = true
            welcomeLabel.isHidden = true
            welcomeView.isHidden = true
            genjiWordsLabel.isHidden = false
            backButton.isHidden = false
            speechBalloon.isHidden = false
            genjiImageView.isHidden = false
            genjiLabel.isHidden = false

        default:
            explanationLabel.text = "アプリの使い方を終了します。よろしいですか？"
            welcomeLabel.isHidden = true
            welcomeView.isHidden = true
            let subViews = videoView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            videoView.isHidden = true
            pageLabel.isHidden = true
            backButton.isHidden = true
            genjiImageView.isHidden = false
            //            nextButton.setTitle("はい", for: .normal)
            //            finishButton.setTitle("いいえ", for: .normal)
            nextButton.isHidden = true
            finishButton.isHidden = true
            yesButton.isHidden = false
            noButton.isHidden = false
        }
    }

    // urlを受け取り動画を再生
    func playMovieFromUrl(movieUrl: URL?) {
        if let movieUrl = movieUrl {
            let player: AVPlayer = AVPlayer(url: movieUrl)
            let controller: AVPlayerViewController = AVPlayerViewController()

            controller.player = player
            controller.view.frame = videoLocation()

            controller.view.layer.cornerRadius = controller.view.frame.size.width * 0.0 // 元画像が正方形のとき，0.5だと円になる
            controller.view.clipsToBounds = true // 領域以外に表示させない
            //            controller.view.backgroundColor = UIColor.white.withAlphaComponent(0) // Backgroundを透明に

            addChild(controller)
            videoView.addSubview(controller.view)
            controller.didMove(toParent: self)
//            player.play()
        } else {
            print("cannot play")
        }
    }

    // パスを受け取り動画を再生
    func playMovieFromPath(moviePath: String?) {
        if let moviePath = moviePath {
            playMovieFromUrl(movieUrl: URL(fileURLWithPath: moviePath))
        } else {
            print("no such file")
        }
    }

    func videoPlay(bundleDataName: String, bundleDataType: String) {
        videoView.isHidden = false

        // MovieApp_iOS -> Build Phases -> Copy Bundle Resources 内にbundle.mp4を追加
        let moviePath: String? = Bundle.main.path(forResource: bundleDataName, ofType: bundleDataType)
        playMovieFromPath(moviePath: moviePath)
    }

    private func videoLocation() -> CGRect {
        let width = videoView.bounds.size.width
        let height = videoView.bounds.size.height

        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}
