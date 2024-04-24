//
//  Co2DetailViewController.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/11/12.
//

import UIKit
import Charts

class Co2DetailViewController: UIViewController {
    
    struct Co2Content: Codable {
        var id: String
        var co2: String?
        var temperature: String?
        var humidity: String?
        var pressure: String?
        var build: String?
        var systemVersion: String?
        var deviceId: String?
        var ssid: String?
        var location: String?
        var iPhone: String?
        var lowPower: String?
        var autoCalibration: String?
        var wifiEnd: String?
        var modified: String?
        var created: String?
    }
    var co2Contents = [Co2Content]()
    
    // 受信するデータを選択するために，ローカルデータを使用
    // ロケージョンは，indexで選択
    struct Co2LocationContent : Codable {
        var location : String
    }
    var co2LocationContents = [Co2LocationContent]()
    
    enum Constant {
        static let co2Url = "http://133.17.165.154:8086/co2/dbreadlocation.php"
        static let co2Color = UIColor(named: "Co2TitleColor")
    }
    
    @IBOutlet weak var chartFrameView: UIView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = location
        }
    }
    @IBOutlet weak var co2TitleLabel: UILabel! {
        didSet{
            co2TitleLabel.textColor = UIColor(named: "Co2TitleColor")
        }}
    @IBOutlet weak var temperatureTitleLabel: UILabel!
    @IBOutlet weak var humidityTitleLabel: UILabel!
    @IBOutlet weak var pressureTitleLabel: UILabel!
    
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var functionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    
    @IBOutlet weak var hourTextField: UITextField! {
        didSet {
            hourTextField.borderStyle = .none
            hourTextField.backgroundColor = .none
            hourTextField.isEnabled = false
        }}
    @IBOutlet weak var minuteTextField: UITextField! {
        didSet {
            minuteTextField.borderStyle = .none
            minuteTextField.backgroundColor = .clear
            minuteTextField.isEnabled = false
        }}
    @IBOutlet weak var secondTextField: UITextField! {
        didSet {
            secondTextField.borderStyle = .none
            secondTextField.backgroundColor = .systemBackground
            secondTextField.isEnabled = false
        }}
    
    @IBOutlet weak var watchImageView: UIImageView! {
        didSet {
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                watchImageView.isHidden = true
            }
        }}
    
    var chartView: LineChartView!
    var chartDataSet: LineChartDataSet!
    
    // 値渡し
    var index: Int = 0
    
    // ローカルデータから入力される
    var location: String = ""
    var maximumIndex: Int = 0
    
    var period = 3 // default 3時間

    enum category {
        case co2
        case temperature
        case humidity
        case pressure
    }
    var chartCategory: category = .co2 // Defaultは，co2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面向きを左横画面でセットする
        UIDevice.current.setValue(3, forKey: "orientation")
        
        loadUserDefaultsContents()
        loadAsyncContents()
        startTimer()
        startWatchTimer()
        addOrientationDidChange()
