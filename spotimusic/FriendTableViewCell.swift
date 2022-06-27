//
//  FriendTableViewCell.swift
//  spotimusic
//
//  Created by Ravi Deshmukh on 27/07/18.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: GIAImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var adminLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
