//
//  HomeHeaderTableViewCell.swift
//  spotimusic
//
//  Created by SCISPLMAC on 21/08/18.
//

import UIKit

class HomeHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
