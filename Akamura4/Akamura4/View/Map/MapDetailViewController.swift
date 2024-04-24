//
//  MapDetailViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/10/12.
//

import UIKit
import MapKit

class MapDetailViewController: UIViewController{

    var titleData:String = ""
    var imageData:String = ""
    var latitudeData:Double = 0
    var longitudeData:Double = 0
    var describeData:String = ""

    @IBOutlet weak var detailImageView: UIImageView!{
        didSet{
            detailImageView.image = UIImage(named: imageData)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.textColor = .white
            titleLabel.backgroundColor = .ThemeColor
            titleLabel.font = titleLabel.font.withSize(20)
            titleLabel.text = titleData
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
        }
    }
    
    @IBOutlet weak var describeLabel: UILabel!{
        didSet{
            describeLabel.text = describeData
            describeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping //単語ごと
            //describeLabel.lineBreakMode = NSLineBreakMode.byCharWrapping//文字単位
            describeLabel.sizeToFit()
        }
    }
    
    @IBOutlet weak var rootButton: UIButton!{
        didSet{
            rootButton.layer.cornerRadius = 25
        }
    }
    

    @IBAction func stopAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func routeSearchButton(_ sender: UIButton) {
        
        let coordinate = CLLocationCoordinate2DMake(latitudeData, longitudeData)
        let placemark = MKPlacemark(coordinate:coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = titleData
        
        //起動オプション
        let option: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject, //徒歩で移動
                                                  MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue as AnyObject]  //地図表示はダークモード向けに標準
        
        //マップアプリを起動
        mapItem.openInMaps(launchOptions: option)
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

    }
    
}
