//
//  EventsCell.swift
//  mapProject
//
//  Created by Tamai on 2021/10/23.
//

import UIKit

class EventsCell:UITableViewCell {
    @IBOutlet weak var eventTitleLabel: UILabel! {
        didSet {
            eventTitleLabel.adjustsFontSizeToFitWidth = true
            eventTitleLabel.minimumScaleFactor = 0.3
        }
    }
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var monthLabel: UILabel! {
        didSet {
            monthLabel.adjustsFontSizeToFitWidth = true
            monthLabel.minimumScaleFactor = 0.3
        }
    }
    @IBOutlet weak var cellButton: UIButton!

    var event: Contents? {
        didSet {
            Task {
                guard let eventList = event else { return }
                let url = "http://133.17.165.154:8086/akamura4/Pictures/\(eventList.picture).png"
                let getImage = try await AkamuraAPIService.shared.fetchImage(with: url)
                let image = UIImage(data: getImage)
                Task { @MainActor in
                    eventTitleLabel.text = eventList.title
                    monthLabel.text = eventList.month + "月"
                    eventImageView.image = image
                    if eventList.month == "" {
                        monthLabel?.isHidden = true
                    } else {
                        monthLabel?.isHidden = false
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    // 再利用可能なセルを準備
    override func prepareForReuse() {
        super.prepareForReuse()

    }
}
