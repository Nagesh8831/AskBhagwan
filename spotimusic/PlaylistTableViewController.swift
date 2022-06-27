//
//  PlaylistTableViewController.swift
//  spotimusic
//
//  Created by appteve on 09/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import SWRevealViewController
import CoreData
import Reachability
import SVProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PlaylistTableViewController: UITableViewController {
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    var subscriptionStatus  = false
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var allPlist: NSArray!
    var count = 0
    var sourceScreeIdentifier: String = ""
    var playListID : String = ""
    var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
       // createBanner()
        
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        
        if sourceScreeIdentifier == "Home" {
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "m_back"), for: UIBarMetrics.default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.white
            
            self.clearsSelectionOnViewWillAppear = false
        } else {
        
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
            
            self.clearsSelectionOnViewWillAppear = false
            self.title =  "Playlist"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if sourceScreeIdentifier == "Home" {
            
        } else {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        fetchDataList()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBar), name: NSNotification.Name(rawValue: "showProgressBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBarError), name: NSNotification.Name(rawValue: "showProgressBarError"), object: nil)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
    }
    func showPreSubscriptionPopUp(){
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "OOPS no subscribe plan for this month, Lets Make Payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubsciptionPlanViewController") as! SubsciptionPlanViewController
                vc.isFromMusicPlayer = false
                self.navigationController?.pushViewController(vc, animated: true)
               // self.present(vc, animated: true, completion: nil)
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
                  // self.navigationController?.popViewController(animated: true)
                switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                 case
                 STKAudioPlayerState(),
                 STKAudioPlayerState.paused :
                    AudioPlayer.sharedAudioPlayer.resume()
                    print("Resume")
                 default: break
                }
               })
               alert.addAction(saveAction)
               alert.addAction(noAction)
               DispatchQueue.main.async {
                   self.present(alert, animated: true, completion: nil)
               }
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    @objc func showProgressBar() {
    }
    @objc func showProgressBarError() {
    }
    
    func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        let mainDta = self.allPlist[index] as! NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            let fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchDataList(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@", BASE_URL_BACKEND, ENDPOINT_ALL_USER_PLIST)
        
      // print("allPalylisturlRequest",urlRequest)
        if let userId = GLOBAL_USER_ID {
            Alamofire.request( urlRequest, method: .post, parameters:["X-API-KEY": API_GENERAL_KEY,"user_id":userId.stringValue])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                        //  print ("All palylist",response)
                        guard let json = response.result.value else {return}
                        let JSON = json as! NSDictionary
                        
                        if let data = JSON.value(forKey: "respon") as? NSArray {
                            self.allPlist = data
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                        if self.allPlist.count > 0 {
                            
                        }else {
                            let message = UILabel()
                            message.text = "No playlist found"
                            message.translatesAutoresizingMaskIntoConstraints = false
                            message.textColor = UIColor.white
                            message.textAlignment = .center
                            self.view.addSubview(message)
                            message.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                            message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                            message.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
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
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (allPlist?.count)  < 0  {
            if (count < 2){
                fetchDataList()
            }
            count += 1
            return 0
        } else {
            return allPlist.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playCell", for: indexPath) as! PlaylistTableViewCell
       
        let data = allPlist.object(at: indexPath.row) as! NSDictionary
        cell.playlistName.text = data.value(forKey: "name") as? String
        playListID = (data.value(forKey: "id") as? String)!
        print("playListID",playListID)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = allPlist.object(at: indexPath.row) as! NSDictionary
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "trackinlist") as! TrackInListTableViewController
        vc.playlistId = data.value(forKey: "id") as! String
        vc.plalistTitle = data.value(forKey: "name") as! String
        navigationController?.pushViewController(vc, animated: true )
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let data = allPlist.object(at: indexPath.row) as! NSDictionary
           let playList_id = (data.value(forKey: "id") as? String)!
            let alert = UIAlertController(title: "My playlist",message: "Are you sure you want to delete?", preferredStyle: .alert)
            let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                print("Yes")
                AudioPlayer.sharedAudioPlayer.pause()
                self.deletePlayList(playList_id)
            }
            let cancleEvent = UIAlertAction(title: "Cancel", style: .default) { (_) -> Void in
                print("No")
            }
            
            alert.addAction(addEvent)
            alert.addAction(cancleEvent)
            present(alert, animated: true, completion:  nil)
 
        }
    }

    
    func deletePlayList (_ playListId : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@", BASE_URL_BACKEND,ENDPOINT_PLIST_DELETE)
         print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"id":playListId])
            .responseJSON { response in
                 SVProgressHUD.dismiss()
                
                switch response.result {
                case .success :
                    self.fetchDataList()
                    //print("Interview_response",response)
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPlaylistUser(){
        let alert = SCLAlertView()
        let txt = alert.addTextField("Playlist name")
        alert.addButton("Create") {
            let playlistName = txt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (txt.text == "" || playlistName == ""){
            }else {
                self.addPlaylistIn(txt.text!)
            }
        }
        alert.showEdit("My playlist", subTitle: "")
    }
    
    func addPlaylistIn(_ text:String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND, ENDPOINT_PLIST_ADD)
       // print(urlRequest)
        if let userId = GLOBAL_USER_ID {
            Alamofire.request( urlRequest,method: .post, parameters: ["X-API-KEY":API_GENERAL_KEY,"user_id":userId.stringValue,"name":text])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success :
                        self.fetchDataList()
                        
                        if let JSON = response.result.value {
                        print("JSON- - ?: \(JSON)")
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
    

}
