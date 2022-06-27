//
//  MiniPlayerView.swift
//  spotimusic
//
//  Created by SCISPLMAC on 25/08/18.
//

import UIKit

class MiniPlayerView: UIView {
    static let sharedInstance = MiniPlayerView()
    let playerHeight : CGFloat = 48.0
    
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    func displayView(presentingViewController:UIViewController) {
        
        for view in presentingViewController.view.subviews {
            if view.isKind(of: MiniPlayerView.self) {
                view.removeFromSuperview()
            }
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MiniPlayerViewController") as! MiniPlayerViewController
       vc.audioName = "ABCD"
        vc.view.frame = CGRect(x: 0, y: presentingViewController.view.bounds.height - self.playerHeight, width: presentingViewController.view.bounds.width, height: self.playerHeight)
        presentingViewController.view.addSubview(vc.view)
    }
    
    @IBAction func playerButtonClicked() {
        self.removeFromSuperview()
        let notificationName = Notification.Name("miniAudioPlayer")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    @IBAction func cancelButtonClicked() {
        AudioPlayer.sharedAudioPlayer.pause()
        self.removeFromSuperview()
        
    }
}
