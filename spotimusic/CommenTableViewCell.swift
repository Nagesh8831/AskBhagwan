//
//  CommenTableViewCell.swift
//  spotimusic
//
//  Created by BQ_Tech on 09/07/18.
//

import UIKit

class CommenTableViewCell: UITableViewCell {

    @IBOutlet weak var downloadSongTagButton: UIButton!
    @IBOutlet weak var playingTrackGIFImageView: UIImageView!
    @IBOutlet weak var commonImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commonName: UILabel!
    @IBOutlet weak var shareButtonWidthConstarint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
