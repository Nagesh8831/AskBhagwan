

import UIKit

protocol SearchResultCellDelegate {
    func searchResultCell(_ searchResultCell: SearchResultCell!, downloadButtonPressed downloadButton: UIButton!)
    func searchResultCell(_ searchResultCell: SearchResultCell!, stopButtonPressed stopButton: ProgressButton!)
}

enum SearchResultCellState {
    case normal
    case progress
    case complete
}

class SearchResultCell: UITableViewCell, ProgressButtonDelegate {

    
    
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackCover: UIImageView!
    @IBOutlet weak var playCount: UILabel!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var progressButton: ProgressButton!
    
    
    var delegate: SearchResultCellDelegate?
    
    var state: SearchResultCellState! = .normal {
        didSet {
            if state == .normal {
                progressButton.isHidden = true
               // downloadButton.isHidden = false
            } else if state == .progress {
                progressButton.isHidden = false
                //downloadButton.isHidden = true
            } else if state == .complete {
                progressButton.isHidden = true
               // downloadButton.isHidden = true
            }
        }
    }
    
    func configure() {
//        self.titleLabel.text = nil
//        self.progressButton.configure()
//        self.progressButton.delegate = self
//        self.progressButton.progress = 0.0
//        //self.downloadButton.isHidden = false
//        self.state = .normal
//        self.titleLabel.textColor = UIColor(rgba:"#ffffff")
     
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.configure()
    }

    override func prepareForReuse() {
        self.configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (selected) {
           // let color = UIColor(rgba:"#23c20e")// tintColor
            self.titleLabel.textColor = UIColor.white
         
        } else {
            self.titleLabel.textColor = UIColor.white
           
        }
    }
//
//    @IBAction func downloadButtonPressed(_ sender: AnyObject) {
//        
//            self.state = .progress
//            self.delegate?.searchResultCell(self, downloadButtonPressed: downloadButton)
//            
//    }

    @IBAction func progressButtonPressed(_ sender: AnyObject) {
        self.state = .normal

        self.delegate?.searchResultCell(self, stopButtonPressed: progressButton)
    }

    // MARK: - ProgressButtonDelegate
    
    func progressButton(_ progressButton: ProgressButton, didUpdateProgress progress: Double) {
        if progress >= 1.0 {
            self.state = .complete
        }
    }
}
