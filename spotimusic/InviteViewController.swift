//
//  InviteViewController.swift
//  spotimusic
//
//  Created by Ravi Deshmukh on 25/07/18.
//

import UIKit
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SCLAlertView
import SVProgressHUD

class InviteViewController: UIViewController {

    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var friendArray = [[String:AnyObject]]()
    var searchActive : Bool = false
    var searchText = ""
    var parentId = ""
    var userId = ""
    var communityId = ""
     var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchBar.searchTextField.textColor = .white
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        friendsTableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
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
        searchUser(searchText)
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

}


extension InviteViewController {
    func searchUser(_ searchText : String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "searchterm":searchText,
            "limit":500,
            "offset":0
            ] as [String : Any]
        APICall.searchUser(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                if let result = data["respon"] as? [[String:AnyObject]] {
                    weakSelf.friendArray = result
                    weakSelf.noDataLabel.isHidden = true
                    weakSelf.friendsTableView.reloadData()
                } else {
                    if let message = data["message"] as? String {
                        self?.noDataLabel.isHidden = false
                        self?.noDataLabel.text = message
                        self?.friendsTableView.isHidden = true
                    }
                }
            })
        }
    }
    
    func addUserToCommunity(_ userId : String , communityId : String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "parent_user_id": parentId,
            "community_id": communityId,
            "user_id": userId,
            "request": 1
            ] as [String : Any]
        APICall.addUserToCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                //print("data::::\(data)")
                if let message = data["message"] as? String {
                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                    }
                    let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                     SCLAlertView().showTitle("Ask Bhagwan", subTitle: message, timeout:time, completeText: "Done", style: .success)
                }
            })
        }
    }
}

extension InviteViewController  : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        cell.contentView.backgroundColor = UIColor.clear
        
        if let userName = friendArray[indexPath.row]["username"] as? String {
            cell.nameLabel.text = "\(userName)"
        }
        
        if let email = friendArray[indexPath.row]["email"] as? String {
            cell.adminLabel.text = "\(email)"
        }
        if let cover = friendArray[indexPath.row]["profile_photo"] as? String {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,cover)
            //print("imgeFile",imgeFile)
            let url = URL(string: imgeFile)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.profileImageView {
                    cell.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var name = ""
        if let username = self.friendArray[indexPath.row]["username"] as? String {
            name = username
        }
        let alert = UIAlertController(title: "Add Friend",message: "Are you sure you want to add \(name)?", preferredStyle: .alert)
        let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
            //print("Yes")
            if let id = self.friendArray[indexPath.row]["id"] as? String {
                self.userId = id
                self.addUserToCommunity(self.userId, communityId: self.communityId)
            }
        }
        let cancleEvent = UIAlertAction(title: "No", style: .cancel) { (_) -> Void in
        }
        
        alert.addAction(addEvent)
        alert.addAction(cancleEvent)
        present(alert, animated: true, completion:  nil)
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}

extension InviteViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.searchUser(searchText)
    }
}
