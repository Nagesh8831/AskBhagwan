//
//  TermsCondtionstionsViewController.swift
//  spotimusic
//
//  Created by Mac on 06/08/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import  SCLAlertView
class TermsCondtionstionsViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var segment: UISegmentedControl!
     var reachabilitysz: Reachability!
    var categoty : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        menuBtn.target = self.revealViewController()
//        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
//        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //  categoty = UserDefaults.standard.value(forKey: "category") as? String
        self.title = "Terms & Conditions"
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RED_COLOR as Any], for: .selected)
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
//            MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
//            //MiniPlayerView.sharedInstance.delegate = self as! MiniPlayerViewDelegate
//        }else {
//            MiniPlayerView.sharedInstance.cancelButtonClicked()
//        }
        if let pdf = Bundle.main.url(forResource: "terms", withExtension: "html", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
        }
        segment.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
        //NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func tapSegment(sender: UISegmentedControl) {
        // Action for touchDown-Event on an already selected segment
        if sender.selectedSegmentIndex == 0 {
            if let pdf = Bundle.main.url(forResource: "terms", withExtension: "html", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
            }
        }else {
            if let pdf = Bundle.main.url(forResource: "combinepdf", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
                webView.scalesPageToFit = true
                //segment.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
            }
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
