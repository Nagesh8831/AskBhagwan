//
//  OshoCenterTableViewCell.swift
//  spotimusic
//
//  Created by BQ_08 on 7/21/18.
//

import UIKit

class OshoCenterTableViewCell: UITableViewCell {
    @IBOutlet weak var centerNameLabel: UILabel!

    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactPersonLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
