//
//  EventsPeopleListTableViewCell.swift
//  spotimusic
//
//  Created by BQ_Tech on 30/06/18.
//

import UIKit

class EventsPeopleListTableViewCell: UITableViewCell {

    @IBOutlet weak var peopleImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var peopleNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
