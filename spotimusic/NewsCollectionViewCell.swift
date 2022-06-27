//
//  NewsCollectionViewCell.swift
//  spotimusic
//
//  Created by Mac on 05/02/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var newsDescriptionTextView: UITextView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
