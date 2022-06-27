//
//  OshoCenterViewController.swift
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
import SCLAlertView
class OshoCenterViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var oshoCenterTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
     var reachabilitysz: Reachability!
    var categoty : String?
    var centerArray = [[String:AnyObject]]()
    var stateId = ""
    var stateName = ""
    var subscriptionStatus  = false
    var adsTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Meditation Centers"
        oshoCenterTableView.register(UINib(nibName: "OshoCenterTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        oshoCenterTableView.estimatedRowHeight = 194
        oshoCenterTableView.rowHeight = UITableView.automaticDimension
        menuBtn.image = UIImage(named: "back")
        menuBtn.target = self
        menuBtn.action = #selector(menuButtonTapped(sender:))
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()
        } else {
        }
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        categoty = UserDefaults.standard.value(forKey: "category") as? String
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        getAllAshramByStateId(stateId)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        let trackInlist = UserDefaults.standard.bool(forKey: "isTrackInList")
        if trackInlist == true {
            if ((AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) == .playing){
                UserDefaults.standard.set(false, forKey: "isTrackInList")
                UserDefaults.standard.synchronize()
            }
        }else {
            if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }
    @objc func callBack(){
         subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
              if subscriptionStatus == true {
                  print("User subscribed")
              }else {
                showAdds()
               // IronSource.showRewardedVideo(with: self)
              }
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func backAction(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return centerArray.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = oshoCenterTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OshoCenterTableViewCell
        cell.stateLabel.text = stateName
        cell.callButton.tag = indexPath.row
        cell.callButton.addTarget(self, action: #selector(callBTNClicked(sender:)), for: .touchUpInside)
        if let name = centerArray[indexPath.row]["name"] as? String, name != "" {
            cell.centerNameLabel.text = name
        } else {
            cell.centerNameLabel.text = "Not Provided"
        }

        if let address = centerArray[indexPath.row]["address"] as? String , address != "" {
            cell.addressLabel.text = address
        } else {
            cell.addressLabel.text = "Not Provided"
        }

        if let contact_name = centerArray[indexPath.row]["contact_name"] as? String , contact_name != "" {
            cell.contactPersonLabel.text = contact_name
        } else {
            cell.contactPersonLabel.text = "Not Provided"
        }

        if let contact_number = centerArray[indexPath.row]["contact_number"] as? String , contact_number != "" {
            cell.contactNumberLabel.text = contact_number
        } else {
            cell.contactNumberLabel.text = "Not Provided"
        }

        if let website = centerArray[indexPath.row]["website"] as? String , website != "" {
            cell.websiteLabel.text = website
        } else {
            cell.websiteLabel.text = "Not Provided"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 275.0
    }
    
    @objc func callBTNClicked(sender: UIButton) {
        var no = ""
        if let contact_number = centerArray[sender.tag]["contact_number"] as? String , contact_number != "" {
            no = contact_number
        }
        if let url = URL(string: "tel://\(no)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension OshoCenterViewController {
    func getAllAshramByStateId (_ stateId : String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "id": stateId
            ]
        print(parameter)
        APICall.getAllAshramByStateId(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                print("data::::\(data)")
                if let result = data["resultObject"] as? [[String:AnyObject]] {
                    weakSelf.centerArray = result
                    print(weakSelf.centerArray)
                   
                    if weakSelf.centerArray.count > 0 {
                        weakSelf.oshoCenterTableView.reloadData()
                    } else {
                        weakSelf.oshoCenterTableView.isHidden = true
                        weakSelf.noDataLabel.isHidden = false
                    }
                } else {
                    weakSelf.oshoCenterTableView.isHidden = true
                    weakSelf.noDataLabel.isHidden = false
                }
            })
        }
    }
}
