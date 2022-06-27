

import UIKit

class DefaultTableViewCell: UITableViewCell {

    @IBOutlet var albumCoverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    func configure() {
        titleLabel.text = nil
        artistLabel.text = nil
        durationLabel.text = nil
        
        titleLabel.textColor = UIColor.white
        artistLabel.textColor = UIColor.white
        durationLabel.textColor = UIColor.darkGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }
    
    override func prepareForReuse() {
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (selected) {
            titleLabel.textColor = GREEN_COLOR
            artistLabel.textColor = UIColor.white
            durationLabel.textColor = GREEN_COLOR
        } else {
            titleLabel.textColor = UIColor.white
            artistLabel.textColor = UIColor.white
            durationLabel.textColor = UIColor.darkGray
        }
        
    }

}
