//
//  DiscourseTableViewCell.swift
//  spotimusic
//
//  Created by Mac on 18/03/21.
//  Copyright © 2021 Appteve. All rights reserved.
//

import UIKit

class DiscourseTableViewCell: UITableViewCell {

    @IBOutlet weak var categotyNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
