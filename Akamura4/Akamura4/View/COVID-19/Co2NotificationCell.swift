//
//  Co2NotificationCell.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/12/18.
//

import UIKit

class Co2NotificationCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch! {
        didSet {
            notificationSwitch.isOn = false
        }
    }
    
}
