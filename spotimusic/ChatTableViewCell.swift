//
//  ChatTableViewCell.swift
//  spotimusic
//
//  Created by BQ_Tech on 12/09/18.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 5.0
        messageView.clipsToBounds = true
    }
}
