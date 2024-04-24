//
//  MenuViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/10/17.
//

import UIKit
//import SideMenu

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 構造体
    struct PinDataTwo: Codable{
        var title: String //ピンの場所の名前
        var category: String
    }
    
    private var tableView = UITableView()
    let addViewController = MapViewController()

     var secondContents = [PinDataTwo]()
    
    var touristAreaContents:[String] = []
    var cafeteriaContents:[String] = []
    var schoolContents: [String] = []
    
    var titleArray:[String] = []
    //let practic:[String] = ["愛","勇気","正義","アンパンマン"]
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJson()
        
        
        
//        for j in 0..<secondContents.count{
//        for i in 0..<secondContents.count {
//            titleContents[i] = secondContents[j].title
//        }
//        }
        //print(addViewController.contents[0].title)
        
        
        
        
        
        let dic435Color = UIColor(hex: "707070")
        view.backgroundColor = dic435Color.withAlphaComponent(0.8)

        // 見た目調整
        navigationController?.navigationBar.tintColor = .clear
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "707070")
        
        // 消しちゃう？
        navigationController?.navigationBar.isHidden = true
        
        // TableView を追加
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        print("clear")
        
//        for i in 0...secondContents.count {
//            if secondContents[i].category == "touristArea" {
//                touristAreaContents[i] = secondContents[i].title
//            } else if secondContents[i].category == "cafeteria" {
//                cafeteriaContents[i] = secondContents[i].title
//            } else {
//                schoolContents[i] = secondContents[i].title
//            }
//        }

    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return practic.count
        return secondContents.count
        //return touristAreaContents.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = secondContents[indexPath.row].title
        //cell.textLabel?.text = touristAreaContents[indexPath.row]
        
        if secondContents[indexPath.row].category == "touristArea" {
            cell.textLabel?.textColor = .white
        } else if secondContents[indexPath.row].category == "cafeteria" {
            cell.textLabel?.textColor = .orange
        } else if secondContents[indexPath.row].category == "school" {
            cell.textLabel?.textColor = .black
        }
        
        //cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "HiraMaruProN-W4",size: cell.textLabel!.font.pointSize)
        cell.backgroundColor = .clear
        
        return cell
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // サイドバーを閉じる
        dismiss(animated: true, completion: nil)
         
        NotificationCenter.default.post(
            name: Notification.Name("SelectMenuNotification"),
            object: nil,
            userInfo: ["itemNo": indexPath.row] // 返したいデータをセットする
        )
    }
    
    func loadJson(){
        // パスの取得
        guard let path = Bundle.main.path(forResource: "Mapdata", ofType: "json") else {return}
        
        let url = URL(fileURLWithPath: path)
        
        do{
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.secondContents = try decoder.decode([PinDataTwo].self, from: data)
            
            print("success!!")
            //print(json.pin_data)
        } catch {
            print("error!!")
        }
    }
    
}
