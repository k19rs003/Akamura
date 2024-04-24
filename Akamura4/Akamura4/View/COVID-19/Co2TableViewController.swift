//
//  Co2TableViewController.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/11/11.
//

import UIKit

class Co2TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct Co2Content : Codable {
        var id: String?
        var co2: String?
        var temperature: String?
        var humidity: String?
        var pressure: String?
        var build: String?
        var systemVersion: String?
        var deviceId: String?
        var ssid: String?
        var location: String?
        var flag: String?
        var modified: String?
        var created: String?
    }
    
    var co2Contents = [Co2Content](){
        didSet{
            navigationItem.searchController?.searchBar.isHidden = false
            self.tableView.reloadData()
            print("self.tableView.reloadData()")
            notificationButton.isHidden = false
        }
    }
    
    @IBOutlet weak var notificationButton: UIButton! {
        didSet {
            notificationButton.isHidden = true
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            // セルをスワイプしたら，キーボードが隠れる
            tableView.keyboardDismissMode = .onDrag
            
            // カスタムセルの登録
            tableView.register(UINib(nibName: "Co2TableViewCell", bundle: nil), forCellReuseIdentifier: "co2Cell")
        }
    }
    
    enum Constant {
        static let defaultContents: String = "[{\"id\":\"\",\"title\":\"'通信エラーです．ネットワークをチェックしてください．'\",\"url\":\"https://www.kyusan-u.ac.jp\",\"source\":\"0\",\"date\":\"\",\"modified\":\"\",\"created\":\"\"}]"
        //        static let heightForRow: CGFloat = UITableView.automaticDimension    // セルの高さを128にする
        static let heightForRow: CGFloat = 136.0    // セルの高さを136にする
        
        static let co2Url = "http://133.17.165.154:8086/co2/dbread.php"
        static let co2PlaceholderMessage = "検索（例：教室，ICT）"
        static let co2Title = "CO2 Monitor（実験中）"
    }
    
    let activityIndicatorView = UIView()
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "CO2モニター"
        
        UserDefaults.standard.register(defaults: ["co2Contents":Constant.defaultContents.data(using: .utf8)!])
//        self.navigationController?.navigationBar.tintColor = UIColor(named: "TintColor")
        self.tabBarController?.tabBar.tintColor = UIColor(named: "TintColor")
        
        setupSearchController()
        setActivityIndicatorView()
        loadAsyncContents()
        refresh()
    }
    
    private func setupSearchController() {
        
        let searchController: UISearchController = {
            
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = Constant.co2PlaceholderMessage
            
            return searchController
            
        }()
        
        navigationItem.searchController = searchController
        // フォントの設定は後でしないと，上書きされる？
        navigationItem.searchController?.searchBar.searchTextField.font = UIFont(name: "HelveticaNeue",size: navigationItem.searchController?.searchBar.searchTextField.font?.pointSize ?? 14)
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .white
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func loadAsyncContents(){
        print("loadAsyncContents()")
        
        
        self.tableView.allowsSelection = false
        var request = URLRequest(url: URL(string: "\(Constant.co2Url)")!)
        request.httpMethod = "POST"
        //            request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            do {
                // データが読み込まれなかった時
                guard let data = data else {
                    DispatchQueue.main.async() {
                        self.loadUserDefaultsContents()
                    }
                    return
                }
                // データが読み込まれた時は，dataをローカルに保存しておく
                UserDefaults.standard.set(data, forKey:"co2Contents")
                // データが読み込まれた時は，dataをローカルに保存しておく
                let contents = try JSONDecoder().decode([Co2Content].self, from: data)
                //                self.isConnected = true
                DispatchQueue.main.async() {
                    self.co2Contents = contents
                    //                        self.goNewsWebViewControllerSegue()
                    self.tableView.allowsSelection = true
                }
            } catch {
                DispatchQueue.main.async() {
                    self.loadUserDefaultsContents()
                }
            }
        })
            .resume()
    }
    
    // ネットに未接続の時，ローカルから読み込む
    private func loadUserDefaultsContents(){
        
        //        self.isConnected = false
        self.tableView.allowsSelection = true
        
        do{
            self.co2Contents = try JSONDecoder().decode([Co2Content].self, from: (UserDefaults.standard.object(forKey: "co2Contents") as? Data)!)
        } catch {
            print("Error: JSONDecoder()")
            return
        }
    }
    
    private func refresh(){
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(Co2TableViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        tableView.addSubview(refreshControl)
    }
    
    @objc
    func refreshControlValueChanged(sender: UIRefreshControl) {
        
        loadAsyncContents()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            sender.endRefreshing()
        })
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return co2Contents.count
        return co2Contents.count == 0 ? 0 : co2Contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "co2Cell") as? Co2TableViewCell {
            
            // セルを押したときに，色を変えない
            cell.selectedBackgroundView = {
                let view = UIView()
                view.backgroundColor = .clear
                return view
            }()
            
            if let title = co2Contents[indexPath.row].location {
                cell.titleLabel.text = title
            }

            if let co2 = co2Contents[indexPath.row].co2 {
                cell.co2Label.text = "\(co2) [ppm]"
                cell.co2ImageView.image = UIImage(named: self.co2ImageViewName(Int(co2)!))
            }

            if let temperature = co2Contents[indexPath.row].temperature {
                cell.temperatureLabel.text = "\(temperature) [℃]"
            }

            if let humidity = co2Contents[indexPath.row].humidity {
                cell.humidityLabel.text = "\(humidity) [％]"
            }

            if let pressure = co2Contents[indexPath.row].pressure {
                cell.pressureLabel.text = "\(pressure) [hPa]"
            }

            if let modified = co2Contents[indexPath.row].modified {
                cell.dateLabel.text = modified
            }

            if let systemVersion = co2Contents[indexPath.row].systemVersion,
               let build = co2Contents[indexPath.row].build {
                cell.versionLabel.text = "Version \(systemVersion) (\(build))"
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Co2Detail", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "co2DetailViewController") as! Co2DetailViewController
        nextViewController.index = indexPath.row
        
        //遷移を実行
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    //セルの高さをheightForRowにする
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 100.0
        return Constant.heightForRow
    }
    
    private func setActivityIndicatorView(){
        // あっとるんかいな？
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 128
        let height: CGFloat = 32
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        activityIndicatorView.frame = CGRect(x: x, y: y, width: width, height: height)
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
    
    
    @IBAction func notificationButton(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Co2Notification", bundle: nil)
        let co2NotificationViewController = storyboard.instantiateViewController(withIdentifier: "co2NotificationViewController") as! Co2NotificationViewController
        
        for i in 0 ..< co2Contents.count {
            
            co2NotificationViewController.locations.append(self.co2Contents[i].location)
        }
        //遷移を実行
        self.present(co2NotificationViewController, animated: true, completion: nil)
        
    }
}

// MARK: - UISearchResultsUpdating
extension Co2TableViewController: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // K'sLifeの検索に対応
        let text = searchController.searchBar.text?.replacingOccurrences(of: "\'", with: "\\\'") ?? ""
        print (text)
        loadUserDefaultsContents() // Searchの時は，ローカルデータを使用
        
        
        if !text.isEmpty {
            co2Contents = co2Contents.filter {
                $0.location!.contains(text)                             // ロケーションのフィルタリング
            }
        }
    }
}
