//
//  GenjiFacilitiesCell.swift
//  PBL_abe
//
//  Created by Abe on R 3/09/30.
//

import UIKit

final class FacilitiesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var facilityImage: UIImageView!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var siteButton: UIButton!
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
