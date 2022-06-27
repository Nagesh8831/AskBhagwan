//
//  CommunityViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 22/06/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
class CommunityViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    
    var subscriptionStatus  = false
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    var items = [[String:AnyObject]]()
    var communityArray = [[String:AnyObject]]()
    var userIds: String!
    var comm_Name : String?
    var comm_Id : String?
    var comm_image : String?
    var userID = ""
    var updateCommunityName : String?
    var updateCommunityImage : String?
    var updateCommunityId : String?
    var isUpdate = false
    var refreshControl: UIRefreshControl!
    var adsTimer: Timer!
    @IBOutlet weak var communityCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
                   reachabilitysz = try Reachability()
               }catch{
               }
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()	
        } else {
        }
  
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.communityCollectionView.addSubview(self.refreshControl)
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Community"
    }
    @objc func pullToRefreshHandler() {
        self.communityCollectionView.reloadData()
        self.refreshControl.endRefreshing()
        // refresh table view data here
    }
    override func viewWillAppear(_ animated: Bool) {
        if let user = UserDefaults.standard.value(forKey: "loginUserID") {
            userID = user as! String
            print(userID)
        }
       adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
//        if let us = GLOBAL_USER_ID {
//            userID = us.stringValue
//            print(userID)
//        }
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        self.getAllCommunityByUserId()
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
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "search"), for: .normal)
        //btn1.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        btn1.frame.size = CGSize(width: 24, height: 24)
        btn1.addTarget(self, action: #selector(searchBTNClicked(sender:)), for: .touchUpInside)
        let searchButton = UIBarButtonItem(customView: btn1)
        searchButton.tintColor = UIColor.white
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "addCommunity"), for: .normal)
        btn2.frame.size = CGSize(width: 24, height: 24)
        btn2.addTarget(self, action: #selector(addCommunityButtonClicekd(sender:)), for: .touchUpInside)
        let addNewCommunity = UIBarButtonItem(customView: btn2)
        addNewCommunity.tintColor = UIColor.white
        self.navigationItem.setRightBarButtonItems([addNewCommunity,searchButton], animated: true)
        self.communityCollectionView!.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }

    @objc func callBack(){
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showAdds()
            //IronSource.showRewardedVideo(with: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func searchBTNClicked(sender: UIButton) {
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchCommunityViewController") as! SearchCommunityViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addCommunityButtonClicekd(sender:UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCommunityViewController") as! AddCommunityViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAllCommunityByUserId(){
        SVProgressHUD.show()
        self.items.removeAll()
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_GET_ALL_COMMUNITY_BY_USER_ID + userID)
            print("urlResponce",urlResponce)
             Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                 .responseJSON { response in
                     SVProgressHUD.dismiss()
                     switch response.result {
                     case .success :
                         
                         guard let itms = response.result.value else {return}
                         let itemss = itms as! NSDictionary
                         self.communityArray = itemss.value(forKey: "resultObject") as! [[String:AnyObject]]
                         
                         if let data = self.communityArray as? [[String:AnyObject]] {
                             for i in (0..<data.count)
                             {
                                 if let dict = data[i] as? [String:AnyObject] , let id1 = dict["parent_user_id"] as? String ,  self.userIds == id1  {
                                     if let action = dict["action"] as? String , action == "2" || action == "0" {
                                         self.items.append(dict)
                                     }
                                     
                                 } else {
                                     if let dict = data[i] as? [String:AnyObject] , let action = dict["action"] as? String , action == "2"  || action == "1" {
                                         self.items.append(dict)
                                     }
                                 }
                             }
                             
                         }
                         DispatchQueue.main.async() {
                             self.communityCollectionView!.reloadData()
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if items.count > 0 {
            return self.items.count
            
        } else {
          // reachabilitysz = Reachability()
            do {
                reachabilitysz = try Reachability()
            }catch{
                       
            }
            if (reachabilitysz?.isReachable)!{
                
            } else {
            }
            return 0
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "communityCell", for: indexPath) as! CommunityCollectionViewCell
        let mainDta = self.items[indexPath.row] as NSDictionary
        
        if  let name = mainDta.value(forKey: "community_name") as? String{
             comm_Name = name
        DispatchQueue.main.async(execute: {
            cell.communityName.text = name
        })
        }
       // if let userId = GLOBAL_USER_ID {
            if let id = mainDta.value(forKey: "parent_user_id") as? String , id == userID {
                cell.starImageView.isHidden = false
                cell.updateButton.isHidden = false
            } else {
                cell.starImageView.isHidden = true
                cell.updateButton.isHidden = true
            }
        //}
        

        if let action = mainDta.value(forKey: "action") as? String , action == "1" {
            cell.pendingLabel.isHidden = false
        } else {
            cell.pendingLabel.isHidden = true
            cell.pendingLabelHight.constant = 0
        }

        let imageUrl = self.items[indexPath.row]["image_url"] as? String

       if imageUrl != "" {
        let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,COMMUNITY,imageUrl!)
       print("imagePath",imgeFile)//

        let url = URL(string: imgeFile)
       // print("imageurl",url!)
        if let url = URL(string: imgeFile){
            if let _ = cell.communityImage {
                cell.communityImage.kf.setImage(with: url, placeholder: UIImage(named: "Image-5"))
            }
        } else {
            cell.communityImage.image = UIImage(named: "Image-5")
        }
       }else {
        cell.communityImage.image = UIImage(named: "Image-5")
        }
        cell.starImageView.tag = indexPath.row

        cell.updateButton.tag = indexPath.row
       cell.updateButton.addTarget(self, action: #selector(updateCommunity), for: .touchUpInside)
        comm_image = imageUrl
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding

        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = items[indexPath.row]["action"] as? String , action != "1" {
            
        if let id = items[indexPath.row]["id"] as? String , let parentId = items[indexPath.row]["parent_user_id"] as? String  ,let commName = items[indexPath.row]["community_name"] as? String{
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            secondViewController.communityId = id
            secondViewController.parentId = parentId
            secondViewController.communityName = commName
            
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
            
        } else {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "Your request sent to community Admin, please wait for approval", timeout: time, completeText: "Done", style: .success)
        }
    }
    
    @objc func updateCommunity(sender : UIButton){
        let alert = UIAlertController(title: "ASK Bhagwan", message: "Please select action from below", preferredStyle: .actionSheet)
         let mainDta = self.items[sender.tag] as NSDictionary
        self.comm_Id = mainDta.value(forKey: "id") as? String
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            print("Edit button tapped")
            self.isUpdate = true
            self.updateCommunityId = mainDta.value(forKey: "id") as? String
           self.updateCommunityName = mainDta.value(forKey: "community_name") as? String
            self.updateCommunityImage = mainDta.value(forKey: "image_url") as? String
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddCommunityViewController") as! AddCommunityViewController
            
            vc.isUpdate = true
            vc.update_CommunityId =  self.updateCommunityId
            vc.update_CommunityName =  self.updateCommunityName
            vc.update_CommunityImage =  self.updateCommunityImage
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in

            self.alertUser(title: "", message: "Are you sure you want to delete?")
            //self.deleteCommunity(_communityId: self.comm_Id ?? "")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel button tapped")
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension CommunityViewController {
    func deleteCommunity(_communityId : String) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
       // if  let  userId = GLOBAL_USER_ID {
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_DELETE_COMMUNITY)
            
          //  print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"community_id":comm_Id!,"parent_user_id":userID])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success :
                        self.getAllCommunityByUserId()
                       // print("response",response)
                        guard let item = response.result.value as! NSDictionary? else {return}
                        if let message = item.value(forKey: "message") as? String {
                            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                            }
                            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                            SCLAlertView().showTitle("Delete Community", subTitle: message, timeout: time, completeText: "Done", style: .success)
                            self.navigationController?.popViewController(animated: true)
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

        //}
    }
}
extension CommunityViewController {
    
    func alertUser (title : String , message: String){
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let addEvent = UIAlertAction(title: "Delete", style: .default) { (_) -> Void in
            print("Yes")
            self.deleteCommunity(_communityId: self.comm_Id ?? "")
            
        }
        let cancleEvent = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            print("No")
        }
        
        alert.addAction(addEvent)
        alert.addAction(cancleEvent)
        present(alert, animated: true, completion:  nil)
    }
}


