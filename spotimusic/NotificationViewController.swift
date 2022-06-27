//
//  NotificationViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 26/07/18.
//

import UIKit
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
import Alamofire

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    var requestArray = [[String:AnyObject]]()
    var communityId = ""
     var reachabilitysz: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notification"
        tableView.register(UINib(nibName: "RequestTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
      //  reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButtonAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllCommunityByUserId()
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
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }

}

extension NotificationViewController {
    
    func getAllCommunityByUserId(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        if let ids  = GLOBAL_USER_ID {
            let id = ids.stringValue
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_GET_ALL_COMMUNITY_BY_USER_ID + id)
            self.requestArray.removeAll()
            Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success:
                        
                        guard let itms = response.result.value else {return}
                        let itemss = itms as! NSDictionary
                        
                        if let dictionaryArray = itemss.value(forKey: "resultObject")   as? [[String : AnyObject]] {
                            if dictionaryArray.count > 0 {
                                for i in (0..<dictionaryArray.count)
                                {
                                    if let dict = dictionaryArray[i] as? [String:AnyObject] , let action = dict["action"] as? String , action == "1" , let request = dict["request"] as? String , request == "1" {
                                        self.requestArray.append(dict)
                                    }
                                }
                                if self.requestArray.count > 0 {
                                    self.tableView.reloadData()
                                    self.noDataLabel.isHidden = true
                                    self.tableView.isHidden = false
                                } else {
                                    //self.view.bringSubview(toFront: self.noDataLabel)
                                    self.noDataLabel.isHidden = false
                                    self.tableView.isHidden = true
                                }
                            }else  {                        self.tableView.isHidden = true
                            }
                        } else {
                            
                        }
                        
                        
                        
                        DispatchQueue.main.async() {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                   
            }
        }
        
    }
    
    func acceptRejectCommunity(_ userId : String ,isAccept: Bool) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        var action = ""
        if isAccept {
            action = "2"
        } else {
            action = "3"
        }
        let parameter = [
            "community_id": communityId,
            "user_id": userId,
            "action": action
            ] as [String : Any]
        print(parameter)
        APICall.acceptRejectCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                print("data::::\(data)")
                if let result = data["resultObject"] as? [[String:AnyObject]] {
                   
                    self?.communityId = ""
                     weakSelf.getAllCommunityByUserId()
                } else {
                    self?.communityId = ""
                    weakSelf.getAllCommunityByUserId()
                }
            })
        }
    }
}

extension NotificationViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return requestArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
                cell.pendingButton.isHidden = true
                cell.acceptView.isHidden = false
            cell.profileImage.image = UIImage(named:"Image-3")
        cell.profileImage.clipsToBounds = true
            if let name = requestArray[indexPath.row]["community_name"] as? String {
                cell.nameLabel.text = name
            }
            
            if let pic = requestArray[indexPath.row]["image_url"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,COMMUNITY,pic)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                })
            } else {
                cell.profileImage.image = UIImage(named:"Image-3")
        }
            
            cell.acceptButton.tag = indexPath.row
            cell.rejectButton.tag = indexPath.row
            
            cell.acceptButton.addTarget(self, action: #selector(acceptButtonClicked), for: .touchUpInside)
            cell.rejectButton.addTarget(self, action: #selector(rejectButtonClicked), for: .touchUpInside)
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    @objc func acceptButtonClicked(_ sender : UIButton) {
        if let userId = GLOBAL_USER_ID {
            if let comId = requestArray[sender.tag]["id"] as? String {
                communityId = comId
                self.acceptRejectCommunity(userId.stringValue, isAccept: true)
            }
        }
    }
    
    @objc func rejectButtonClicked(_ sender: UIButton) {
        if let userId = GLOBAL_USER_ID {
            if let comId = requestArray[sender.tag]["id"] as? String {
                       communityId = comId
                self.acceptRejectCommunity(userId.stringValue, isAccept: false)
                   }
        }
       
    }
}
