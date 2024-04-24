//
//  MainContentsCell.swift
//  Akamura4-Swift
//
//  Created by Tamai on 2021/10/31.
//

import UIKit

class MainContentsCell: UITableViewCell{
    
        // 天気api用のJSON
        struct topWeather: Codable{
    
            let weather: [Weather]
            let main: Main
        }
    
        struct Weather: Codable{
    
            let icon: String
    
        }
    
        struct Main: Codable{
    
            let temp: Double
            let temp_min: Double
            let temp_max: Double
        }
    
    var topViewController = TopViewController()
    
    let faceBookUrl = URL(string: "https://www.facebook.com/akamura.krt")!//村おこし
    let eventUrl = URL(string: "http://www.akamura.net/sightseeing/event.html")!//イベント用URL
    let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=Tagawa,JP&units=metric&appid=85ecd2795ce2db948c0148683ad74404" )//天気facebookのapi(※Akamura3と同じものを使用している)
    let firstImageView = UIImageView(image: UIImage(named: "1"))//表示する画像の最初
    var imageFrame = CGRect(x: 0, y: 0, width: 0, height: 0)//スライドショーのフレーム
    let delay = 2.0//間隔？
    let maxImageNumber = 5//表示する画像の数
    @objc dynamic var imageNumber = 1//監視(※よくわからん)→解決:Objective-Cのランチタイムを使用するため
    var currentNumber = 0 //最新番号
    var viewState = 0//画像の状態の初期状態
    let current = Calendar.current
    var weather = [Weather]()
    var main = [Main]()
    
    
    @IBOutlet weak var facilitiesButton: UIButton!{//施設紹介用
        didSet{
            facilitiesButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var touristMapButton: UIButton! {//観光マップ用
        didSet{
            touristMapButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var eventLabel: UILabel! //イベント用のラベル

    @IBOutlet weak var imageControl: UIPageControl!//画像切替用
    @IBOutlet weak var imageShowView: UIView!{ //スライド用のView
        didSet{
            imageShowView.backgroundColor = UIColor.clear //背景は透明
        }
    }
    
    override func awakeFromNib() {
            super.awakeFromNib()
                test()
                setEventLabel()
                
                imageControl.numberOfPages = maxImageNumber //ページの数
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){//１秒後に括弧内の処理を実行
                    self.start()//画像をViewにセット
                    
        
                }
            
        }
    
        private func setEventLabel(){
            let month = current.component(.month, from: Date())
    
            if month >= 3, month <= 5 {
                eventLabel.text = "春のイベント"
            }else if month >= 6, month <= 8 {
                eventLabel.text = "夏のイベント"
            }else if month >= 9, month <= 11 {
                eventLabel.text = "秋のイベント"
            }else {
                eventLabel.text = "冬のイベント"
            }
    
        }
    
        private func start(){
            self.frame.size = imageShowView.frame.size//フレームに画像のサイズを代入(画像のサイズに変更できるということ※frameは0にセットしている)
    
            firstImageView.frame = frame
            //self.firstImageView.frame = imageView.frame.size//(Cannot assign value of type 'CGSize' to type 'CGRect')タイプが違うので代入できない
    
            firstImageView.contentMode = .scaleAspectFill
            firstImageView.clipsToBounds = true//Viewのサイズに切り取る
            firstImageView.alpha = 0 //透過度0
            imageShowView.addSubview(firstImageView)
    
            //withDuration:アニメーション時間 delay:開始までの遅延時間 curveEaseOut:動き終わりがゆっくりになる animations:アニメーションしたViewのプロパティを変更 completion:アニメーションが完了したタイミングで実行
            UIView.animate(withDuration: delay, delay: delay, options: .curveEaseOut, animations: {
                self.firstImageView.alpha = 1.0//1.0
            }, completion: {_ in
                self.repeatImageShow()
            })
    
        }
    
        // 繰り返しのメソッド
        func repeatImageShow(){
            self.imageNumber += 1
            self.currentNumber += 1
    
            if self.maxImageNumber < self.imageNumber {
                //repeat
                self.imageNumber = 1
                self.currentNumber = 0
    
            }
    
            frame.size = imageShowView.frame.size
            let secondImageView = UIImageView(frame: frame)
            //secondImageView.layer.cornerRadius = 10.0
            secondImageView.image = UIImage(named: String(self.imageNumber))
            secondImageView.contentMode = .scaleAspectFill
            secondImageView.clipsToBounds = true
            secondImageView.frame = frame
            secondImageView.alpha = 0 //0
    
            //firstImageViewの上にsecondImageViewを差し込む
            self.imageShowView.insertSubview(secondImageView, aboveSubview: self.firstImageView)
    
            UIView.animate(withDuration: self.delay, delay: self.delay, options: .curveEaseOut, animations: {
                secondImageView.alpha = 1.0//1.0
            }, completion: {_ in
                self.firstImageView.image = secondImageView.image
                secondImageView.removeFromSuperview()
                self.repeatImageShow()
            })
        }
    
    
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
           // print(imageNumber)
            self.imageControl.currentPage = currentNumber
        }
    
//        override func viewDidAppear(_ animated: Bool) {//通知を受け取る
//            self.addObserver(self, forKeyPath: "imageNumber", options: .new, context: nil)
//        }
    
        deinit {
            removeObserver(self, forKeyPath: "imageNumber")
        }
    
        //天気関係のdecode
        func loadJson(){
            guard let url = url else {return}
            do{
                let json = try JSONDecoder().decode(topWeather.self, from: Data(contentsOf: url))
                self.weather = json.weather
                self.main = [json.main]
    
                print("JSON success!!")
            } catch let error{
                print("Error: loadJson()\n\(error)")
            }
        }
    
        func getImage(){
    
    
            if weather.count > 0 {
    
                guard let url =  URL(string: "http://openweathermap.org/img/w/\(weather[0].icon).png") else { return }
    
                URLSession.shared.dataTask(with: url) { data, URLResponse, error in
    
                    guard let data = data, error == nil, URLResponse != nil else { return }
    
                    DispatchQueue.main.async {
    
                        self.weatherIconButton.setImage(UIImage(data: data), for: UIControl.State()) }
                    print("getImage success!!")
                }
    
                .resume()
            }
        }
    
        func tempSet(){
    
            //小数点をずらす
            var temp = (main[0].temp)*10
            var temp_max = (main[0].temp_max)*10
            var temp_min = (main[0].temp_min)*10
    
            //INT
            //        let temp = main[0].temp
            //        let temp_max = main[0].temp_max
            //        let temp_min = main[0].temp_min
    
            //四捨五入
            temp = (round(temp) / 10)
            temp_max = (round(temp_max) / 10)
            temp_min = (round(temp_min) / 10)
    
    
            temperatureAverageLabel.text = "\(temp)(℃)"
            tempratureMaxValueLabel.text = "\(temp_max)(℃)"
            temperatureMiniLabel.text = "\(temp_min)(℃)"
    
        }
    
        func test(){
            guard let url = url else { return }
            //タスクの作成
            URLSession.shared.dataTask(with: url){(data, URLResponse, error) in
                guard let _ = data, URLResponse != nil, error == nil else { return }
    
                DispatchQueue.main.async {
    
                    self.loadJson()
                    self.tempSet()
                    self.getImage()
                }
    
                print("session success")
            }.resume()//開始
        }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        if UIApplication.shared.canOpenURL(faceBookUrl){
            UIApplication.shared.open(faceBookUrl)
        }
        
    }
    
    @IBOutlet weak var placeNameLabel: UILabel!{
        didSet{
            placeNameLabel.textColor = UIColor.black
            placeNameLabel.font = UIFont(name: "KFhimaji", size: 21)
            placeNameLabel.text = "赤村の天気"
        }
    }
  
    @IBOutlet weak var temperatureAverageLabel: UILabel!{
                didSet{
                    temperatureAverageLabel.textColor = UIColor.black
                    temperatureAverageLabel.font = UIFont(name: "KFhimaji", size: 16)
                }
            }
    
    @IBOutlet weak var tempratureMaxValueLabel: UILabel!{
                    didSet{
                        tempratureMaxValueLabel.textColor = UIColor.red
                        tempratureMaxValueLabel.font = UIFont(name: "KFhimaji", size: 16)
                    }
                }
    
    @IBOutlet weak var temperatureMiniLabel: UILabel!{
                didSet{
                    temperatureMiniLabel.textColor = UIColor.blue
                    temperatureMiniLabel.font = UIFont(name: "KFhimaji", size: 16)
                }
            }
    @IBOutlet weak var weatherIconButton: UIButton!
    
    @IBAction func weatherImageAction(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        let storyboard: UIStoryboard = UIStoryboard(name: "Weather", bundle: nil)//遷移先のStoryboardを設定
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "weatherViewController") as! WeatherViewController//遷移先のViewControllerを設定
        
        topViewController.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
    }
    
    

    
    
    @IBAction func MapAction(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Map", bundle: nil)//遷移先のStoryboardを設定
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "rightMenuNavigationController") as! MapViewController//遷移先のViewControllerを設定
        
        topViewController.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
    }
    

    
    @IBAction func FacilityAction(_ sender: UIButton) { //反応しない 識別できないものを送っている 名前が違う？
        let storyboard: UIStoryboard = UIStoryboard(name: "Facility", bundle: nil)//遷移先のStoryboardを設定
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "facilityNavigationController") as! FacilityViewController//遷移先のViewControllerを設定
        
        topViewController.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
    }
    
    @IBAction func EventAction(_ sender: UIButton) {
        if UIApplication.shared.canOpenURL(eventUrl){
            UIApplication.shared.open(eventUrl)
        }
    }
}
