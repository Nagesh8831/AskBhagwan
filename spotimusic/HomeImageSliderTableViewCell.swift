//
//  HomeImageSliderTableViewCell.swift
//  spotimusic
//
//  Created by SCISPLMAC on 22/08/18.
//

import UIKit
import AACarousel

class HomeImageSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var imageSlider: AACarousel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
