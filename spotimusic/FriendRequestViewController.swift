//
//  FriendRequestViewController.swift
//  spotimusic
//
//  Created by Ravi Deshmukh on 27/07/18.
//

import UIKit
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView

class FriendRequestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var friendArray = [[String:AnyObject]]()
    var requestArray = [[String:AnyObject]]()
    var communityId = ""
    var isFriendRequest = false
     var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        tableView.register(UINib(nibName: "RequestTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
       // reachabilitysz = Reachability()
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
        getAllFriends()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isFriendRequest = false
            friendArray.removeAll()
            requestArray.removeAll()
            titleLabelHeightConstraint.constant = 21
            getAllFriends()
        } else {
            friendArray.removeAll()
            requestArray.removeAll()
            isFriendRequest = true
            titleLabelHeightConstraint.constant = 0
            getAllFriends()
        }
    }
}

extension FriendRequestViewController {
    func getAllFriends() {
        friendArray.removeAll()
        requestArray.removeAll()
        self.tableView.reloadData()
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
                                    } else if let dict = dictionaryArray[i] as? [String:AnyObject] , let action = dict["action"] as? String , action == "1" , let request = dict["request"] as? String , request == "1" || request == "2" {
                                        self.requestArray.append(dict)
                                    }
                                }
                                self.titleLabel.text = "Total \(self.friendArray.count) friends"
                                if self.segment.selectedSegmentIndex == 0 {
                                    self.tableView.reloadData()
                                    if self.friendArray.count > 0 {
                                        self.noDataLabel.isHidden = true
                                        self.tableView.isHidden = false
                                    } else {
                                        self.tableView.reloadData()
                                        self.noDataLabel.isHidden = false
                                        self.noDataLabel.text = "No friends available in this community"
                                        self.tableView.isHidden = true
                                    }
                                } else {
                                    if self.requestArray.count > 0 {
                                        self.tableView.reloadData()
                                        self.noDataLabel.isHidden = true
                                        self.tableView.isHidden = false
                                    } else {
                                        self.tableView.reloadData()
                                        self.noDataLabel.isHidden = false
                                        self.noDataLabel.text = "No request available in this community"
                                        self.tableView.isHidden = true
                                    }
                                }
                                
                            }
                        } else {
                            if self.segment.selectedSegmentIndex == 0 {
                                self.tableView.reloadData()
                                self.noDataLabel.isHidden = false
                                self.noDataLabel.text = "No friends available in this community"
                                self.tableView.isHidden = true
                            } else {
                                self.tableView.reloadData()
                                self.noDataLabel.isHidden = false
                                self.noDataLabel.text = "No request available in this community"
                                self.tableView.isHidden = true
                            }
                        }
                    }
                }
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            })
           
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
        APICall.acceptRejectCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                print("aceept reject data::::\(data)")
                
                if let status = data["status"] as? Bool {
                    if status == true {
                        weakSelf.getAllFriends()
                        self?.tableView.reloadData()
                    }
                }
            })
        }
    }
}

extension FriendRequestViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFriendRequest {
            return friendArray.count
        } else {
            return requestArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isFriendRequest {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
            cell.contentView.backgroundColor = UIColor.clear
            
            if let userName = friendArray[indexPath.row]["username"] as? String {
                cell.nameLabel.text = "\(userName)"
            }
            if let parentUserId = GLOBAL_USER_ID {
                if let parent_user_id = friendArray[indexPath.row]["user_id"] as? String ,parent_user_id == parentUserId.stringValue {
                               print(parent_user_id)
                               cell.adminLabel.isHidden = false
                           }else {
                               cell.adminLabel.isHidden = true
                           }
            }
            if let cover = friendArray[indexPath.row]["profile_photo"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,cover)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.profileImageView {
                        cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                    
                    
                })
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
            
            if let request = requestArray[indexPath.row]["request"] as? String , request == "1" {
                cell.pendingButton.isHidden = false
                cell.acceptView.isHidden = true
            } else {
                cell.pendingButton.isHidden = true
                cell.acceptView.isHidden = false
            }
            
            if let name = requestArray[indexPath.row]["username"] as? String {
                cell.nameLabel.text = name
            }
            
            if let pic = requestArray[indexPath.row]["profile_photo"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,pic)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.profileImage {
                        cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
            
            cell.acceptButton.tag = indexPath.row
            cell.rejectButton.tag = indexPath.row
            cell.acceptButton.addTarget(self, action: #selector(acceptButtonClicked), for: .touchUpInside)
            cell.rejectButton.addTarget(self, action: #selector(rejectButtonClicked), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    @objc func acceptButtonClicked(_ sender : UIButton) {
        var userId = ""
        if let id = requestArray[sender.tag]["user_id"] as? String {
            userId = id
            self.acceptRejectCommunity(userId, isAccept: true)
            
        }
        
    }
    
    @objc func rejectButtonClicked(_ sender: UIButton) {
        var userId = ""
        if let id = requestArray[sender.tag]["user_id"] as? String {
            userId = id
            self.acceptRejectCommunity(userId, isAccept: false)
        }
    }
}
