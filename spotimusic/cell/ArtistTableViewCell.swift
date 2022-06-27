//
//  ArtistTableViewCell.swift
//  spotimusic
//
//  Created by appteve on 11/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistCover: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
