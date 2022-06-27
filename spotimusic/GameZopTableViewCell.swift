//
//  GameZopTableViewCell.swift
//  spotimusic
//
//  Created by Mac on 22/09/20.
//  Copyright © 2020 Appteve. All rights reserved.
//

import UIKit

class GameZopTableViewCell: UITableViewCell {

    @IBOutlet weak var gameZopImageView: UIImageView!
    @IBOutlet weak var gameZopButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
