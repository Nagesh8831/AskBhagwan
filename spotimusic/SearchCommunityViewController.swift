//
//  SearchCommunityViewController.swift
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

class SearchCommunityViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var tableView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataLabel: UILabel!
    var items = [[String:AnyObject]]()
    var searchText = ""
    var searchActive = false
    //var parentId = ""
     var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
         tableView.backgroundView = UIImageView(image: UIImage(named: "screen_1"))
         tableView.dataSource = self
         tableView.delegate = self
       // searchBar.searchTextField.textColor = .white
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont(name:"HelveticaNeue", size: 20)!]

       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
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
        searchCommunity(searchText)


        self.title = "Search Community"
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
    
    
    func searchCommunity(_ searchText : String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "searchterm":searchText,
            "limit":500,
            "offset":0
            ] as [String : Any]
        APICall.searchCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
               print("data::::\(data)")
                if let result = data["respon"] as? [[String:AnyObject]] {
                    weakSelf.items = result
                    if (self?.items.count)! > 0 {
                        weakSelf.tableView.reloadData()
                        self?.noDataLabel.isHidden = true
                        self?.tableView!.isHidden = false
                    }else {
                        self?.view.bringSubviewToFront((self?.noDataLabel)!)
                        self?.noDataLabel.isHidden = false
                        self?.noDataLabel.text = "No community found"
                        self?.tableView!.isHidden = true
                    }
//
                }
            })
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "communityCell", for: indexPath) as! CommunityCollectionViewCell
        let mainDta = self.items[indexPath.row] as NSDictionary
        
        if  let name = mainDta.value(forKey: "name") as? String{
            
            
            DispatchQueue.main.async(execute: {
                cell.communityName.text = name
            })
        }
        
        
        let imageUrl = mainDta.value(forKey: "image_url") as? String
         if imageUrl != "" {
        let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,COMMUNITY,imageUrl!)
        
        let url = URL(string: imgeFile)
        if let url = URL(string: imgeFile){
           if let _ = cell.communityImage {
                cell.communityImage.kf.setImage(with: url, placeholder: UIImage(named: "Image-5"))
            }

        } else {
        }
         }else {
             cell.communityImage.image = UIImage(named: "Image-5")
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let userId = GLOBAL_USER_ID {
            var name = ""
                  if let username = self.items[indexPath.row]["name"] as? String {
                      name = username
                  }
                  let alert = UIAlertController(title: "Join Community",message: "Are you sure you want to join this \(name)?", preferredStyle: .alert)
                  let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                      //// // print("Yes")
                      if let id = self.items[indexPath.row]["id"] as? String , let parentId = self.items[indexPath.row]["parent_user_id"] as? String {
                        self.addUserToCommunity(userId.stringValue, communityId: id, parentId: parentId)
                      }
                  }
                  let cancleEvent = UIAlertAction(title: "No", style: .cancel) { (_) -> Void in
                  }
                  
                  alert.addAction(addEvent)
                  alert.addAction(cancleEvent)
                  present(alert, animated: true, completion:  nil)
        }
      
        
    }
    
    func addUserToCommunity(_ userId : String , communityId : String, parentId: String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "parent_user_id": parentId,
            "community_id": communityId,
            "user_id": userId,
            "request": 2
            ] as [String : Any]
        // // print(parameter)
        APICall.addUserToCommunity(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                // // print("data::::\(data)")
                if let message = data["message"] as? String {
                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                    }
                    let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                    SCLAlertView().showTitle("Ask Bhagwan", subTitle: message, timeout: time, completeText: "Done", style: .success)
                }
            })
        }
    }
}

extension SearchCommunityViewController : UISearchBarDelegate {
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
        self.searchCommunity(searchText)
    }
}
