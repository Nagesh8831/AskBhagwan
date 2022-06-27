//
//  EventsTableViewCell.swift
//  spotimusic
//
//  Created by BQ_Tech on 29/06/18.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var peopleImage: UIImageView!
    @IBOutlet weak var attendImage: UIImageView!
    @IBOutlet weak var updateEventButton: UIButton!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var willAttendButton: UIButton!
    @IBOutlet weak var peopleListButton: UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var approvalPendingLabel: UILabel!
    @IBOutlet weak var eventShareButton: UIButton!
    @IBOutlet weak var websiteLinkLabel: UILabel!
    @IBOutlet weak var websiteLinkButton: UIButton!
    @IBOutlet weak var imageWebsiteLinkButton: UIButton!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
