//
//  FacilityViewController.swift
//  PBL_abe
//
//  Created by Abe on R 3/09/29.
//

import UIKit
import SafariServices

struct Content : Codable {
    
    struct Contents : Codable {
        var title : String
        var subTitle : String
        var picture : String
        var site : String
        var contact : String
    }
    
    var header : String
    var isShown : Bool
    var address : String
    var phoneNumber : String
    var mainSite : String
    var facebook : String
    var contents : [Contents]
}


class FacilityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genjiImageView: UIImageView!
    
    var facilitycontents = [Content]()
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(genjiImageView)
        loadJson()
        self.navigationItem.title = "施設紹介"
    }
    
    private func loadJson() {
        // パスの取得
        guard let url = Bundle.main.url(forResource: "Facilities", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        self.facilitycontents = try! JSONDecoder().decode([Content].self, from: data)
        print("facilitycontents \(facilitycontents.count)")
    }
}

extension FacilityViewController: UITableViewDataSource {
    
    // 各セクションの中のcellの数をここでセット
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 三項演算子
        return facilitycontents[section].isShown ? facilitycontents[section].contents.count : 0
        
        //　下のこと
//        if listArray[section].isShown {
//            return listArray[section].facilitiesArray.count
//        } else {
//            return 0
//        }
    }
    
    // cellの中に何が入るのか
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "facilityCell", for: indexPath)

        tableView.register(UINib(nibName: "FacilitiesCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FacilitiesCell {
            
            cell.titleLabel?.text = (facilitycontents[indexPath.section].contents[indexPath.row].title)
            cell.subTitleLabel?.text = (facilitycontents[indexPath.section].contents[indexPath.row].subTitle)
            cell.facilityImage?.image = UIImage(named: (facilitycontents[indexPath.section].contents[indexPath.row].picture))
            
            if facilitycontents[indexPath.section].contents[indexPath.row].site.isEmpty == true {
                cell.siteButton?.isHidden = true
            } else {
                cell.siteButton?.isHidden = false
            }
            if facilitycontents[indexPath.section].contents[indexPath.row].contact.isEmpty == true {
                cell.contactButton?.isHidden = true
            } else {
                cell.contactButton?.isHidden = false
            }
            
            cell.siteButton.tag = indexPath.section*16+indexPath.row
            cell.contactButton.tag = indexPath.section
            cell.siteButton.addTarget(self, action: #selector(self.siteButtonTapped(_:)), for: .touchUpInside)
            cell.contactButton.addTarget(self, action: #selector(self.contactButtonTapped(_:)), for: .touchUpInside)
        
            return cell
        }
        
        return UITableViewCell()
    }
    
    @objc private func siteButtonTapped(_ sender: UIButton) {
        
        print("section\(sender.tag / 16),row\(sender.tag % 16)")
        
//        // 画面遷移
//        let storyboard: UIStoryboard = UIStoryboard(name: "Facility", bundle: nil)
//        let nextViewController = storyboard.instantiateViewController(withIdentifier: "webView") as! WebViewController//遷移先のViewControllerを設定
//        nextViewController.url = (facilitycontents[sender.tag / 16].contents[sender.tag % 16].site)
//        self.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
        
        if let url = URL(string: (facilitycontents[sender.tag / 16].contents[sender.tag % 16].site)) {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            }
    }
    
    @objc private func contactButtonTapped(_ sender: UIButton) {
        // 画面遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "Facility", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "contactView") as! ContactViewController//遷移先のViewControllerを設定
        
        nextViewController.header = facilitycontents[sender.tag].header
        nextViewController.address = facilitycontents[sender.tag].address
        nextViewController.phoneNumber = facilitycontents[sender.tag].phoneNumber
        nextViewController.siteUrl = facilitycontents[sender.tag].mainSite
        nextViewController.facebook = facilitycontents[sender.tag].facebook
        
        self.navigationController?.pushViewController(nextViewController, animated: true)//遷移する
    }
    
    
    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return facilitycontents.count
    }
    
    
//    // セクションのタイトルにセット
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return listArray[section].facilitiesName
//    }
}

extension FacilityViewController: UITableViewDelegate {
    
    // HeaderのViewに対して，タップを感知できるように
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let headerView = UITableViewHeaderFooterView()
        // UITapGestureを定義　Tapされた際にheadertappedを呼ぶ
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(headertapped(sender:)))
      // headerViewをセット
//        headerView.addGestureRecognizer(gesture)
//        headerView.tag = section
//      return headerView

        tableView.register(UINib(nibName: String(describing: FacilityHeaderCell.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: FacilityHeaderCell.self))
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FacilityHeaderCell")
        if let headerView = view as? FacilityHeaderCell {
            headerView.setup(title: facilitycontents[section].header, openClose: facilitycontents[section].isShown)
        }
        // UITapGestureを定義　Tapされた際にheadertappedを呼ぶ
        let gesture = UITapGestureRecognizer(target: self, action: #selector(headertapped(sender:)))
        
        view?.addGestureRecognizer(gesture)
        view?.tag = section
        
        return view
    }
    
    @objc func headertapped(sender: UITapGestureRecognizer) {
        print("tapped!")

        guard let section = sender.view?.tag else { return }

        // isShownの値を反転
        facilitycontents[section].isShown.toggle()
        
        if facilitycontents.allSatisfy ({ $0.isShown == false}) {
            self.view.bringSubviewToFront(genjiImageView)
        } else {
            self.view.sendSubviewToBack(genjiImageView)
        }
        
        // 表示，非表示の切り替えs
        tableView.beginUpdates()
        tableView.reloadSections([section], with: .automatic)  // そのセクションのみリロード
        tableView.endUpdates()
    }
    
}
    
