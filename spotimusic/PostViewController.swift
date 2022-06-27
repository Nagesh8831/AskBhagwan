//
//  PostViewController.swift
//  spotimusic
//
//  Created by Ravi Deshmukh on 25/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
class PostViewController: UIViewController ,AVPlayerViewControllerDelegate{

    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var postArray = [[String:AnyObject]]()
    var communityId = ""
    var parentId = ""
    var communityName = ""
    var trackType = String()
     var reachabilitysz: Reachability!
    var songs: [Audio] = [Audio]() {
        didSet {
            self.playlist = Playlist(audios: songs)
        }
    }

    var playlist: Playlist? {
        didSet {
            AudioPlayer.sharedAudioPlayer.playlist = playlist
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with:  [AVAudioSession.CategoryOptions.duckOthers])
       // try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: nil), forCellReuseIdentifier: "eventsCell")
     //   reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        segment.selectedSegmentIndex = 0
        self.getAllPost()
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
       
        self.title = communityName
        if let userId = UserDefaults.standard.value(forKey: "user_id") as? String , userId == parentId {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(named: "addFriend"), for: .normal)
            //btn1.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            btn1.frame.size = CGSize(width: 24, height: 24)
            btn1.addTarget(self, action: #selector(inviteUser(sender:)), for: .touchUpInside)
            let searchButton = UIBarButtonItem(customView: btn1)
            searchButton.tintColor = UIColor.white
            let btn2 = UIButton(type: .custom)
            btn2.setImage(UIImage(named: "friends"), for: .normal)
            btn2.frame.size = CGSize(width: 24, height: 24)
            btn2.addTarget(self, action: #selector(showFriends(sender:)), for: .touchUpInside)
            let addNewCommunity = UIBarButtonItem(customView: btn2)
            addNewCommunity.tintColor = UIColor.white
            self.navigationItem.setRightBarButtonItems([searchButton, addNewCommunity], animated: true)
        } else {
            let btn2 = UIButton(type: .custom)
            btn2.setImage(UIImage(named: "friends"), for: .normal)
            btn2.frame.size = CGSize(width: 24, height: 24)
            btn2.addTarget(self, action: #selector(showFriend(sender:)), for: .touchUpInside)
            let addNewCommunity = UIBarButtonItem(customView: btn2)
            addNewCommunity.tintColor = UIColor.white
            self.navigationItem.setRightBarButtonItems([addNewCommunity], animated: true)
        }
        
        segment.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
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
    @objc func tapSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
             getAllPost()
        }else {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                controller.communityId = communityId
                navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }
    
    
    @objc func inviteUser(sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteViewController") as! InviteViewController
        vc.parentId = parentId
        vc.communityId = communityId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showFriends(sender:UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendRequestViewController") as! FriendRequestViewController
        vc.communityId = communityId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showFriend(sender:UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        vc.communityId = communityId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func postComment(){
     //   SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_COMMUNITY_COMMENT_POST)
        //print(urlResponce)
        
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"user_id" : "","community_id":1])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success:
                    print("Comments",response)
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
    
    func getAllCommentByCommunityId() {
       // SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_COMMUNITY_GET_ALL_COMMENT_POST + "29" + ADD_LIMIT)
       
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success:
                    print("AllComments",response)
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
    @IBAction func sendCommentButtonAction(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PostViewController {
    func getAllPost() {
        APICall.getAllPost(communityId) { (data) in
            DispatchQueue.main.async(execute: {
                if let status = data["status"] as? Bool {
                    if status == true {
                        if let dictionaryArray = data["resultObject"]  as? [[String : AnyObject]] {
                            print("AllPOst",dictionaryArray)
                            if dictionaryArray.count > 0 {
                                self.postArray = dictionaryArray
                                self.noDataLabel.isHidden = true
                                self.tableView.reloadData()
                            } else {                                    self.noDataLabel.isHidden = false
                                    self.noDataLabel.text = "No post available for community"
                                    self.tableView.isHidden = true
                              
                            }
                        }
                        SVProgressHUD.dismiss()
                    }
                }
            })
        }
    }
    @objc func playButtonClicked(sender: UIButton) {
        let selectedRadio = postArray[sender.tag]
        
        let file_type = selectedRadio["file"] as? String
        
        if let track_type = selectedRadio["track_type"] as? String , let file_type = selectedRadio["file"] as? String ,track_type == "5"  ||  file_type.contains(".mp4") {
            
            let videoUrl = selectedRadio["file"] as? String
            guard let videourl = videoUrl else {return}
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController
            vc.videoURLStr = videoUrl!
                //adsTimer.invalidate()
            self.navigationController?.pushViewController(vc, animated: true)
//            let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,videourl)
//
//
//
//           // guard let videourl = videoUrl else {return}
//          //  let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,videourl)
//            print("videoFile",videoFile)
//
//            let urlStr : NSString = videoFile.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
//            let searchURL : NSURL = NSURL(string: urlStr as String)!
//            print(searchURL)
//            let url =  URL(string: videoFile)
//           // print("videoFile",url)
//            let player = AVPlayer(url: searchURL as URL)
//            playerController.player = player
//
//
//
////            let url =  URL(string: videoFile)
////
////            let player = AVPlayer(url: url!)
////            print("videoUrl",url)
////            playerController.player = player
//            AudioPlayer.sharedAudioPlayer.pause()
//            MiniPlayerView.sharedInstance.removeFromSuperview()
//            sender.isEnabled = false
//            present(playerController, animated: true) {
//                self.playerController.player!.play()
//                MiniPlayerView.sharedInstance.removeFromSuperview()
//                UIView.animate(withDuration: 1, animations: {
//                    sender.isEnabled = true
//                })
//            }
        } else {
            let song = Audio(soundDictonary: selectedRadio as! NSDictionary)
            self.songs = [song]
            let count = self.songs.count
            let x = UInt32(count)
            let randomIdx = Int(arc4random_uniform(x)+0)
            
            GLOBAL_CONTROLLER = "radio"
            
            if let track = self.playlist?.trackAtIndex(randomIdx) {
                
                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                AudioPlayer.sharedAudioPlayer.play(track)
            }
            let mainDta = self.postArray[sender.tag] as NSDictionary
            
            let name = mainDta.value(forKey: "name") as? String
            UserDefaults.standard.set(name, forKey: "audioFileName")
            UserDefaults.standard.synchronize()
            let imageUrl = mainDta.value(forKey: "cover") as? String
            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
            UserDefaults.standard.synchronize()
            let controller = RadioStreamViewController.sharedInstance
            controller.isFromCommunity = true
            controller.isFromHome = false
            controller.isFromPlayList = false
            controller.isFromRecentPlayList = false
            controller.isFromAudios = false
            controller.isFromQA = false
            controller.indexOfSong = 0
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
}

extension PostViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell
        cell.contentView.backgroundColor = UIColor.clear
        cell.peopleImage.isHidden = false
        cell.contentView.backgroundColor = UIColor.clear
         let track_Type = postArray[indexPath.row]["track_type"] as? String
        
         let fileName = postArray[indexPath.row]["file"] as? String
        
        if track_Type == "1" ||  track_Type == "2" || track_Type == "3" || track_Type == "4" || track_Type == "7" ||  track_Type == "8" ||  track_Type == "9"{
            cell.startDateLabel.isHidden = true
            cell.endDateLabel.isHidden = true
            if let trackName = postArray[indexPath.row]["track_name"] as? String {
                cell.trackNameLabel.text = trackName
            }
            
            if let userName = postArray[indexPath.row]["username"] as? String , let date = postArray[indexPath.row]["createdAt"] as? String {
                cell.descriptionLabel.text = "Post shared by \(userName) on \(date)"
            }
            
            if let cover = postArray[indexPath.row]["cover"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,cover)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.coverImageView {
                        cell.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
        }else  if track_Type == "5"{
          
            cell.contentView.backgroundColor = UIColor.clear
            cell.startDateLabel.isHidden = true
            cell.endDateLabel.isHidden = true
            cell.peopleImage.isHidden = false
            cell.contentView.backgroundColor = UIColor.clear
            if let trackName = postArray[indexPath.row]["track_name"] as? String {
                cell.trackNameLabel.text = trackName
            }
            
            if let userName = postArray[indexPath.row]["username"] as? String , let date = postArray[indexPath.row]["createdAt"] as? String {
                cell.descriptionLabel.text = "Post shared by \(userName) on \(date)"
                
            }
            
            if let cover = postArray[indexPath.row]["cover"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,cover)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.coverImageView {
                        cell.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
        }else if track_Type == "6"{
         
            cell.contentView.backgroundColor = UIColor.clear
            cell.imageWidth.constant = 0
            cell.contentView.backgroundColor = UIColor.clear

            cell.playButton.isHidden = true
            cell.peopleImage.isHidden = true
            if let trackName = postArray[indexPath.row]["track_name"] as? String {
                cell.trackNameLabel.text = trackName
            }
            
            if let address = postArray[indexPath.row]["file"] as? String , let date = postArray[indexPath.row]["createdAt"] as? String , let to_date = postArray[indexPath.row]["to_date"] as? String , let from_date = postArray[indexPath.row]["from_date"] as? String {
                cell.descriptionLabel.text = address
                cell.startDateLabel.text = "Start:\(from_date.stringFromUTCDate(format: SHORT_DATE_FORMAT))"
                cell.endDateLabel.text = "End:\(to_date.stringFromUTCDate(format: SHORT_DATE_FORMAT))"
            }
            
            if let cover = postArray[indexPath.row]["cover"] as? String {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,EVENTS,cover)
                //print("imgeFile",imgeFile)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.coverImageView {
                        cell.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }
        }
    
        
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
             return cell

       
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