//        setupInformationViewSwipe()
        setupChartFrameViewSwipe()
        
        print("index: \(index)")
        print("maximumIndex: \(maximumIndex)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
        stopWatchTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeOrientationDidChange()
    }
    
    // ネットに未接続の時，ローカルから読み込む
    private func loadUserDefaultsContents() {

            do{
                self.co2LocationContents = try JSONDecoder().decode([Co2LocationContent].self, from: (UserDefaults.standard.object(forKey: "co2Contents") as? Data)!)
            } catch {
                print("Error: JSONDecoder()")
                return
            }
        location = co2LocationContents[index].location
        maximumIndex = co2LocationContents.count - 1
    }
    
    private func setupChartFrameViewSwipe() {
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(chartFrameViewSwipe(_:)))
        rightSwipe.direction = .right
        categoryButton.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(chartFrameViewSwipe(_:)))
        leftSwipe.direction = .left
        categoryButton.addGestureRecognizer(leftSwipe)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(chartFrameViewSwipe(_:)))
        upSwipe.direction = .up
        categoryButton.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(chartFrameViewSwipe(_:)))
        downSwipe.direction = .down
        categoryButton.addGestureRecognizer(downSwipe)
    }
    
    @objc
    func chartFrameViewSwipe(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .right:
            print("swiped right")
            
            // 最長１週間
            if period >= 24 * 7 {
                period = 24 * 7
            } else if period >= 24 {
                period = 24 * 7
            } else if period < 6 {
                period += 1
            } else {
                period += 3
            }
            
        case .left:
            print("swiped left")
            
            // 最短１時間
            if period <= 1 {
                period = 1
            } else if period <= 6 {
                period -= 1
            } else if period >= 24 * 7 {
                period = 24
            } else {
                period -= 3
            }
            
        case .up:
            print("swiped up")
            
            co2TitleLabel.textColor = .none
            temperatureTitleLabel.textColor = .none
            humidityTitleLabel.textColor = .none
            pressureTitleLabel.textColor = .none
            
            switch chartCategory {
                
            case .co2:
                chartCategory = .temperature
                temperatureTitleLabel.textColor = Constant.co2Color
                
            case .temperature:
                chartCategory = .humidity
                humidityTitleLabel.textColor = Constant.co2Color
                
            case .humidity:
                chartCategory = .pressure
                pressureTitleLabel.textColor = Constant.co2Color
                
            case .pressure:
                chartCategory = .co2
                co2TitleLabel.textColor = Constant.co2Color
            }
            
        case .down:
            print("swiped down")
            
            co2TitleLabel.textColor = .none
            temperatureTitleLabel.textColor = .none
            humidityTitleLabel.textColor = .none
            pressureTitleLabel.textColor = .none
            
            switch chartCategory {
                
            case .humidity:
                chartCategory = .temperature
                temperatureTitleLabel.textColor = Constant.co2Color
                
            case .pressure:
                chartCategory = .humidity
                humidityTitleLabel.textColor = Constant.co2Color
                
            case .co2:
                chartCategory = .pressure
                pressureTitleLabel.textColor = Constant.co2Color
                
            case .temperature:
                chartCategory = .co2
                co2TitleLabel.textColor = Constant.co2Color
            }
            
        default: break
        }
        
        loadAsyncContents()
    }
    
    private func setupInformationViewSwipe() {
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(informationViewSwipe(_:)))
        rightSwipe.direction = .right
        informationView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(informationViewSwipe(_:)))
        leftSwipe.direction = .left
        informationView.addGestureRecognizer(leftSwipe)
    }
    
    @objc
    func informationViewSwipe(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case .right: print("swiped right")
            if index <= 0 { index = maximumIndex }
            else { index -= 1 }

        case .left: print("swiped left")
            if index >= maximumIndex { index = 0 }
            else { index += 1 }
            
        default: break
        }
        
        location = co2LocationContents[index].location
        loadAsyncContents()
    }
    
    @objc
    func timerAction() {
        
        loadAsyncContents()
    }
    
    var timer: Timer?
    private func startTimer() {
        
        if timer == nil {
                        
            timer =  Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    private func stopTimer() {
        
        timer?.invalidate()
        timer = nil
    }
    
    private func loadAsyncContents(){
        print("loadAsyncContents()")
        
        print("location: \(location)")
        print("period: \(period)")
        
        let locationEncodeString: String = location.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "None"
        var request = URLRequest(url: URL(string: "\(Constant.co2Url)?location=\(locationEncodeString)&period=\(period)")!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            do {
                // データが読み込まれなかった時
                guard let data = data else { return }
                
                self.co2Contents = try JSONDecoder().decode([Co2Content].self, from: data)
                
                var chartContents = [Int]()
                
                for i in 0 ..< self.co2Contents.count {
                    
                    switch self.chartCategory {
                        
                    case .temperature: chartContents += [Int(roundf(Float(self.co2Contents[i].temperature ?? "20.0") ?? 20.0))]
                    case .humidity: chartContents += [Int(roundf(Float(self.co2Contents[i].humidity ?? "50.0") ?? 50.0))]
                    case .pressure: chartContents += [Int(roundf(Float(self.co2Contents[i].pressure ?? "1000.0") ?? 1000.0))]
                    default: chartContents += [Int(self.co2Contents[i].co2 ?? "400") ?? 400]
                        
                    }
                }
                
                var chartTimeContents = [String]()
                chartTimeContents = [String](repeating: "", count: self.co2Contents.count)
                
                if self.co2Contents.count > 0 {
                    
                    guard let firstDateTime = self.co2Contents[0].created else { return }
                    guard let middleDateTime = self.co2Contents[self.co2Contents.count / 2].created else { return }
                    guard let nowDateTime = self.co2Contents[self.co2Contents.count - 1].created else { return }
                    
                    chartTimeContents[0] = "\(self.timeFromString(firstDateTime))"
                    chartTimeContents[self.co2Contents.count / 2] = "\(self.timeFromString(middleDateTime))"
                    chartTimeContents[self.co2Contents.count - 1] = "\(self.timeFromString(nowDateTime))"
                    
                    DispatchQueue.main.async() {
                        
                        self.showInformation()
                        self.displayChart(chartContents, chartTimeContents)
                    }
                    
                }
            } catch {
                print("catch: Error")
            }
        })
            .resume()
    }
    
    private func showInformation() {
        
        if co2Contents.count > 0 {
            
            titleLabel.text = location
            
            imageView.image = UIImage(named: co2ImageViewName( Int(co2Contents[co2Contents.count - 1].co2 ?? "400") ?? 400 ))
            
            co2Label.text = "\(co2Contents[co2Contents.count - 1].co2 ?? "450") [ppm]"
            temperatureLabel.text = "\(co2Contents[co2Contents.count - 1].temperature ?? "20") [℃]"
            humidityLabel.text = "\(co2Contents[co2Contents.count - 1].humidity ?? "50") [％]"
            pressureLabel.text = "\(co2Contents[co2Contents.count - 1].pressure ?? "1000") [hPa]"
            dateLabel.text = co2Contents[co2Contents.count - 1].created
            
            guard let systemVersion: String = co2Contents[co2Contents.count - 1].systemVersion else { return }
            guard let build: String = co2Contents[co2Contents.count - 1].build else { return }
            
            versionLabel.text = "Version \(systemVersion) (\(build))"
            
            functionLabel.text = {
                
                var text: String = ""
                if co2Contents[co2Contents.count - 1].autoCalibration ?? "0" == "1"
                    || (Int(build) ?? 17)  < 17 { text += " 自動調整"}
                if co2Contents[co2Contents.count - 1].autoCalibration ?? "0" == "2" { text += "手動調整"}
                if co2Contents[co2Contents.count - 1].lowPower ?? "0" == "1" { text += " 省電力"}
                if co2Contents[co2Contents.count - 1].iPhone ?? "0" == "1" { text += " テザリング"}
                return text
            }()
        }
    }

    func co2ImageViewName(_ count: Int) -> String {
        
        var imageName: String
        
        switch (count) {
        case 0...767: imageName = "Alert1"
        case 768...1023: imageName = "Alert2"
        case 1024...2047: imageName = "Alert3"
        default: imageName = "Alert4"
        }
        
        return imageName
    }
    
    private func timeFromString (_ dateString: String) -> String {
        
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let date = dateFormatter.date(from: dateString)
        
        // フォーマット設定
        dateFormatter.dateFormat = "HH:mm:ss"
        // カレンダー設定（西暦固定）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        // ロケール設定（日本語・日本国固定）
        dateFormatter.locale = Locale(identifier: "ja_JP")
        // タイムゾーン設定（日本標準時固定）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let date = date else { return "" }
        
        return dateFormatter.string(from: date)
    }

    
    func displayChart(_ contents: [Int], _ timeContents: [String]) {

        if chartView != nil { chartView.removeFromSuperview() }
        
        // グラフの範囲を指定する
        chartView = LineChartView(frame: CGRect(x: 0, y: 0, width: chartFrameView.frame.width, height: chartFrameView.frame.height))
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()
        
        for (xValue, yValue) in contents.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: Double(yValue))
            dataEntries.append(dataEntry)
        }
        // グラフにデータを適用
        chartDataSet = LineChartDataSet(entries: dataEntries, label: "My data") // My data?
        
        chartDataSet.lineWidth = 5.0 // グラフの線の太さを変更
        chartDataSet.mode = .cubicBezier // 滑らかなグラフの曲線にする
        chartDataSet.drawFilledEnabled = true // グラフの下塗りつぶし
        
        // 表示期間でグラフの点を制御
        if period > 3 { chartDataSet.drawCirclesEnabled = false }
        else { chartDataSet.drawCirclesEnabled = true }
        
        if chartCategory == .co2 {
            if contents.count > 0 {
                switch contents[contents.count - 1] {
                case 0...767:  chartDataSet.fillColor = .cyan
                case 768...1023: chartDataSet.fillColor = .green
                case 1024...2047: chartDataSet.fillColor = .red
                default: chartDataSet.fillColor = .purple
                }
            }
        } else {
            chartDataSet.fillColor = .cyan
        }
        
        if period == 1 { chartDataSet.drawValuesEnabled = true }
        else { chartDataSet.drawValuesEnabled = false }
        
        // データをチャートにセット
        chartView.data = LineChartData(dataSet: chartDataSet)
        
        // X軸(xAxis)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeContents)
        //labelCountはChartDataEntryと同じ数だけ入れます。
        chartView.xAxis.labelCount = timeContents.count
        print("timeContents.count: \(timeContents.count)")
        //granularityは1.0で固定
        chartView.xAxis.granularity = 1.0
        chartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        // x軸の縦線を表示しない
        chartView.xAxis.drawGridLinesEnabled = false

        var minimumValue: Int = contents.min() ?? 400
        let maximumValue: Int = contents.max() ?? 1000
        print("minimumValue: \(minimumValue)")
        print("maximumValue: \(maximumValue)")
        print("chartCategory: \(chartCategory)")
        
        // Y軸(leftAxis/rightAxis)
        var referenceValue: Int!
        if chartCategory == .co2 { referenceValue = 100 }
        else { referenceValue = 10 }
        minimumValue -= referenceValue / 2
        chartView.leftAxis.axisMaximum = Double(maximumValue + (referenceValue - maximumValue % referenceValue)) //y左軸最大値
        chartView.leftAxis.axisMinimum = Double(minimumValue - minimumValue % referenceValue) //y左軸最小値
        chartView.leftAxis.labelCount = 6 // y軸ラベルの数
        chartView.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
        
        // その他の変更
        chartView.highlightPerTapEnabled = false // プロットをタップして選択不可
        chartView.legend.enabled = false // グラフ名（凡例）を非表示
        chartView.pinchZoomEnabled = false // ピンチズーム不可
        chartView.doubleTapToZoomEnabled = false // ダブルタップズーム不可
        chartView.extraTopOffset = 20 // 上から20pxオフセットすることで上の方にある値(99.0)を表示する
        chartView.extraRightOffset = 24 // 右に余白(時間表示のため)
        
        chartView.animate(xAxisDuration: 2) // 2秒かけて左から右にグラフをアニメーションで表示する
        
        chartFrameView.addSubview(chartView)
    }

    @objc
    func orientationDidChange(_ notification: NSNotification) {
        
        if UIDevice.current.orientation.isLandscape {
            // 横向きの場合
            hourTextField.font = UIFont.boldSystemFont(ofSize: 80)
            minuteTextField.font = UIFont.boldSystemFont(ofSize: 80)
            secondTextField.font = UIFont.boldSystemFont(ofSize: 48)
            secondTextField.contentVerticalAlignment = .bottom
            watchImageView.isHidden = false
            dismissButton.isHidden = false
            
        } else if UIDevice.current.orientation.isPortrait{
            // 縦向きの場合
            hourTextField.font = UIFont.boldSystemFont(ofSize: 64)
            minuteTextField.font = UIFont.boldSystemFont(ofSize: 64)
            secondTextField.font = UIFont.boldSystemFont(ofSize: 32)
            secondTextField.contentVerticalAlignment = .center
            watchImageView.isHidden = true
            dismissButton.isHidden = true
            
        } else {
            // フラットの場合
        }
        
        loadAsyncContents()
    }
    
    private func addOrientationDidChange() {
        // 端末回転の通知機能を設定します。
        let action = #selector(orientationDidChange(_:))
        let center = NotificationCenter.default
        let name = UIDevice.orientationDidChangeNotification
        center.addObserver(self, selector: action, name: name, object: nil)
    }
    
    private func removeOrientationDidChange() {
        // 端末回転の通知機能の設定を解除します。
        let center = NotificationCenter.default
        let name = UIDevice.orientationDidChangeNotification
        center.removeObserver(self, name: name, object: nil)
    }
    
    var watchTimer: Timer?
    func startWatchTimer() {
        
        if watchTimer == nil {
            
            watchTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(watchAction), userInfo: nil, repeats: true)
        }
    }
    
    func stopWatchTimer() {
        
        watchTimer?.invalidate()
        watchTimer = nil
    }
    
    @objc
    func watchAction() {
        
        let date = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let hour = Int(calendar?.component(.hour, from: date as Date) ?? 12)
        let minute = Int(calendar?.component(.minute, from: date as Date) ?? 0)
        let second = Int(calendar?.component(.second, from: date as Date) ?? 0)
        hourTextField.text = String(format: "%02d", hour)
        minuteTextField.text = String(format: "%02d", minute)
        secondTextField.text = String(format: "%02d", second)

        switch hour {
        case 4...10:
            if watchImageView.image != UIImage(named: "sun.and.horizon.fill") {
                watchImageView.image = UIImage(named: "sun.and.horizon.fill")
                watchImageView.tintColor = .orange
            }
        case 11...17:
            if watchImageView.image != UIImage(named: "sun.max.fill") {
                watchImageView.image = UIImage(named: "sun.max.fill")
                watchImageView.tintColor = .orange
            }
        case 0...3:
            if watchImageView.image != UIImage(named: "moon.zzz.fill") {
                watchImageView.image = UIImage(named: "moon.zzz.fill")
                watchImageView.tintColor = .blue
            }
        default:
            if watchImageView.image != UIImage(named: "moon.fill") {
                watchImageView.image = UIImage(named: "moon.fill")
                watchImageView.tintColor = .blue
            }
        }
    }
    
    @IBAction func periodButton(_ sender: UIButton) {
        
        if period >= 24 {
            period = 1
        } else if period < 6 {
            period += 1
        } else {
            period += 3
        }
        
        loadAsyncContents()
    }
    
    @IBAction func categoryButton(_ sender: UIButton) {
        
//        switch chartCategory {
//        case .co2:
//            chartCategory = .temperature
//        case .temperature:
//            chartCategory = .humidity
//        case .humidity:
//            chartCategory = .pressure
//        case .pressure:
//            chartCategory = .co2
//        }
//
//        loadAsyncContents()
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        //画面向きを縦画面でセットする
        UIDevice.current.setValue(1, forKey: "orientation")
        dismiss(animated: true, completion: nil)
    }
    
}
