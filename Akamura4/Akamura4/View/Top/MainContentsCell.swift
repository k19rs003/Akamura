//
//  MainContentsCell.swift
//  Akamura4-Swift
//
//  Created by Tamai on 2021/10/31.
//

import UIKit

final class MainContentsCell: UITableViewCell {
    let faceBookUrl = URL(string: "https://www.facebook.com/akamura.krt")!//村おこし
    let eventUrl = URL(string: "http://www.akamura.net/sightseeing/event.html")!//イベント用URL
    let weatherApiUrl = "http://api.openweathermap.org/data/2.5/weather?q=Tagawa,JP&units=metric&appid=85ecd2795ce2db948c0148683ad74404"
    let firstImage = UIImage(named: "1")//表示する画像の最初
    var imageFrame = CGRect(x: 0, y: 0, width: 0, height: 0)//スライドショーのフレーム
    let maxImageNumber = 5//表示する画像の数
    var imageNumber = 1//監視(※よくわからん)→解決:Objective-Cのランチタイムを使用するため
    var currentNumber = 0 //最新番号
    //var viewState = 0//画像の状態の初期状態
    let springColor = UIColor(hex: "FF5AD3")
    let summerColor = UIColor(hex: "FFB95A")
    let fallColor = UIColor(hex: "AC6D40")
    let winterColor = UIColor(hex: "6B9BCF")
    let current = Calendar.current
    var weather = [OpenWeather.Weather]()
    var main = [OpenWeather.Main]() {
        didSet {
            // 小数点第1位まで表示
            let temperature = (main[0].temperature * 10).rounded() / 10
            let maxTemperature = (main[0].maxTemperature * 10).rounded() / 10
            let minTemperature = (main[0].minTemperature * 10).rounded() / 10

            temperatureAverageLabel.text = "\(temperature)(℃)"
            tempratureMaxValueLabel.text = "\(maxTemperature)(℃)"
            temperatureMiniLabel.text = "\(minTemperature)(℃)"
        }
    }

    @IBOutlet weak var facebookIcon: UIButton!
    @IBOutlet weak var facilitiesButton: UIButton! {//施設紹介用
        didSet {
            //facilitiesButton.layer.cornerRadius = 24
            //facilitiesButton.layer.borderWidth = 1
            //facilitiesButton.layer.borderColor = UIColor(hex: "008400").cgColor
        }
    }
    @IBOutlet weak var touristMapButton: UIButton! {//観光マップ用
        didSet {
            //touristMapButton.layer.cornerRadius = 24
            //touristMapButton.layer.borderWidth = 1
            //touristMapButton.layer.borderColor = UIColor(hex: "008400").cgColor
        }
    }
    @IBOutlet weak var eventLabel: UILabel! { // イベント用のラベル
        didSet {
            eventLabel.font = UIFont(name: "KFhimaji", size: 30)
            eventLabel.adjustsFontSizeToFitWidth = true
            eventLabel.minimumScaleFactor = 0.3
        }
    }

    @IBOutlet weak var eventDetailButton: UIButton!
    @IBOutlet weak var imageControl: UIPageControl!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var topSecondImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        Task {
            await fetchWeather()
        }
        setEventLabel()
        imageControl.numberOfPages = maxImageNumber
        start()
    }

    private func start() {
        Task { @MainActor in
            topImageView.image = firstImage
//            self.repeatImageShow()
        }
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }

    // 繰り返しのメソッド
    @objc private func changeImage() {
        self.imageNumber += 1
        self.currentNumber += 1

        if self.maxImageNumber < self.imageNumber {
            //repeat
            self.imageNumber = 1
            self.currentNumber = 0
        }
        DispatchQueue.main.async {
            self.imageControl.currentPage = self.currentNumber
            self.topImageView.image = UIImage(named: String(self.imageNumber))
        }
    }

    private func setEventLabel() {
        let month = current.component(.month, from: Date())

        if month < 3 || month == 12 {
            eventLabel.text = "冬のイベント "
            eventDetailButton.backgroundColor = winterColor
        } else if month < 6 {
            eventLabel.text = "春のイベント "
            eventDetailButton.backgroundColor = springColor
            
        } else if month < 9 {
            eventLabel.text = "夏のイベント "
            eventDetailButton.backgroundColor = summerColor
        } else {
            eventLabel.text = "秋のイベント "
            eventDetailButton.backgroundColor = fallColor
        }
    }

    //天気関係のdecode
    func fetchWeather() async {
        do {
            let contents = try await AkamuraAPIService.shared.request(with: self.weatherApiUrl, responseType: OpenWeather.self)
            self.weather = contents.weather
            self.main = [contents.main]

            if !weather.isEmpty {
                let url = "http://openweathermap.org/img/w/\(weather[0].icon).png"
                let getWeatherIcon = try await AkamuraAPIService.shared.fetchImage(with: url)
                if let imageIcon = UIImage(data: getWeatherIcon) {
                    DispatchQueue.main.async {
                        self.weatherIconButton.setImage(imageIcon, for: .normal)
                    }
                }
            }
        } catch let error {
            print("Error: loadJson()\n\(error)")
        }
    }

    @IBOutlet weak var akamuraNameLabel: UILabel!{
        didSet{
            akamuraNameLabel.textColor = UIColor.black
            akamuraNameLabel.font = UIFont(name: "KFhimaji", size: 21)
            akamuraNameLabel.text = "赤村の天気"
            akamuraNameLabel.adjustsFontSizeToFitWidth = true
            akamuraNameLabel.minimumScaleFactor = 0.3
        }
    }
    
    @IBOutlet weak var temperatureAverageLabel: UILabel!{
        didSet{
            temperatureAverageLabel.textColor = UIColor.black
            temperatureAverageLabel.font = UIFont(name: "KFhimaji", size: 20)
            temperatureAverageLabel.adjustsFontSizeToFitWidth = true
            temperatureAverageLabel.minimumScaleFactor = 0.3
        }
    }
    
    @IBOutlet weak var tempratureMaxValueLabel: UILabel!{
        didSet{
            tempratureMaxValueLabel.textColor = UIColor.red
            tempratureMaxValueLabel.font = UIFont(name: "KFhimaji", size: 20)
            tempratureMaxValueLabel.adjustsFontSizeToFitWidth = true
            tempratureMaxValueLabel.minimumScaleFactor = 0.3
        }
    }
    
    @IBOutlet weak var temperatureMiniLabel: UILabel!{
        didSet{
            temperatureMiniLabel.textColor = UIColor.blue
            temperatureMiniLabel.font = UIFont(name: "KFhimaji", size: 20)
            temperatureMiniLabel.adjustsFontSizeToFitWidth = true
            temperatureMiniLabel.minimumScaleFactor = 0.3
        }
    }
    @IBOutlet weak var weatherIconButton: UIButton!
    
    @IBAction func EventAction(_ sender: UIButton) {
        
        if UIApplication.shared.canOpenURL(eventUrl){
            UIApplication.shared.open(eventUrl)
        }
        
    }
    
    @IBOutlet weak var covid19Button: UIButton!
    
    
}
