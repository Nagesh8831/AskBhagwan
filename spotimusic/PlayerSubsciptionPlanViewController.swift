//
//  PlayerSubsciptionPlanViewController.swift
//  spotimusic
//
//  Created by Mac on 19/08/21.
//  Copyright © 2021 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import CZPicker
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
import StoreKit

class PlayerSubsciptionPlanViewController: UIViewController {

    @IBOutlet weak var subscribeButton: UIButton!

    @IBOutlet weak var oneMonthButton: UIButton!
    @IBOutlet weak var sixMonthButton: UIButton!
    @IBOutlet weak var oneYearButton: UIButton!

    @IBOutlet weak var oneMonthView: UIView!
    @IBOutlet weak var sixMonthView: UIView!
    @IBOutlet weak var oneYearView: UIView!

    @IBOutlet weak var oneMonthImageView: UIImageView!
    @IBOutlet weak var sixMonthImageView: UIImageView!
    @IBOutlet weak var oneYearImageView: UIImageView!

    @IBOutlet weak var unSubsciptionView: UIView!


    var subscriptionMonth = 0
    var subscriptionStatus  = false
    var subscrptionEndDate = ""
    let date = Date()
    var isFromMusicPlayer = false
    let formatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
//        menuBtn.target = self.revealViewController()
//        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
//        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//         navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = true
//        self.navigationController!.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor : UIColor.white
//        ]
//        self.navigationController?.navigationBar.tintColor = UIColor.white
        title = "Ask Bhagwan subscription"
        oneMonthImageView.image = UIImage(named: "radio_fill")
        oneMonthView.layer.borderColor = UIColor.white.cgColor
        oneMonthView.layer.borderWidth = 2.0
        subscriptionMonth = 1

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    @IBAction func selectPlanButtonAction(_ sender: UIButton) {
        if sender.tag == 101 {
            oneMonthImageView.image = UIImage(named: "radio_fill")
            sixMonthImageView.image = UIImage(named: "radio_unfill")
            oneYearImageView.image = UIImage(named: "radio_unfill")
            oneMonthView.layer.borderColor = UIColor.white.cgColor
            oneMonthView.layer.borderWidth = 2.0
            sixMonthView.layer.borderColor = UIColor.clear.cgColor
            oneYearView.layer.borderColor = UIColor.clear.cgColor
            subscriptionMonth = 1
        } else if sender.tag == 102 {
            oneMonthImageView.image = UIImage(named: "radio_unfill")
            sixMonthImageView.image = UIImage(named: "radio_fill")
            oneYearImageView.image = UIImage(named: "radio_unfill")
            sixMonthView.layer.borderColor = UIColor.white.cgColor
            sixMonthView.layer.borderWidth = 2.0
            oneMonthView.layer.borderColor = UIColor.clear.cgColor
            oneYearView.layer.borderColor = UIColor.clear.cgColor
            subscriptionMonth = 6
        } else if sender.tag == 103{
            oneMonthImageView.image = UIImage(named: "radio_unfill")
            sixMonthImageView.image = UIImage(named: "radio_unfill")
            oneYearImageView.image = UIImage(named: "radio_fill")
            oneYearView.layer.borderColor = UIColor.white.cgColor
            oneYearView.layer.borderWidth = 2.0
            subscriptionMonth = 12
            sixMonthView.layer.borderColor = UIColor.clear.cgColor
            oneMonthView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    @IBAction func subscriptionButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomIntegrationViewController") as! CustomIntegrationViewController
        vc.isFromMusicPlayer = true
        vc.selectedMonth = subscriptionMonth
        self.present(vc, animated: true, completion: nil)
       // self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
