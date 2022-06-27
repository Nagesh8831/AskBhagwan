//
//  HomeCollectionViewCell.swift
//  spotimusic
//
//  Created by BQ_Tech on 30/06/18.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var homeImageView: UIImageView!
    
    @IBOutlet weak var lockButton: UIButton!
    var isPlay = false
}
