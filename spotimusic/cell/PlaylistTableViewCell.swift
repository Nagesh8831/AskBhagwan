//
//  PlaylistTableViewCell.swift
//  spotimusic
//
//  Created by appteve on 09/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playlistName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
