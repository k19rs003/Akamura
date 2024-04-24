//
//  HeaderCell.swift
//  PBL_abe
//
//  Created by Abe on R 3/09/30.
//

import Foundation
import UIKit

class FacilityHeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont(name: "KFhimaji",size: 26)
        }
    }
    @IBOutlet weak var openCloseLabel: UILabel! {
        didSet {
            openCloseLabel.font = UIFont(name: "KFhimaji",size: 26)
        }
    }
    
    
    
    func setup(title: String, openClose: Bool) {
        titleLabel.text = title
        openCloseLabel.text = ">"
        if openClose == true {
            openCloseLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
        } else {
            openCloseLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
    }

}
