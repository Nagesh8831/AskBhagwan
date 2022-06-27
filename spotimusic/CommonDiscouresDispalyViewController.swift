//
//  CommonDiscouresDispalyViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 23/07/18.
//
import UIKit
import Alamofire
import MediaPlayer
import CoreData
import CZPicker
import SWRevealViewController
import KVNProgress
import Kingfisher
import SVProgressHUD
import MarqueeLabel
import SCLAlertView
import Reachability
import AVKit
import AVFoundation
class CommonDiscouresDispalyViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate{

    override var shouldAutorotate: Bool {
        return true
    }
    var subscriptionStatus  = false
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var addPlaylist : NSArray!
    var trackType = 1
    var trackIds: String!
    var reachabilitysz: Reachability!
    @IBOutlet weak var discourseNameLabel: UILabel!
    @IBOutlet weak var discouresIamgeView: UIImageView!
    @IBOutlet weak var discourseTableView: UITableView!
    var discourseName : String?
    var discourseImageName : String?
    var albumId : String?
    var discourseArray = [[String : AnyObject]]()
    var discourseVideoArray = [[String : AnyObject]]()
    var categoty : String?
    var downloadFiles = [NSManagedObject]()
    var isFromVideoDiscorse = false
    var adsTimer: Timer!
    var videoPlayUrl = ""
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
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommonDiscouresDispalyViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with:  [AVAudioSession.CategoryOptions.duckOthers])
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.discourseTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
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
    @objc func callBack(){
           subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                 if subscriptionStatus == true {
                     print("User subscribed")
                 }else {
                    showAdds()
                   // IronSource.showRewardedVideo(with: self)
                 }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
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
        }else{
            if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
         categoty = UserDefaults.standard.value(forKey: "category") as? String
        self.getAudioDiscourses()
        self.getVideoDiscources()
       // self.discouresIamgeView.image = discouresIamgeView.image
        discourseNameLabel.text = discourseName!
        if isFromVideoDiscorse {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,discourseImageName!)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                 if let _ = self.discouresIamgeView {
                     self.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
        }else {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,discourseImageName!)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                 if let _ = self.discouresIamgeView {
                     self.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }

    func showProgressBar() {

    }
    func showProgressBarError() {

    }
    func getAudioDiscourses(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES)
       // print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : discourseName!,"quedisc":2,"album_id": albumId!,"limit":500,"offset":0,"should_orderby_name": false])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success:
                    print("Discource_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.discourseArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                   // print("Array_response",self.discourseArray)
                    DispatchQueue.main.async() {
                        self.discourseTableView!.reloadData()
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
    
    
    func getVideoDiscources() {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_VIDEO_QA_DISCOURSES)
       // print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : discourseName!,"quedisc":2,"album_id": albumId!,"limit":500,"offset":0,"should_orderby_name": false])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success:
                    
                     print("VideoDiscource_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.discourseVideoArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                    
                    // print("Array_response",self.discourseArray)
                    DispatchQueue.main.async() {
                        self.discourseTableView!.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoty == "Audio" {
                return discourseArray.count
        }else {
            return discourseVideoArray.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        cell.commonImageView.isHidden = false
        if categoty == "Audio" {
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        cell.playingTrackGIFImageView.isHidden = true
        cell.unlockButton.isHidden = true
        cell.commonImageView.layer.borderWidth = 1.0
            cell.commonImageView.frame = CGRect(x: cell.frame.size.width - cell.frame.size.height, y: 0, width: cell.frame.size.height, height: cell.frame.size.height)
            cell.downloadButton.tag = indexPath.row
       
        cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for:.touchUpInside)
            cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)

            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareAudioButton), for: .touchUpInside)
        let mainDta = self.discourseArray[indexPath.row] as NSDictionary
        let name = mainDta.value(forKey: "file_name") as? String
            trackIds = mainDta.value(forKey: "id") as? String
        let coverName = mainDta.value(forKey: "cover") as? String
            let imageUrl = coverName?.unescapingUnicodeCharacters
            print("convertedStr",coverName)
        let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
        //let url = URL(string: imgeFile)

//        DispatchQueue.main.async(execute: {
//            if let _ = cell.commonImageView {
//                cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
//            }
//            cell.commonName.text = name
//            cell.descriptionLabel.text = "The series"
//        })
            DispatchQueue.main.async(execute: {
                               if let url = URL(string: imgeFile){
                                   if let _ = cell.commonImageView {
                                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                               }
                               cell.commonName.text = name
                               cell.descriptionLabel.text = "The series"
                           })
            
            //playing track GIF image
            for data in mainDta {
            if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
                let idds = playingId as! String
                if idds == id {
                    
                    switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                    case
                    STKAudioPlayerState.playing,
                    STKAudioPlayerState.buffering:
                        cell.playingTrackGIFImageView.isHidden = false
                        cell.commonImageView.isHidden = true
                        cell.playingTrackGIFImageView.loadGif(name: "UlgL")
                    default: break
                    }
                    
                }else {
                    switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                    case
                    STKAudioPlayerState(),
                    STKAudioPlayerState.stopped,
                    STKAudioPlayerState.paused :
                        cell.playingTrackGIFImageView.isHidden = true
                        cell.commonImageView.isHidden = false
                    // cell.playingTrackGIFImageView.loadGif(name: "UlgL1")
                    default: break
                    }
                }
            }
        }
            //download song tag
            if isdownloaded {
                cell.downloadButton.isHidden = true
                cell.downloadSongTagButton.isHidden = false
            }else {
                cell.downloadButton.isHidden = false
                cell.downloadSongTagButton.isHidden = true
            }
            
        }else {
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for:.touchUpInside)
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playVideo), for:.touchUpInside)
            
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            let mainDta = self.discourseVideoArray[indexPath.row] as NSDictionary
            let name = mainDta.value(forKey: "file_name") as? String
            let imageUrl = mainDta.value(forKey: "cover") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
            let url = URL(string: imgeFile)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
                cell.commonName.text = name
                cell.descriptionLabel.text = "The series"
            })
            //download song tag
            if isdownloaded {
                cell.downloadButton.isHidden = true
                cell.downloadSongTagButton.isHidden = false
            }else {
                cell.downloadButton.isHidden = false
                cell.downloadSongTagButton.isHidden = true
            }
        }
        cell.unlockButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categoty == "Audio" {
        let mainDta = self.discourseArray[indexPath.row] as NSDictionary
        trackIds = mainDta.value(forKey: "id") as? String
        self.showAlertPickerView()
        }
    }
    
    @objc func playSong(sender : UIButton){
        if discourseArray.count == 0 {
        }  else {
            
            var songs: Array<Audio> = []
            
            for music in discourseArray {
                
                let song = Audio(soundDictonary: music as NSDictionary)
                songs.append(song)
            }
            self.songs = songs
            let count = self.songs.count
            let x = UInt32(count)
            let randomIdx = Int(sender.tag)
            //  let randomIdx = Int(arc4random_uniform(x)+0)
            
            GLOBAL_CONTROLLER = "radio"
            
            if let track = self.playlist?.trackAtIndex(randomIdx) {
                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                AudioPlayer.sharedAudioPlayer.play(track)
            }
            
            let controller = RadioStreamViewController.sharedInstance
            controller.trackType = 1
            controller.recentTrackType = 1
            controller.allAudioArray = discourseArray
            controller.indexOfSong = sender.tag
            controller.isFromAudios = true
            controller.isFromQA = false
            controller.isFromHome = false
            controller.isFromPlayList = false
            controller.isFromRecentPlayList = false
            controller.isFromCommunity = false
            controller.isFromDiscourse = true
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
            let mainData = self.discourseArray[sender.tag] as NSDictionary
            let name = mainData.value(forKey: "file_name") as? String
            print("discourseName",name)
            UserDefaults.standard.set(name, forKey: "audioFileName")
            UserDefaults.standard.synchronize()
            let imageUrl = mainData.value(forKey: "cover") as? String
            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
            UserDefaults.standard.synchronize()
            SVProgressHUD.dismiss()
            discourseTableView.reloadData()
        }
    }
    
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
        if categoty == "Audio" {
            let mainDta = self.discourseArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongsForDiscoures(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            
        }else {
            let mainDta = self.discourseVideoArray[index] as NSDictionary
            fileType = "Video"
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            if  DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongsForDiscoures(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
        }
        
    }
    @objc func playVideo(sender : UIButton){

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController
        let mainDta = self.discourseVideoArray[sender.tag] as NSDictionary

        if let trackId = mainDta.value(forKey: "id") as? String {
            //self.recentplayTrack(trackId: trackId)
            vc.trackId = trackId
            vc.videoURLStr = (mainDta.value(forKey: "file") as? String)!
            RecentPlayTrackData.shared.recentplayTrack1(trackId: trackId, trackType: 8)
            adsTimer.invalidate()
        }
        self.navigationController?.pushViewController(vc, animated: true)
        

//        let name = mainDta.value(forKey: "name") as? String
//        let videoUrl = mainDta.value(forKey: "file") as? String
//       // print("videoUrl",videoUrl)
//
//        guard let videourl = videoUrl else {return}
//        let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,videourl)
//        print("videoFile",videoFile)
//        let urlStr : NSString = videoFile.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
//            //videoFile.addingPercentEscapes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as NSString
//        let searchURL : NSURL = NSURL(string: urlStr as String)!
//        print(searchURL)
//
//
//        let url =  URL(string: videoFile)
//        print("videoFile",url)
//        let player = AVPlayer(url: searchURL as URL)
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
    @IBAction func downloadSeries(_ sender: UIButton) {
        print("click")
       // let button = sender as UIButton
       // let index = button.tag
        var fileType = ""
        if categoty == "Audio" {
            for item in self.discourseArray {
                let mainDta = item as NSDictionary
               // let fileName = mainDta.value(forKey: "name") as! String
                let fileId = mainDta.value(forKey: "file") as! String
               // let fileImage = mainDta.value(forKey: "cover") as! String
                fileType = "Audio"
                if  DownloadManager.getDownloadedObject(predicate: fileId ){
                    DownloadManager.downloadSongsForDiscoures(mainDta: mainDta, type: fileType)
                }else {
                    Utilities.displayToastMessage("Song already downloaded...!!!")
                }
            }
        }else {
            for item in self.discourseVideoArray {
            let mainDta = item as NSDictionary
            fileType = "Video"
            //let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
           // let fileImage = mainDta.value(forKey: "cover") as! String
            if  DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongsForDiscoures(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            }
        }
    }
    
    @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        mainData = self.discourseVideoArray[sender.tag] as NSDictionary
        secondViewController.isShare = true
        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
        secondViewController.trackType = "5"
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @objc func shareAudioButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        mainData = self.discourseArray[sender.tag] as NSDictionary
        secondViewController.isShare = true
        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
        secondViewController.trackType = "1"
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    
    //Unlock songs
    @objc func unlockAction(sender : UIButton){
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func playerDidStartPlaying() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CommonDiscouresDispalyViewController {
    func showAlertPickerView( ) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_USER_PLIST)
        print("addlistUrl",urlRequest)
        if  let  userId = GLOBAL_USER_ID {
            Alamofire.request(urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"user_id":userId.stringValue])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success :
                        
                        print("addPlaylist",response)
                        guard let json = response.result.value else {return}
                        let JSON = json as! NSDictionary
                        // let JSON = response.result.value as! NSDictionary
                        
                        guard let val = JSON.value(forKey: "respon")  else {return}
                        self.addPlaylist =  val as! NSArray
                        
                        if self.addPlaylist.count > 0 {
                        DispatchQueue.main.async() {
                            
                            let picker = CZPickerView(headerTitle: "Playlist", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
                            picker?.dataSource = self
                            picker?.delegate = self
                            picker?.needFooterView = true
                            picker?.headerBackgroundColor = GREEN_COLOR
                            picker?.confirmButtonBackgroundColor = GREEN_COLOR
                            picker?.show()
                            
                            }
                        }else {
                            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                            }
                            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                            SCLAlertView().showTitle("", subTitle: "You do not have playlist", timeout: time, completeText: "Done", style:  .success)
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
    
    func saveTrackInPl(_ trackId:String,playlistId:String){
        // SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ADD_TRACK_IN_PLIST)
        
        print(urlRequest, trackId, playlistId)
        print("trackType",trackType)
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type": trackType,"X-API-KEY":API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success :
                    
                    print("Trackresponse",response)
                    guard let json = response.result.value else {return}
                    let JSON = json as! NSDictionary
                    
                    let success = JSON.value(forKey: "error") as! NSNumber
                    if success == 0 {
                        KVNProgress.showSuccess()
                    } else {
                        KVNProgress.showError()
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
    
    
    func checkDownloadSongs(index: Int) -> Bool {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedFile")
        request.returnsObjectsAsFaults = false
        var isDownloaded = false
        do {
            let results = try context.fetch(request)
            downloadFiles = results as! [NSManagedObject]
            if results.count == 0 {
                
            } else {
                
                if categoty == "Audio" {
                    let mainDta = self.discourseArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else{
                    let mainDta = self.discourseVideoArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                    
                }
                
            }
        } catch {
            
            print("Fetch Failed")
        }
        return isDownloaded
    }

    
}
extension String {
    var unescapingUnicodeCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, "Any-Hex/Java" as NSString, true)

        return mutableString as String
    }
}
extension CommonDiscouresDispalyViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return addPlaylist.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        let name  = (addPlaylist[row] as AnyObject).value(forKey: "name") as! String
        return name
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print("A1- ",addPlaylist[row])
        let plId  = (addPlaylist[row] as AnyObject).value(forKey: "id") as! String
        
        saveTrackInPl(trackIds, playlistId: plId)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if let row = row as? Int {
                print("A2- ",addPlaylist[row])
            }
        }
    }
}
/*
 @objc func playSong(sender : UIButton){
     if discourseArray.count == 0 {
     }  else {
         
         var songs: Array<Audio> = []
         
         for music in discourseArray {
             let song = Audio(soundDictonary: music as NSDictionary)
             songs.append(song)
         }
         self.songs = songs
         let count = self.songs.count
         let x = UInt32(count)
         let randomIdx = Int(sender.tag)
         //  let randomIdx = Int(arc4random_uniform(x)+0)
         
         GLOBAL_CONTROLLER = "radio"
         let mainDta = self.discourseArray[sender.tag] as NSDictionary
                let  file = mainDta.value(forKey: "file") as? String
                //let  imageName = mainDta.value(forKey: "cover") as? String
                   //let imageName = mainDta.value(forKey: "cover") as? String
         
                  if (file?.contains("Sambhog_Se_Samadhi_Ki_Aur"))! {
                      let file_url = "https://avapplication.s3.amazonaws.com/audios/track/" + file!
                       
                       let destURL = URL.init(fileURLWithPath: file_url)
                       _ = AVURLAsset(url: destURL).duration.seconds
                        //let destURL1 = URL.init(fileURLWithPath: imgUrl)
                      // print("destURL1",destURL1)
                           print(sender.tag)
                           print("file path of bundle songs =",file_url)
                           let player = AVPlayer(url: URL(fileURLWithPath: file_url))
                       
                       playerController.player = player
                       AudioPlayer.sharedAudioPlayer.pause()
                       sender.isEnabled = false
                       present(playerController, animated: true) {
                           self.playerController.player!.play()
                           MiniPlayerView.sharedInstance.removeFromSuperview()
                           UIView.animate(withDuration: 1, animations: {
                               sender.isEnabled = true
                           })
                       }
                     if file_url.contains(".mp4") || file_url.contains(".m4v") {
                         playerController.contentOverlayView?.isHidden = true
                     }else {
                         let playerCoverImageView = UIImageView.init(image: UIImage.init(named: "os_ho.jpg"))
                         playerCoverImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
                         
                         playerCoverImageView.center = self.view.center
                         let imgeFile = "https://avapplication.s3.amazonaws.com/audios/cover/1589271732%E0%A4%B8%E0%A4%AE%E0%A5%8D%E0%A4%AD%E0%A5%8B%E0%A4%97_%E0%A4%B8%E0%A5%87_%E0%A4%B8%E0%A4%AE%E0%A4%BE%E0%A4%A7%E0%A5%80_%E0%A4%95%E0%A5%80_%E0%A4%93%E0%A4%B0.jpg"
                         let url = URL(string: imgeFile)
                         DispatchQueue.main.async(execute: {
                                 playerCoverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                         })
                         playerController.contentOverlayView?.isHidden = false
                         playerController.contentOverlayView?.addSubview(playerCoverImageView)
                     }
                     let controller = RadioStreamViewController.sharedInstance
                                controller.trackType = 1
                                controller.recentTrackType = 1
                                controller.allAudioArray = discourseArray
                                controller.indexOfSong = sender.tag
                                controller.isFromAudios = true
                                controller.isFromQA = false
                                controller.isFromHome = false
                                controller.isFromPlayList = false
                                controller.isFromRecentPlayList = false
                                controller.isFromCommunity = false
                                controller.isFromDiscourse = true
                  }else{
                     if let track = self.playlist?.trackAtIndex(randomIdx) {
                                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                                    AudioPlayer.sharedAudioPlayer.play(track)
                                }
         }

         let controller = RadioStreamViewController.sharedInstance
         controller.trackType = 1
         controller.recentTrackType = 1
         controller.allAudioArray = discourseArray
         controller.indexOfSong = sender.tag
         controller.isFromAudios = true
         controller.isFromQA = false
         controller.isFromHome = false
         controller.isFromPlayList = false
         controller.isFromRecentPlayList = false
         controller.isFromCommunity = false
         controller.isFromDiscourse = true
         controller.modalPresentationStyle = .fullScreen
         self.present(controller, animated: true, completion: nil)
         
         let mainData = self.discourseArray[sender.tag] as NSDictionary
         let name = mainData.value(forKey: "file_name") as? String
         print("discourseName",name)
         UserDefaults.standard.set(name, forKey: "audioFileName")
         UserDefaults.standard.synchronize()
         let imageUrl = mainData.value(forKey: "cover") as? String
         UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
         UserDefaults.standard.synchronize()
         SVProgressHUD.dismiss()
         discourseTableView.reloadData()
     }
 }
 */
