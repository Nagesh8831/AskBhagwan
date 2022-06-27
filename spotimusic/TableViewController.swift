

import UIKit

class TableViewController: UITableViewController {
    lazy var playerBarButtonItem: UIBarButtonItem = {
        var button = UIButton(type: .system) as UIButton
        var image = UIImage(named: "arrow1.png")!
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 44)
       // button.setImage(image, forState: .Normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(image.size.width+15), bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: button.frame.size.width - image.size.width, bottom: 0, right: 0)
        return UIBarButtonItem(customView: button)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state == STKAudioPlayerState.playing && AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state == STKAudioPlayerState.buffering ){
            
            self.navigationItem.rightBarButtonItem = self.playerBarButtonItem
            
        }
        
    }
    
    override func viewDidDisappear (_ animated: Bool) {

        self.navigationItem.rightBarButtonItem = self.playerBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func showPlayerBarButtonTapped(_ sender: AnyObject) {
        
        
        
        if (AudioPlayer.sharedAudioPlayer.playlist?.count() != nil ) {
            
            print("Aplay no nil", AudioPlayer.sharedAudioPlayer.playlist?.count())
            
            let controller = RadioStreamViewController.sharedInstance
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            
            
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
