//
//  TopViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/10/18.
//

import UIKit
import CoreData
import SafariServices

final class TopTableViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(UINib(nibName: "MainContentsCell", bundle: nil), forCellReuseIdentifier: "topCell")
            tableView.register(UINib(nibName: "EventsCell", bundle: nil), forCellReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var topView: UIView! {
        didSet {
            topView.backgroundColor = .ThemeColor
        }
    }
    @IBOutlet weak var reviewButton: UIBarButtonItem!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    let eventUrl = "http://133.17.165.154:8086/akamura4/Event.json"

    let current = Calendar.current
    var eventContents = [Events]() {
        didSet {
            tableView.reloadData()
        }
    }
    var startTime = Date()

    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 63, height: 63))
        let image = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))

        button.layer.cornerRadius = 30
        button.backgroundColor = .systemGray
        button.setImage(image, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)

        return button
    }()

    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        eventLoadJson()
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {

            let storyboard = UIStoryboard(name: "FirstLaunch", bundle: nil)
            let firstLaunchViewController = storyboard.instantiateViewController(withIdentifier: "firstLaunch") as! FirstLaunchViewController
            self.present(firstLaunchViewController, animated: true, completion: nil)
        }

        // アプリ起動時・フォアグラウンド復帰時の通知を設定する
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TopTableViewController.onDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        settingJustAfterUpdating()
//        settingImage()
        self.navigationItem.title = "Akamura"//ナビゲーションの名前

        view.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        floatingButton.isHidden = true
        //getImage()
    }

    private func settingJustAfterUpdating() {
        guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") else { return }

        let newBuildKey = "Build\(build as! String)"

        let visit = UserDefaults.standard.bool(forKey: newBuildKey)
        if !visit {
            UserDefaults.standard.set(true, forKey: newBuildKey)
        }
    }

    @objc func onDidBecomeActive(_ notification: Notification?) {
        // ココに処理
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                // 0.2秒後に実行したい処理
                let storyboard: UIStoryboard = UIStoryboard(name: "Review", bundle: nil)//遷移先のStoryboardを設定
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "ReviewStoryboardId") as! ReviewListViewController//遷移先のViewControllerを設定

                self?.navigationController?.pushViewController(nextViewController, animated: true) //遷移する
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        floatingButton.frame = CGRect(
            x: self.view.frame.size.width - 70,
            y: self.view.frame.size.height - 100,
            width: 60,
            height: 60)
    }

    @objc private func didTapButton() {
        print("Floating Button")
        let bottomOffset = CGPoint(x: 0, y: 0)
        self.tableView.setContentOffset(bottomOffset, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        floatingButton.isHidden = false
        if tableView.contentOffset.y <= 0.5 {
            floatingButton.isHidden = true
        }

        if tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging {
//            print("一番下に来た時の処理")
            floatingButton.backgroundColor = .clear
            floatingButton.layer.borderWidth = 0.0
            floatingButton.layer.borderColor = UIColor.clear.cgColor
            floatingButton.tintColor = .clear
            floatingButton.isEnabled = false
        } else if tableView.contentOffset.y + tableView.frame.size.height  < tableView.contentSize.height - tableView.frame.size.height/3 && tableView.isDragging {
            floatingButton.tintColor = .white
            floatingButton.backgroundColor = .systemGray
            floatingButton.layer.borderWidth = 0.0
            floatingButton.isEnabled = true
        }
    }

    private func eventLoadJson() {
        Task {
            do {
                let events = try await AkamuraAPIService.shared.request(with: eventUrl, responseArrayType: Events.self)
//                Task { @MainActor in
                    self.eventContents = events
//                }
                if !eventContents.isEmpty {
                    let month = current.component(.month, from: Date())
                    var numberOfRotations = 0
                    
                    if month >= 3, month <= 5 { // 春
                        numberOfRotations = 0
                    } else if month >= 6, month <= 8 { // 夏
                        numberOfRotations = 1
                    } else if month >= 9, month <= 11 { // 秋
                        numberOfRotations = 2
                    } else { // 冬
                        numberOfRotations = 3
                        
                    }
                    
                    if numberOfRotations > 0 {
                        for _ in 0 ..< numberOfRotations {
                            let removed = eventContents.remove(at: 1)
//                            Task { @MainActor in
                                eventContents.append(removed)
//                            }
                        }
                        //                    print(self.eventContents)
                    }
                    // 修正:順番を決めてから一番をtrueにする
                    if eventContents.count > 1 {
//                        Task { @MainActor in
                            eventContents[1].isShown = true
                            eventContents[2].isShown = true
                            eventContents[3].isShown = true
                            eventContents[4].isShown = true
//                        }
                    }
                }
            } catch {
                present(.makeNetworkAlert(title: "ネットワークエラー", message: "インターネットに接続して\nもう一度アプリを起動してください"))
            }
        }
    }

    @IBAction func SettingAction(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SettingStoryboardId") as! SettingViewController

        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @IBAction func ReviewAction(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Review", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "ReviewStoryboardId") as! ReviewListViewController

        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    // リフレッシュ機能
    @objc private func handleRefreshControl() {
        eventLoadJson()
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - UITableViewDataSource
extension TopTableViewController: UITableViewDataSource {
    // 各セクションの中のcellの数をここでセット
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !eventContents.isEmpty {
            return eventContents[section].isShown ? eventContents[section].contents.count : 0
        } else {
            return 1
        }
//        return eventContents.isEmpty ? 1 : eventContents[section].contents.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // cellの中に何が入るのか
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "topCell") as? MainContentsCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.facilitiesButton.addTarget(self, action: #selector(self.facilitiesButtonTapped(_:)), for: .touchUpInside)
            cell.weatherIconButton.addTarget(self, action: #selector(self.weatherIconButtonTapped(_:)), for: .touchUpInside)
//            cell.covid19Button.addTarget(self, action: #selector(self.covid19ButtonTapped(_:)), for: .touchUpInside)
            cell.touristMapButton.addTarget(self, action: #selector(self.touristMapButtonTapped(_:)), for: .touchUpInside)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? EventsCell else { return UITableViewCell() }
                cell.selectionStyle = .default
                cell.cellButton.tag = indexPath.section * 16 + indexPath.row
                cell.cellButton.addTarget(self, action: #selector(self.cellButtonTapped(_:)), for: .touchUpInside)
                cell.event = eventContents[indexPath.section].contents[indexPath.row]
                return cell
        }
    }

    @objc private func facilitiesButtonTapped(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Facility", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "facilityNavigationController") as? FacilityViewController else { return }

        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @objc private func weatherIconButtonTapped(_ sender: UIButton) {
//        let storyboard: UIStoryboard = UIStoryboard(name: "Weather", bundle: nil)
//        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "weatherViewController") as? WeatherViewController else { return }
//
//        self.navigationController?.pushViewController(nextViewController, animated: true)
        //Safariに遷移
        if let url = URL(string: "https://weather.yahoo.co.jp/weather/jp/40/8230/40609.html") {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            }
    }

//    @objc private func covid19ButtonTapped(_ sender: UIButton) {
//        let storyboard: UIStoryboard = UIStoryboard(name: "Co2TableView", bundle: nil)
//        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "Co2TableViewController") as? Co2TableViewController else { return }
//
//        self.navigationController?.pushViewController(nextViewController, animated: true)
//    }

    @objc private func touristMapButtonTapped(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Map", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "rightMenuNavigationController") as? MapViewController else { return }
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @objc private func cellButtonTapped(_ sender: UIButton) {
        print("section\(sender.tag / 16),row\(sender.tag % 16)")

        //let notContents:[String] = ["桃の開花","赤村体育大会","稲刈り","村民駅伝大会","除夜の鐘","赤村成人式","赤村消防団出初式","梅の開花"]

        let storyboard: UIStoryboard = UIStoryboard(name: "Event", bundle: nil)
        let eventsViewController = storyboard.instantiateViewController(withIdentifier: "eventStoryboardId") as! EventsViewController

        let sectionNumber = sender.tag / 16
        let rowNumber = sender.tag % 16

        eventsViewController.titleName = eventContents[sectionNumber].contents[rowNumber].title
        eventsViewController.detail = eventContents[sectionNumber].contents[rowNumber].detail
        eventsViewController.videoUrl = eventContents[sectionNumber].contents[rowNumber].video
        eventsViewController.month = eventContents[sectionNumber].contents[rowNumber].month
        eventsViewController.picture = eventContents[sectionNumber].contents[rowNumber].picture
        print("eventViewController: \(eventContents[sectionNumber].contents[rowNumber].picture)")

//        if eventsViewController.detail != "" {
            self.navigationController?.pushViewController(eventsViewController, animated: true)
//        }
    }

    //  MainContentsCellをタップ不可
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }

    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
//        return eventContents.isEmpty ? 0 : eventContents.count
        return eventContents.count
    }
}

// MARK: - UITableViewDelegate
extension TopTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard: UIStoryboard = UIStoryboard(name: "Event", bundle: nil)
        guard let eventsCellViewController = storyboard.instantiateViewController(withIdentifier: "eventStoryboardId") as? EventsViewController else { return }
        eventsCellViewController.events = eventContents[indexPath.row]
        self.navigationController?.pushViewController(eventsCellViewController, animated: true)
        print("プッシュ完了")
    }

    // HeaderのViewに対して，タップを感知できるように
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.register(UINib(nibName: String(describing: EventsHeaderCell.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: EventsHeaderCell.self))

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EventsHeaderCell")
        view?.backgroundColor = .systemBackground

        if let headerView = view as? EventsHeaderCell {
            headerView.setup(title: eventContents[section].header, openClose: eventContents[section].isShown)
        }
        // UITapGestureを定義　Tapされた際にheadertappedを呼ぶ
        let gesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(sender:)))

        view?.addGestureRecognizer(gesture)
        view?.tag = section

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15,*) {
            tableView.sectionHeaderTopPadding = 0.0
        }

        if section == 0 || section == 1 {
            return 0.0
        } else {
            return 48.0
        }
    }

    @objc func headerTapped(sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        // isShownの値を反転
        eventContents[section].isShown.toggle()

        // 表示，非表示の切り替えs
        tableView.beginUpdates()
        tableView.reloadSections([section], with: .fade)  // そのセクションのみリロード
        tableView.endUpdates()
    }
}
