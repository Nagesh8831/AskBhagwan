//
//  DownloadsTableViewController.swift
//  spotimusic
//
//  Created by appteve on 06/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.

//Sandy's UDID
//826f102a450b1638eb9a0a5b86242cbf98911860

import UIKit
import SWRevealViewController
import CoreData
import Kingfisher
import Reachability
import SVProgressHUD
import Alamofire
import CoreData
import SCLAlertView
import AVKit
import AVFoundation
class DownloadsViewController: TableViewController, DirectoryWatcherDelegate ,AVPlayerViewControllerDelegate{
    var reachabilitysz: Reachability!
    var downloadArray = [Any]()
    var media_type_id : String?
    var downloadFile : [NSManagedObject]?
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var object : SampleQueueId!
    var audioPlayer : STKAudioPlayer!
    var subscriptionStatus  = false
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    var adsTimer: Timer!
    let kAPPKEY = "a4fd26cd"
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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadsViewController.reloadData), name: NSNotification.Name(rawValue: NewFilesAvailableNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadsViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIronSourceSdk()
        // AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with:  [AVAudioSession.CategoryOptions.duckOthers])
        //try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "commonTableCell")
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
        }
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
       // reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{
        } else {
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Download"
        self.clearsSelectionOnViewWillAppear = false
        self.downloadFile = Utilities.fetchObjectByEntity(entity: "DownloadedFile", predicate: nil)
        if let  download = downloadFile {
            for obj in download {
                self.downloadArray.append(obj)
            }
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        adsTimer =  Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        if downloadArray.count > 0 {
        }else{
            let message = UILabel()
            message.text = "No downloaded files"
            message.translatesAutoresizingMaskIntoConstraints = false
            message.textColor = UIColor.white
            message.textAlignment = .center
            self.view.addSubview(message)
            message.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            message.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
    }
    @objc func callBack(){
       // print("timer",adsTimer)
       subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
           if playerController.player?.rate != nil {
                self.playerController.player!.pause()
            }
            IronSource.showRewardedVideo(with: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
       // adsTimer.invalidate()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        media_type_id = "1"
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func playSong(sender : UIButton){
        if subscriptionStatus == true {
            print("User subscribed")
        UserDefaults.standard.set(true, forKey: "isFromDownloadPlay")
        UserDefaults.standard.synchronize()
        let selectedRadio = downloadArray[sender.tag]
        _ =  (selectedRadio as AnyObject).value(forKey: "type") as? String
        _ =  (selectedRadio as AnyObject).value(forKey: "name") as? String
        let  imageName =  (selectedRadio as AnyObject).value(forKey: "imageName") as? String
        _ =  (selectedRadio as AnyObject).value(forKey: "fileID") as? String
        _ =  (selectedRadio as AnyObject).value(forKey: "id") as? String
        _ =  (selectedRadio as AnyObject).value(forKey: "artist") as? String
        _ =  (selectedRadio as AnyObject).value(forKey: "plays") as? String
        var  fileurl  = ""
        var imgUrl = ""
            fileurl =  (selectedRadio as AnyObject).value(forKey: "url") as? String ?? ""
            imgUrl =  (selectedRadio as AnyObject).value(forKey: "imageName") as? String ?? ""

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController
        vc.isFromDownloadedSong = true
        vc.songURL = fileurl
        vc.songImageURL = imgUrl
        vc.imagName = imageName!
        self.navigationController?.pushViewController(vc, animated: true)
    }else {
        let alert = UIAlertController(title: "Please subscribe for playing audios/videos", message: "OOPS no subscribe plan for this month, Lets Make Payment", preferredStyle: .alert)
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



//          let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        let oldPath = fileurl.prefix(86)
//        print("oldPath",oldPath)
//        let updateFile = UserDefaults.standard.value(forKey: "basePath") as! String
//     let file_url =   fileurl.replacingOccurrences(of: oldPath, with: updateFile)
//        print(file_url)
//       // dirPath /var/mobile/Containers/Data/Application/CCC4AAF3-5593-4433-B320-5126500501CB/Documents
//        let pathArray = fileurl.components(separatedBy: "/")
//        var strPath = "music/"
//        strPath.append((pathArray.last ?? nil)!)
//        if let pathComponent = url.appendingPathComponent(strPath) {
//            let filePath = pathComponent.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                print("FILE AVAILABLE")
//            } else {
//                print("FILE NOT AVAILABLE")
//            }
//        } else {
//            print("FILE PATH NOT AVAILABLE")
//        }
//        let destURL = URL.init(fileURLWithPath: file_url)
//        _ = AVURLAsset(url: destURL).duration.seconds
//         let destURL1 = URL.init(fileURLWithPath: imgUrl)
//        print("destURL1",destURL1)
//            print(sender.tag)
//            print("file path of bundle songs =",file_url)
//            let player = AVPlayer(url: URL(fileURLWithPath: file_url))
//        if file_url.contains(".mp4") || file_url.contains(".m4v") {
//            playerController.contentOverlayView?.isHidden = true
//        }else {
//            let playerCoverImageView = UIImageView.init(image: UIImage.init(named: "os_ho.jpg"))
//            playerCoverImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//
//            playerCoverImageView.center = self.view.center
//            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageName!)
//            let url = URL(string: imgeFile)
//            DispatchQueue.main.async(execute: {
//                    playerCoverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
//            })
//            playerController.contentOverlayView?.isHidden = false
//            playerController.contentOverlayView?.addSubview(playerCoverImageView)
//        }
//        sender.isEnabled = false
//        playerController.player = player
//        AudioPlayer.sharedAudioPlayer.pause()
//        sender.isEnabled = false
//        present(playerController, animated: true) {
//            self.playerController.player!.play()
//            MiniPlayerView.sharedInstance.removeFromSuperview()
//            UIView.animate(withDuration: 1, animations: {
//                sender.isEnabled = true
//            })
//        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return downloadArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        cell.unlockButton.isHidden = true
        cell.downloadSongTagButton.isHidden = true
        //cell.descriptionLabel.text = "Jokes"
        //cell.commonImageView.layer.borderColor = UIColor.gray.cgColor
        cell.commonImageView.layer.borderWidth = 1.0
        cell.downloadButton.isHidden = true
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playSong(sender:)), for: .touchUpInside)
        cell.shareButton.isHidden = true
        cell.shareButtonWidthConstarint.constant = 0
        let mainDta = self.downloadArray[indexPath.row] as! NSManagedObject
        print("maindata",mainDta)
        let type = mainDta.value(forKey: "type") as? String
        if type == "Audio" {
            let name = mainDta.value(forKey: "name") as? String
            let name1 = mainDta.value(forKey: "id") as? String
            print("name",name ?? "")
            let imageUrl = mainDta.value(forKey: "imageName") as? String
            //print("imageUrl",imageUrl)
            let type = mainDta.value(forKey: "type") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
            let url = URL(string: imgeFile)
            cell.playButton.accessibilityHint = type
            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
                cell.commonName.text = name
            })
        } else {
            let name = mainDta.value(forKey: "name") as? String
            //print("name",name)
            let imageUrl = mainDta.value(forKey: "imageName") as? String
            //print("imageUrl",imageUrl)
            let type = mainDta.value(forKey: "type") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
            let url = URL(string: imgeFile)
            cell.playButton.accessibilityHint = type
            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
                cell.commonName.text = name
            })
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Downloads",message: "Are you sure you want to delete?", preferredStyle: .alert)
            let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                print("Yes")
                print("Deleted")
                let mainDta = self.downloadArray[indexPath.row] as! NSManagedObject
                let fileId =  (mainDta as AnyObject).value(forKey: "fileID") as? String
                let fileurl =  (mainDta as AnyObject).value(forKey: "url") as? String ?? ""
                if (Utilities.deleteObject(entity: "DownloadedFile", predicate: fileId!)) {
                    var error: NSError?
                    if fileurl != "" {
                        let url =  URL(fileURLWithPath: fileurl)
                        DataManager.removeFile(url, error: &error)
                    }
                    Utilities.displayToastMessage("Song deleted successfully..")
                    
                    self.songs = DataManager.audioFiles()
                    self.downloadArray.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            let cancleEvent = UIAlertAction(title: "Cancel", style: .default) { (_) -> Void in
                print("No")
            }
            alert.addAction(addEvent)
            alert.addAction(cancleEvent)
            present(alert, animated: true, completion:  nil)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.tableView.setEditing(editing, animated: animated)
    }
    func refreshControlValueChanged(_ refreshControl: UIRefreshControl!) {
    }
    @objc func reloadData() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async { () -> Void in
            self.songs = DataManager.audioFiles()
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    @objc func playerDidStartPlaying() {
    }
    func directoryDidChange(_ folderWatcher: DirectoryWatcher!) {
        self.reloadData()
    }
}
extension DownloadsViewController : ISRewardedVideoDelegate {
    func setupIronSourceSdk() {
        ISIntegrationHelper.validateIntegration()
        // Before initializing any of our products (Rewarded video, Offerwall or Interstitial) you must set
        // their delegates. Take a look at these classes and you will see that they each implement a product
        // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
        // we will not be able to communicate with you.
        // We're passing 'self' to our delegates because we want
        // to be able to enable/disable buttons to match ad availability.
       // IronSource.setInterstitialDelegate(self)
        //IronSource.add(self)
        IronSource.setRewardedVideoDelegate(self)
        IronSource.initWithAppKey(kAPPKEY)
        // To initialize specific ad units:
//        IronSource.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL,IS_BANNER])
    }
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        print("RV Availbel")
    }

    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        print("RV Received")
        if playerController.player?.rate != nil {
             self.playerController.player!.pause()
         }
        AudioPlayer.sharedAudioPlayer.pause()
        if player != nil && player.rate != 0 {
            player.pause()
            playerController.player?.pause()
        }
    }

    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print("Rv Failed to show")
        if playerController.player?.rate != nil {
             self.playerController.player!.pause()
         }
        AudioPlayer.sharedAudioPlayer.pause()
        if player != nil && player.rate != 0 {
            player.pause()
            playerController.player?.pause()
        }
        //player.play()
        //Utilities.displayToastMessage("ads not present")
        //AudioPlayer.sharedAudioPlayer.resume()
        //IronSource.showRewardedVideo(with: self)
    }

    func rewardedVideoDidOpen() {
        IronSource.showRewardedVideo(with: self)
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidClose() {
        if playerController.player?.rate != nil {
             self.playerController.player!.pause()
         }
        if player != nil && player.rate != 0 {
            player.pause()
            playerController.player?.pause()
        }
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                self.player.pause()
                self.playerController.player?.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubsciptionPlanViewController") as! SubsciptionPlanViewController
                vc.isFromMusicPlayer = false
                self.navigationController?.pushViewController(vc, animated: true)
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
               // self.player.play()
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

    func rewardedVideoDidStart() {
        //self.isAdClosed = true
        //print("RV Start",isAdClosed)
        //player.pause()
        if playerController.player?.rate != nil{
             self.playerController.player!.pause()
         }
        if player != nil && player.rate != 0 {
            player.pause()
            playerController.player?.pause()
        }
    }

    func rewardedVideoDidEnd() {
       // self.isAdClosed = true
       // print("RV End",isAdClosed)
    }

    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        if playerController.player?.rate != nil {
             self.playerController.player!.pause()
         }
        if player != nil && player.rate != 0 {
            player.pause()
        }
        //self.isAdClosed = true
        //print("RV clicked",isAdClosed)
    }


}
