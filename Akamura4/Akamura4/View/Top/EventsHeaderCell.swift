//
//  EventsTopCell.swift
//  mapProject
//
//  Created by Tamai on 2021/10/23.
//

import UIKit

class EventsHeaderCell: UITableViewHeaderFooterView{
    
    @IBOutlet weak var seasonTitleLabel: UILabel!{
        didSet {
            seasonTitleLabel.font = UIFont(name: "KFhimaji",size: 26)
            
        }
    }
    @IBOutlet weak var closeOpenLabel: UILabel!{
        didSet {
            closeOpenLabel.font = UIFont(name: "KFhimaji",size: 26)
        }
    }
    func setup(title: String, openClose: Bool) {
        seasonTitleLabel.text = title
        
        closeOpenLabel.text = ">"
        if openClose == true {
            closeOpenLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
        } else {
            closeOpenLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
    }
    
}
