//
//  Co2TableViewCell.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/11/11.
//

import UIKit

class Co2TableViewCell: UITableViewCell {
    
    @IBOutlet weak var stackViewSuperViewConstraint: NSLayoutConstraint! {
        didSet {
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                stackViewSuperViewConstraint.priority = UILayoutPriority.init(999)
            }
        }
    }
    
    @IBOutlet weak var stackViewCo2ImageViewConstraint: NSLayoutConstraint! {
        didSet{
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                stackViewCo2ImageViewConstraint.priority = UILayoutPriority.init(1)
            }
        }}
    
    @IBOutlet weak var co2ImageView: UIImageView! {
        didSet{
            //            print ("123: \(UIDevice.modelName)")
            if UIDevice.modelName.contains("iPhone SE (1st generation)") {
                co2ImageView.isHidden = true
            }
        }}
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
}
