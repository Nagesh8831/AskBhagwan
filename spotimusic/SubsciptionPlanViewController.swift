//
//  SubsciptionPlanViewController.swift
//  spotimusic
//
//  Created by Mac on 16/07/21.
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
class SubsciptionPlanViewController: BaseViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
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
    @IBOutlet weak var premiumView: UIView!

    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    var subscriptionMonth = 0
    var subscriptionStatus  = false
    var subscrptionEndDate = ""
    let date = Date()
    var isFromMusicPlayer = false
    let formatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        title = "Ask Bhagwan subscription"
        oneMonthImageView.image = UIImage(named: "radio_fill")
        oneMonthView.layer.borderColor = UIColor.white.cgColor
        oneMonthView.layer.borderWidth = 2.0
        subscriptionMonth = 1

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let idds = UserDefaults.standard.value(forKey: "id") {
            getUserInfo(id: idds as! String)
        }
        subscrptionEndDate = UserDefaults.standard.string(forKey: "subscriptionEndDate")!
       // let result = formatter.string(from: date)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
             if subscriptionStatus == true {
                 print("User subscribed")
                unSubsciptionView.isHidden = true
                premiumView.isHidden = false
                subscribeButton.isHidden = true
             }else {
                print("User Unsubscribed")
                unSubsciptionView.isHidden = false
                premiumView.isHidden = true
                subscribeButton.setTitle("Subscribe Now", for: .normal)
             }
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
        vc.isFromMusicPlayer = false
        vc.selectedMonth = subscriptionMonth
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getUserInfo(id : String){
        print("noodataavailabel")
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_USER_INFO + id)
            print(urlResponce)
            Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    print(response)
                    SVProgressHUD.dismiss()
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    print("itemss",itemss)
                    let st = itemss["state_id"] as! String
                    let ct = itemss["country_id"] as! String

                    let subscriptionEndDate = itemss["subscriptionEndDate"] as! String
                    if subscriptionEndDate != "0000-00-00"{
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "YYYY-MM-dd"

                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "MMM d, yyyy"

                    let showDate = inputFormatter.date(from: subscriptionEndDate)
                    let resultString = outputFormatter.string(from: showDate!)

                    self.subscriptionStatusLabel.text = "Subscription end date: " + resultString

                    UserDefaults.standard.set(subscriptionEndDate, forKey: "subscriptionEndDate")
                    UserDefaults.standard.synchronize()
                }
                    print(st)
                    print(ct)
                    if st == "0" || st == "" || ct == "0" || ct == "" {
                        print("Show pop up")
                       // self.showAlert()
                let notify = Notification.Name(rawValue: "popUp")
                        NotificationCenter.default.post(name: notify, object: nil)
                    }
            }
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

