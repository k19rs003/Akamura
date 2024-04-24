//
//  TestMKPointAnnotation.swift
//  mapProject
//
//  Created by Tamai on 2021/10/04.
//

import UIKit
import MapKit
 
class CoustomMKPointAnnotation: MKPointAnnotation {
    //ピンの色
    var pinColor:UIColor = UIColor(hex: "009AF3")
    
    var pinPhoto:UIImageView = UIImageView(image: UIImage(named: "camphor_tree.png"))
    
}
