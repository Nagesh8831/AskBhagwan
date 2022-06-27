//
//  TermsAndConditionsViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 21/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVFoundation
import SCLAlertView
class TermsAndConditionsViewController: UIViewController,UIWebViewDelegate {

    var player: AVAudioPlayer?

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var segment: UISegmentedControl!
    var reachabilitysz: Reachability!
    var categoty : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        
        
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "About"

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RED_COLOR as Any], for: .selected)
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
//            MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
//        }else {
//            MiniPlayerView.sharedInstance.cancelButtonClicked()
//        }
        if let pdf = Bundle.main.url(forResource: "terms", withExtension: "html", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
        }
       segment.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }

    @objc func tapSegment(sender: UISegmentedControl) {
        // Action for touchDown-Event on an already selected segment
            if sender.selectedSegmentIndex == 0 {
                SVProgressHUD.show()
                if let pdf = Bundle.main.url(forResource: "terms", withExtension: "html", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.loadRequest(req as URLRequest)
                    SVProgressHUD.dismiss()
                }
            }else {
                 SVProgressHUD.show()
                if let pdf = Bundle.main.url(forResource: "combinepdf", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.loadRequest(req as URLRequest)
                    webView.scalesPageToFit = true
                     SVProgressHUD.dismiss()
                }
            }
    }
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "iphone_6_original-RingtonesHub-544", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.black)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
    }
    func webViewDidFinishLoad(_ webView: UIWebView){
        SVProgressHUD.dismiss()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
