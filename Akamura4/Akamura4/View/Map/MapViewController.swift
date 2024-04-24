//
//  ViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/09/30.
//

import UIKit
import MapKit// iOS5.1以前はgoogle機能を使用していた
import SideMenu

class MapViewController: UIViewController, MKMapViewDelegate {
    // 構造体
    struct PinData: Codable{
        var title: String //ピンの場所の名前
        var latitude: Double //緯度
        var longitude: Double //経度
        var category: String//ピン色
        var photo: String //写真
        var explanation: String //説明
        
    }
    
    var contents = [PinData]() //JSONの配列
    let red = UIColor.ThemeColor
    private let blue = UIColor(hex: "009AF3") //ピンの色 blue
    private let orange = UIColor(hex: "FE9864") //ピンの色 orange
    let storyboardsId = "two" //second:stackViewで作成 two:navigationで作成
    
    @IBOutlet weak var topView: UIView!{
        didSet{
            topView.backgroundColor = .ThemeColor
        }
    }
    @IBOutlet weak var menueButton: UIBarButtonItem!{
        didSet{
            menueButton.tintColor = .white
        }
    }
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!{
        didSet{
            segmentedControlOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:red],for: .selected)
        }
    }
    //　MKMapViewのプロパティを定義
    @IBOutlet weak var mapView: MKMapView!{
        //プロパティが設定されるたびに設定が必要な場合
        didSet{
            mapView.mapType = MKMapType.hybrid
            // デリゲートをアサインする. MKMapView の delegate 問い合わせ先を self に
            self.mapView.delegate = self
        }
        
    }
    
    // 回転させたくないViewControllerに
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // ビューのロードしたあとに一度だけセットが必要な場合
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup() //最初の座標の位置設定
        loadJson() //MapdataからJSONデータを取り出す
        pinSetup() //ピンの表示
        setSideMenu() // サイドバーメニューからの通知を受け取る
    
        self.navigationItem.title = "観光マップ"
        self.view.tintColor = .ThemeColor
    }

    private func setSideMenu() {
        // サイドバーメニューからの通知を受け取る
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(catchSelectMenuNotification(notification:)),
            name: Notification.Name("SelectMenuNotification"),
            object: nil
        )
        print("読んだ")
    }
    
    // 選択されたサイドバーのアイテムを取得
    @objc func catchSelectMenuNotification(notification: Notification) -> Void {
        // メニューからの返り値を取得
        // = notification.userInfo
        guard let itemNumber = notification.userInfo?["itemNo"] as? Int else { return }
        print(itemNumber)
        
        // 緯度と経度の値を座標データ構造の形式にします。
        let location = CLLocationCoordinate2DMake(contents[itemNumber].latitude,contents[itemNumber].longitude)
        // マップ領域の幅と高さを指定します。 delta 差
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        // 領域の設定をする
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated:true)
    }
    
    //　最初の座標を定義
    func mapSetup(){
        // 緯度と経度の値を座標データ構造の形式にします。
        let location = CLLocationCoordinate2DMake(33.6124,130.8822)
        // マップ領域の幅と高さを指定します。 delta 差
        let span = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        // 領域の設定をする
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated:true)
    }
    
    func pinSetup(){
        
        //JSONのデータの数を変数に追加
        let pinMaxNumber = contents.count
        
        //JSONのデータ数分、設定する
        for i in 0..<pinMaxNumber {
            //カスタムのアノテーション使用（CoustomMKPointAnnotation参照）
            let annotation = CoustomMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(contents[i].latitude, contents[i].longitude)
            annotation.title = contents[i].title
            annotation.pinPhoto = UIImageView(image: UIImage(named: contents[i].photo))
            
            //ピンの色の設定
            switch contents[i].category {
                
            case "touristArea":annotation.pinColor = blue //blue
            case "cafeteria": annotation.pinColor = orange //orange
            default: annotation.pinColor = UIColor.black
                
            }
        
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func loadJson(){
        // パスの取得
        guard let path = Bundle.main.path(forResource: "Mapdata", ofType: "json") else {return}
        
        let url = URL(fileURLWithPath: path)
        
        do{
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.contents = try decoder.decode([PinData].self, from: data)
            
            print("success!!")
            //print(json.pin_data)
        } catch {
            print("error!!")
        }
    }
    
    //ピンを挿すときの設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKMarkerAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationView")
        
        
        annotationView.animatesWhenAdded = true
        
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        
        let testPinView = MKPinAnnotationView()
        
        testPinView.annotation = annotation
        //アノテーションビューに色を設定する。
        if let test = annotation as? CoustomMKPointAnnotation {
            annotationView.markerTintColor = test.pinColor
            annotationView.detailCalloutAccessoryView = test.pinPhoto
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        for j in 0 ..< contents.count {
            //MapDetailViewControllerに値を渡したい
            //mapDetailViewController.imageData = contents[i].photo
            
            //ピンを押したときのタイトルとjsonのタイトルをfor文で回して、検索してます
            if view.annotation?.title?!.applyingTransform(.fullwidthToHalfwidth, reverse: false) == contents[j].title.applyingTransform(.fullwidthToHalfwidth, reverse: false){
                
           
                let storyboard: UIStoryboard = self.storyboard!
                let nc: UINavigationController = storyboard.instantiateViewController(withIdentifier: "detail") as! UINavigationController
                let followingVC = nc.viewControllers[0] as! MapDetailViewController
//                followingVC.variable = self.variable //ここで値渡し
                
                followingVC.imageData = contents[j].photo
                followingVC.describeData = contents[j].explanation
                followingVC.latitudeData = contents[j].latitude
                followingVC.longitudeData = contents[j].longitude
                followingVC.titleData = contents[j].title
                self.present(nc, animated: true, completion: nil) //画面遷移
                
                return
            }
        }
    }
    
    
    //menueのアクション
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        guard let menu = SideMenuManager.default.rightMenuNavigationController else { return print("つながってない") }
        present(menu, animated: true, completion: nil)
       
    }

    //セグメントコントローラの設定
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
        case 0: mapView.mapType = MKMapType.standard    // 地図のタイプを標準に設定.
        case 1: mapView.mapType = MKMapType.hybrid      // 地図のタイプをハイブリッド(航空写真+標準)に設定.
        case 2: mapView.mapType = MKMapType.satellite   // 地図のタイプを航空写真に設定.
        default: break//mapView.mapType = MKMapType.hybrid   // 地図のタイプをハイブリッドに設定.
            
        }
    }

    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}
