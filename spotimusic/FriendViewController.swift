//
//  FriendViewController.swift
//  spotimusic
//
//  Created by Ravi Deshmukh on 27/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView

class FriendViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    var friendArray = [[String:AnyObject]]()
    var communityId = ""
    var items = [[String:AnyObject]]()
    var communityArray = [[String:AnyObject]]()
    var isShare = false
    var trackId = ""
    var trackType = ""
     var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        //reachabilitysz = Reachability()
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

    override func viewWillAppear(_ animated: Bool) {
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
        if isShare {
            getAllCommunityByUserId()
            cancelButton.isHidden = false
            titleLabel.isHidden = false
            titleLabel.text = "Communities"
        } else {
            getAllFriends()
            cancelButton.isHidden = true
            
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
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FriendViewController {
    func getAllFriends() {
        APICall.getFriends(communityId) { (data) in
            DispatchQueue.main.async(execute: {
                if let status = data["status"] as? Bool {
                    if status == true {
                        if let dictionaryArray = data["resultObject"]  as? [[String : AnyObject]] {
                           // print(dictionaryArray)
                            if dictionaryArray.count > 0 {
                                for i in (0..<dictionaryArray.count)
                                {
                                    if let dict = dictionaryArray[i] as? [String:AnyObject] , let action = dict["action"] as? String , action == "2" {
                                            self.friendArray.append(dict)
                                           // print(self.friendArray)
                                        }
                                }
                                self.titleLabel.text = "Total \(self.friendArray.count) friends"
                                self.noDataLabel.isHidden = true
                                self.tableView.reloadData()
                            }
                        } else {
                            if let message = data["message"] as? String {
                                self.noDataLabel.isHidden = false
                                self.noDataLabel.text = message
                                self.tableView.isHidden = true
                            }
                        }
                    }
                }
            })
        }
    }
    
    func getAllCommunityByUserId(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
       if let id = GLOBAL_USER_ID {
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_GET_ALL_COMMUNITY_BY_USER_ID + id.stringValue)
                  // print("urlResponce",urlResponce)
                   Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                       .responseJSON { response in
                           SVProgressHUD.dismiss()
                           
                           switch response.result {
                           case .success:
                               guard let itms = response.result.value else {return}
                               let itemss = itms as! NSDictionary
                               self.communityArray = itemss.value(forKey: "resultObject") as! [[String:AnyObject]]
                               
                               if let data = self.communityArray as? [[String:AnyObject]] {
                                   for i in (0..<data.count)
                                   {
                                    if let dict = data[i] as? [String:AnyObject] , let id1 = dict["parent_user_id"] as? String , id1 == id.stringValue  {
                                           if let action = dict["action"] as? String , action == "2" || action == "0" {
                                               self.items.append(dict)
                                           }
                                           
                                       } else {
                                           if let dict = data[i] as? [String:AnyObject] , let action = dict["action"] as? String , action == "2"  {
                                               self.items.append(dict)
                                           }
                                       }
                                   }
                               }
                               
                               
                               DispatchQueue.main.async() {
                                   self.tableView.reloadData()
                               }
                           case .failure(let error):
                               print(error)
                               let alert = UIAlertController(title: "Oops!", message: "Something went wrong", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                               DispatchQueue.main.async {
                                   self.present(alert, animated: true, completion: nil)
                               }
                           }
                         
                   }
        }
    }
    
    func addPostToCommunity() {
        
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        if  let userId = GLOBAL_USER_ID {
            let parameter = [
                "user_id": userId.stringValue,
                "community_id": communityId,
                "track_id": trackId,
                "track_type": trackType
                ] as [String : Any]
            //print(parameter)
            APICall.addPostToCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.dismiss()
                   // print("data::::\(data)")
                    if let message = data["message"] as? String {
                        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                        }
                        let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                        SCLAlertView().showTitle("Ask Bhagwan", subTitle: message, timeout:  time, completeText: "Done", style: .success)
                        self?.dismiss(animated: true, completion: nil)
                    }
                })
            }

        }
    }
}


extension FriendViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShare {
          return items.count
        } else {
        return friendArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        cell.contentView.backgroundColor = UIColor.clear
        
        if isShare {
            if let userName = items[indexPath.row]["community_name"] as? String {
                cell.nameLabel.text = "\(userName)"
            }
            
            if let cover = items[indexPath.row]["image_url"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,COMMUNITY,cover)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.profileImageView {
                        cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
        } else {
            if let userName = friendArray[indexPath.row]["username"] as? String {
                cell.nameLabel.text = "\(userName)"
            }
            
            if let cover = friendArray[indexPath.row]["profile_photo"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,cover)
               // print("imgeFile",imgeFile)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.profileImageView {
                        cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
        }
        return cell
    }
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        let imageView = gesture.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShare {
            if let id = items[indexPath.row]["id"] as? String {
                communityId = id
                let alert = UIAlertController(title: "Ask Bhagwan",message: "Are you sure you want to share this audio to community?", preferredStyle: .alert)
                let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                    self.addPostToCommunity()
                }
                let cancleEvent = UIAlertAction(title: "No", style: .cancel) { (_) -> Void in
                    //print("No")
                    self.dismiss(animated: true, completion: nil)
                }
                
                // Accessing alert view backgroundColor :
                alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = GRAY_COLOR
                alert.view.tintColor = UIColor.white
                
                alert.addAction(addEvent)
                alert.addAction(cancleEvent)
                present(alert, animated: true, completion:  nil)
            }
        }
    }
}
