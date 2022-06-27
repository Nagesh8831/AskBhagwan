
//  CategorywiseSearchVideoAudioViewController.swift
//
//
//  Created by Mac on 19/07/18.
//

import UIKit
import Alamofire
import CoreData
import CZPicker
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
import StoreKit
class CategorywiseSearchVideoAudioViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate,languageDelegate{
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var rightMenuItem: UIBarButtonItem!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var leftMenuItem: UIBarButtonItem!
    var subscriptionStatus  = false
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var media_type_id : String?
    var album_id : String?
    var album_name : String?
    var album_Name : String?
    var albumId : String?
    var playVideoButtonTag : Int?
    var playAudioButtonTag : Int?
    var name : String?
    var categoty : String?
    var isQA = true
    var items : NSArray!
    var trackIds: String!
    var pickerWithImage: CZPickerView?
    var audioArray = [[String : AnyObject]]()
    var videoArray = [[String : AnyObject]]()
    var lockAudioArray = [[String : AnyObject]]()
    var subscriptionDataArray = [[String : AnyObject]]()
    var searchText = ""
    var searchActive = false
    var reachabilitysz: Reachability!
    var selectedIndex = Int()
    var refreshControl: UIRefreshControl!
    var indexOfRow = Int()
    var isPlay = false
    var recentTrackID : String?
    //Inapp purchase
    var product_id: String?
    var isPurchased : Bool?
    var userID : String?
    var subscriptionArray = [[String:AnyObject]]()
    var transaction_id =  ""
    var downloadFiles = [NSManagedObject]()
    var adsTimer: Timer!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CategorywiseSearchVideoAudioViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.audioArray.removeAll()
        self.videoArray.removeAll()
        self.listTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        //Inapp purchase
        product_id = IN_APP_PURCHASE_PRODUCT_ID
        //searchBar.searchTextField.textColor = .white
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        searchBar.delegate = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.listTableView.addSubview(self.refreshControl)
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
        }
        if (reachabilitysz?.isReachable)!{
        } else {
        }
       
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.listTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        
        // Do any additional setup after loading the view.+
    }

    @objc func pullToRefreshHandler() {
        categoty = (UserDefaults.standard.value(forKey: "category") as? String)!
        album_id = UserDefaults.standard.string(forKey: "defaultLanguageId")
        languageLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
        
        if categoty == "Audio" {
            self.getQAAudiosByMediaId(media_type_id!, albumId: album_id!,search_Text: searchText)
        } else {
            self.getQAVideoByMediaId(media_type_id!, albumId: album_id!, search_Text: searchText)
        }
        self.listTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        //navigationController?.isNavigationBarHidden = false
        //AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with:  [AVAudioSession.CategoryOptions.duckOthers])
        self.title = name
        categoty = (UserDefaults.standard.value(forKey: "category") as? String)!
//        if UserDefaults.standard.bool(forKey: "isAddClose") && UserDefaults.standard.bool(forKey: "isVideo") {
//            let videoButton = UIButton()
//            videoButton.tag =  playVideoButtonTag! //saved id on play button click
//            self.playVideo(sender: videoButton)
//        } else if UserDefaults.standard.bool(forKey: "isAddClose") && UserDefaults.standard.bool(forKey: "isAudio") {
//            let videoButton = UIButton()
//            videoButton.tag =  playVideoButtonTag! //saved id on play button click
//            self.playAudio(sender: videoButton)
//        }
        
        //Inapp purchase
//        if let pur  = UserDefaults.standard.value(forKey: "isPurchased") {
//            self.isPurchased = (pur as! Bool)
//        }
//        self.searchBarHeightConstraint.isActive = true
//        if  isPurchased == true {
//            self.searchBar.isHidden = false
//            self.searchBarHeightConstraint.constant = 56.0
//
//        }else {
//            self.searchBar.isHidden = true
//            self.searchBarHeightConstraint.constant = 0.0
//        }
        album_id = UserDefaults.standard.string(forKey: "defaultLanguageId")
        languageLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
        
        if categoty == "Audio" {
             self.getQAAudiosByMediaId(media_type_id!, albumId: album_id!,search_Text: searchText)
        } else {
               self.getQAVideoByMediaId(media_type_id!, albumId: album_id!,search_Text: searchText)
        }
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

        UserDefaults.standard.set(false, forKey: IN_APP_FROM_HOME)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchaseDone), name: NSNotification.Name(rawValue: IN_APP_PURCHASE_SUCCESS_CATEGORY_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }
    @objc func callBack(){
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            //IronSource.showRewardedVideo(with: self)
            self.showAdds()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
   @objc func inAppPurchaseDone() {
        self.listTableView.reloadData()
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
    @IBAction func languageButtonAction(_ sender: Any) {
    
    }
    
    func hideLabel() {
        
        if audioArray != nil {
            self.errorMessageLabel.isHidden = true
        }else {
            self.errorMessageLabel.isHidden = false
        }
    }
    
    
    func getQAAudiosByMediaId(_ mediaId : String,albumId : String,search_Text : String){
        self.audioArray.removeAll()
        self.videoArray.removeAll()
        if searchActive {
            searchText = search_Text
        }else {
            searchText = ""
        }
        self.listTableView.reloadData()
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES)
        print(urlResponce)
        //print("search_Text",search_Text)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : searchText,"quedisc":1,"media_type_id": mediaId,"album_id": albumId,"limit":1000,"offset":0,"should_orderby_name": false])
            .responseJSON { response in
                //print("parameters",Parameters)
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                   // print("Discource_response111",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.audioArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                    if self.audioArray.count > 0 {
                        //print("Array_response",self.audioArray)
                        DispatchQueue.main.async() {
                            
                            self.errorMessageLabel.isHidden = true
                            self.listTableView!.isHidden = false
                            self.listTableView!.reloadData()
                        }
                    } else {
                        self.view.bringSubviewToFront(self.errorMessageLabel)
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.text = "No songs found for selected language"
                        self.listTableView!.isHidden = true
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
    
    func getQAVideoByMediaId(_ mediaId : String,albumId : String,search_Text : String){
        self.audioArray.removeAll()
        self.videoArray.removeAll()
        self.listTableView.reloadData()
        if searchActive {
            searchText = search_Text
        }else {
            searchText = ""
        }
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_VIDEO_QA_DISCOURSES)
        //print(urlResponce)
        // print("media_type_id",mediaId)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : search_Text,"quedisc":1,"media_type_id": mediaId,"album_id":albumId ,"limit":1000,"offset":0,"should_orderby_name": false])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success :
                      print("Discource_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.videoArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                    if self.videoArray.count > 0 {
                        // print("Array_response",self.videoArray)
                        DispatchQueue.main.async() {
                            //self.listTableView!.reloadData()
                            self.errorMessageLabel.isHidden = true
                            self.listTableView!.isHidden = false
                            self.listTableView!.reloadData()
                        }
                    } else {
                        self.view.bringSubviewToFront(self.errorMessageLabel)
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.text = "No videos found for selected language"
                        self.listTableView!.isHidden = true
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
                return audioArray.count
        } else {
                return videoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        var mainData = NSDictionary()
        cell.unlockButton.isHidden = true
        cell.playingTrackGIFImageView.isHidden = true
        cell.downloadSongTagButton.isHidden = true
        cell.commonImageView.isHidden = false
        
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        cell.downloadSongTagButton.tag = indexPath.row
        cell.downloadSongTagButton.addTarget(self, action: #selector(downloadTagButton), for: .touchUpInside)
        if categoty == "Audio" {
    
            cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
            cell.commonImageView.clipsToBounds = true
            cell.commonImageView.layer.borderWidth = 1.0
                mainData = self.audioArray[indexPath.row] as NSDictionary
            
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playAudio), for:.touchUpInside)
          
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareAudioButton), for: .touchUpInside)
            
            let imageUrl = mainData.value(forKey: "cover") as? String
              if imageUrl != "" {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
            let name = mainData.value(forKey: "name") as? String
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = cell.commonImageView {
                        
                    cell.commonImageView.kf.setImage(with: url , placeholder:UIImage(named: "os_ho.jpg"))
                    }
                }
                cell.commonName.text = name
            })
            } else {
                cell.commonImageView.image = UIImage(named: "os_ho.jpg")
            }
            if selectedIndex == indexPath.row && isPlay {
                cell.playButton.setImage(UIImage(named: "pause-1"), for: .normal)
            } else {
                cell.playButton.setImage(UIImage(named: "play_button"), for: .normal)
            }
            
//            DispatchQueue.main.async(execute: {
//            if  let audioFileURL =  mainData.value(forKey: "file") as? String {
//                let audioFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO_TRACK,audioFileURL)
//                if let url = URL(string: audioFile){
//                    let audioAsset = AVURLAsset.init(url: url)
//                    let duration = audioAsset.duration
//                    let durationInSeconds = CMTimeGetSeconds(duration)
//                    self.formatSecondsToString(durationInSeconds)
//                    let audioTime = self.formatSecondsToString(durationInSeconds)
//                    cell.descriptionLabel.text = "Q & A" + "     " + audioTime
//                }
//            }
//            })re
            
            cell.descriptionLabel.text = "Q & A"
            //playing track GIF image
            for data in mainData {
            if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainData.value(forKey: "id") as? String{
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
                        STKAudioPlayerState.stopped :
                        cell.playingTrackGIFImageView.isHidden = true
                        cell.commonImageView.isHidden = false
                    case
                    STKAudioPlayerState(),
                    STKAudioPlayerState.paused :
                        cell.playingTrackGIFImageView.isHidden = true
                        cell.commonImageView.isHidden = false
                    default: break
                    }
                }
            }
            }
//            //download song tag
//            if isdownloaded {
//                cell.downloadButton.isHidden = true
//                cell.downloadSongTagButton.isHidden = false
//            }else {
//                cell.downloadButton.isHidden = false
//                cell.downloadSongTagButton.isHidden = true
//            }
            
        }else {
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playVideo(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareVideoButton), for: .touchUpInside)
            mainData = self.videoArray[indexPath.row] as NSDictionary
            if  let name = mainData.value(forKey: "name") as? String {
                cell.commonName.text = name
            }
            if let imageUrl = mainData.value(forKey: "cover") as? String {
                if imageUrl != "" {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl)
                    
                    DispatchQueue.main.async(execute: {
                        if let url = URL(string: imgeFile){
                            if let _ = cell.commonImageView {
                                cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                            }
                        }
                        cell.descriptionLabel.text = "Q & A"
                    })
                } else {
                    cell.commonImageView.image = UIImage(named: "os_ho.jpg")
                }
            }
                cell.shareButton.isHidden = false
                cell.shareButtonWidthConstarint.constant = 30
        }
                cell.downloadButton.tag = indexPath.row
                cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for: .touchUpInside)
        
        //download song tag
        if isdownloaded {
            cell.downloadButton.isHidden = true
            cell.downloadSongTagButton.isHidden = false
        }else {
            cell.downloadButton.isHidden = false
            cell.downloadSongTagButton.isHidden = true
        }
        //Inapp purchase
       /* if let pur  = UserDefaults.standard.value(forKey: "isPurchased") {
            self.isPurchased = pur as? Bool
        }
            if self.isPurchased == true{
                self.searchBar.isHidden = false
                self.searchBarHeightConstraint.constant = 56.0
                cell.unlockButton.isHidden = true
                cell.playButton.isHidden = false
                cell.shareButton.isHidden = false
                //download song tag
                if isdownloaded {
                    cell.downloadButton.isHidden = true
                    cell.downloadSongTagButton.isHidden = false
                }else {
                    cell.downloadButton.isHidden = false
                    cell.downloadSongTagButton.isHidden = true
                }
            } else {
                self.searchBar.isHidden = true
                self.searchBarHeightConstraint.constant = 0.0
                if indexPath.row == 0 {
                    cell.unlockButton.isHidden = true
                    cell.playButton.isHidden = false
                    cell.shareButton.isHidden = false
                    //download song tag
                    if isdownloaded {
                        cell.downloadButton.isHidden = true
                        cell.downloadSongTagButton.isHidden = false
                    }else {
                        cell.downloadButton.isHidden = false
                        cell.downloadSongTagButton.isHidden = true
                    }
                }else if indexPath.row == 1{
                    cell.unlockButton.isHidden = true
                    cell.playButton.isHidden = false
                    cell.downloadButton.isHidden = false
                    cell.shareButton.isHidden = false
                    //download song tag
                    if isdownloaded {
                        cell.downloadButton.isHidden = true
                        cell.downloadSongTagButton.isHidden = false
                    }else {
                        cell.downloadButton.isHidden = false
                        cell.downloadSongTagButton.isHidden = true
                    }
                }else {
                    
                    cell.unlockButton.isHidden = false
                    cell.playButton.isHidden = true
                    cell.downloadButton.isHidden = true
                    cell.downloadSongTagButton.isHidden = true
                    cell.shareButton.isHidden = true
                    cell.unlockButton.tag = indexPath.row
                    cell.unlockButton.addTarget(self, action: #selector(unlockAction), for:.touchUpInside)
                }
                
            }*/
                return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.isPurchased == true{
//            if categoty == "Audio" {
//                let mainDta = self.audioArray[indexPath.row] as NSDictionary
//                trackIds = mainDta.value(forKey: "id") as? String
//                    self.showAlertPickerView()
//            }
//        }else {
//            if categoty == "Audio" {
//                if indexPath.row == 0 || indexPath.row == 1 {
//                    let mainDta = self.audioArray[indexPath.row] as NSDictionary
//                    trackIds = mainDta.value(forKey: "id") as? String
//                        self.showAlertPickerView()
//                }
//            }
//
//        }
        if categoty == "Audio" {
            let mainDta = self.audioArray[indexPath.row] as NSDictionary
            trackIds = mainDta.value(forKey: "id") as? String
            self.showAlertPickerView()
        }
    }
    @objc func downloadTagButton(sender: UIButton) {
        Utilities.displayToastMessage("Song already downloaded...!!!")
    }
    @objc func playAudio(sender : UIButton){
//        SVProgressHUD.show()
//        UserDefaults.standard.set(false, forKey: "isVideo")
//        UserDefaults.standard.set(true, forKey: "isAudio")
//        UserDefaults.standard.synchronize()
//        self.playVideoButtonTag = sender.tag
//
//        if UserDefaults.standard.bool(forKey: "isAddClose") == true {
//            UserDefaults.standard.set(false, forKey: "isAddClose")
//            UserDefaults.standard.synchronize()
            if audioArray.count == 0 {
            }  else {
                var songs: Array<Audio> = []
                for music in audioArray {
                    let song = Audio(soundDictonary: music as NSDictionary)
                    songs.append(song)
                }
                self.songs = songs
                _ = self.songs.count
                let randomIdx = Int(sender.tag)
                GLOBAL_CONTROLLER = "radio"
                if let track = self.playlist?.trackAtIndex(randomIdx) {
                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                    AudioPlayer.sharedAudioPlayer.play(track)
                }
                let controller = RadioStreamViewController.sharedInstance
                controller.trackType = 1
                controller.recentTrackType = 1
                controller.allAudioArray = audioArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = true
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromCommunity = false
                controller.isFromRecentPlayList = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.audioArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                listTableView.reloadData()
            }
//        }else {
//            self.showVideosAdds()
//        }
        
        
        
        //lock functinality
       /* self.lockAudioArray = [[String : AnyObject]]()
        if self.audioArray.count == 1 {
          self.lockAudioArray = [audioArray[0]]
        }else if self.audioArray.count >=  2 {
            self.lockAudioArray = [audioArray[0] , audioArray[1]]
        }
        if isPurchased == true {
            if audioArray.count == 0 {
            }  else {
                var songs: Array<Audio> = []
                for music in audioArray {
                    let song = Audio(soundDictonary: music as NSDictionary)
                    songs.append(song)
                }
                self.songs = songs
                _ = self.songs.count
                let randomIdx = Int(sender.tag)
                GLOBAL_CONTROLLER = "radio"
                if let track = self.playlist?.trackAtIndex(randomIdx) {
                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                    AudioPlayer.sharedAudioPlayer.play(track)
                }
                let controller = RadioStreamViewController.sharedInstance
                controller.trackType = 1
                controller.recentTrackType = 1
                controller.allAudioArray = audioArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromCommunity = false
                controller.isFromRecentPlayList = false
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.audioArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                listTableView.reloadData()
            }
        }else {
            if lockAudioArray.count == 0 {
            }  else {
                var songs: Array<Audio> = []
                for music in lockAudioArray {
                    let song = Audio(soundDictonary: music as NSDictionary)
                    songs.append(song)
                }
                self.songs = songs
                _ = self.songs.count
                let randomIdx = Int(sender.tag)
                GLOBAL_CONTROLLER = "radio"
                if let track = self.playlist?.trackAtIndex(randomIdx) {
                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                    AudioPlayer.sharedAudioPlayer.play(track)
                }
                
                let controller = RadioStreamViewController.sharedInstance
                controller.trackType = 1
                controller.allAudioArray = lockAudioArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.lockAudioArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                listTableView.reloadData()
            }
        }*/
    }
    
    @objc func playVideo(sender : UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController

        let mainDta = self.videoArray[sender.tag] as NSDictionary

        if let trackId = mainDta.value(forKey: "id") as? String {
            //self.recentplayTrack(trackId: trackId)
            vc.trackId = trackId
            vc.videoURLStr = (mainDta.value(forKey: "file") as? String)!
            RecentPlayTrackData.shared.recentplayTrack1(trackId: trackId, trackType: 8)
            adsTimer.invalidate()
        }
        self.navigationController?.pushViewController(vc, animated: true)
        /*
//        UserDefaults.standard.set(true, forKey: "isVideo")
//        UserDefaults.standard.set(false, forKey: "isAudio")
//        UserDefaults.standard.synchronize()
//        self.playVideoButtonTag = sender.tag
            let mainDta = self.videoArray[sender.tag] as NSDictionary
            let videoUrl = mainDta.value(forKey: "file") as? String
        if let trackId = mainDta.value(forKey: "id") as? String {
            RecentPlayTrackData.shared.recentplayTrack1(trackId: trackId, trackType: 8)
        }
//        if UserDefaults.standard.bool(forKey: "isAddClose") == true {
//            UserDefaults.standard.set(false, forKey: "isAddClose")
//            UserDefaults.standard.synchronize()
            guard let videourl = videoUrl else {return}
            let urlwithPercentEscapes = videourl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!)
            let url =  URL(string: videoFile)
            let player = AVPlayer(url: url!)
            playerController.player = player
            sender.isEnabled = false
            AudioPlayer.sharedAudioPlayer.pause()
            present(playerController, animated: true) {
                self.playerController.player!.play()
                MiniPlayerView.sharedInstance.removeFromSuperview()
                UIView.animate(withDuration: 1, animations: {
                    sender.isEnabled = true
                })
            }
//        }else {
//            self.showVideosAdds()
//        }*/
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    @objc func playerDidStartPlaying() {

    }
    
    @objc func shareVideoButton(sender: UIButton) {
        let shareOnViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareOnViewController") as! ShareOnViewController
//        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
       // var mainData = NSDictionary()
      //  mainData = self.videoArray[sender.tag] as NSDictionary
//        secondViewController.isShare = true
//        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
//        secondViewController.trackType = "5"
        shareOnViewController.isFromAudio = false
        shareOnViewController.isFromJokes = false
        shareOnViewController.isFromWorldMusic = false
        shareOnViewController.mainData = self.videoArray[sender.tag] as NSDictionary
        shareOnViewController.modalTransitionStyle = .crossDissolve
        shareOnViewController.modalPresentationStyle = .overCurrentContext
        self.present(shareOnViewController, animated: true, completion: nil)
    }
    
    @objc func shareAudioButton(sender: UIButton) {
        let shareOnViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareOnViewController") as! ShareOnViewController

        shareOnViewController.isFromAudio = true
        shareOnViewController.isFromJokes = false
        shareOnViewController.isFromWorldMusic = false
        shareOnViewController.mainData = self.audioArray[sender.tag] as NSDictionary
        
        shareOnViewController.modalTransitionStyle = .crossDissolve
        shareOnViewController.modalPresentationStyle = .overCurrentContext
        self.present(shareOnViewController, animated: true, completion: nil)
    }
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
        if categoty == "Audio" {
                let mainDta = self.audioArray[index] as NSDictionary
                let fileName = mainDta.value(forKey: "name") as! String
                let fileId = mainDta.value(forKey: "file") as! String
                let fileImage = mainDta.value(forKey: "cover") as! String
                fileType = "Audio"
                if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                    DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                }else {
                    Utilities.displayToastMessage("Song already downloaded...!!!")
                    UserDefaults.standard.set(true, forKey: "AlreadyDownload")
                    UserDefaults.standard.synchronize()
                }
        } else {
                let mainDta = self.videoArray[index] as NSDictionary
                fileType = "Video"
                let fileName = mainDta.value(forKey: "name") as! String
                let fileId = mainDta.value(forKey: "file") as! String
                let fileImage = mainDta.value(forKey: "cover") as! String
                if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                    DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                }else {
                    Utilities.displayToastMessage("Song already downloaded...!!!")
                }
        }
   }
    
   //Inapp purchase Unlock songs
    @objc func unlockAction(sender : UIButton){
        let alert = UIAlertController(title: "You have not unlocked premium Q&A episodes",message: "You need to purchase for continueing to listen. Do you want to proceed?", preferredStyle: .alert)
        let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
            if self.isPurchased == true  {
                self.listTableView.reloadData()
            } else {
                self.makePaymentMethod()
            }
        }
        let cancleEvent = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            //print("No")
        }
        alert.addAction(addEvent)
        alert.addAction(cancleEvent)
        self.present(alert, animated: true, completion:  nil)
    }
    
    func reloadPurchasingData() {
         self.listTableView.reloadData()
    }
    
    func makePaymentMethod (){
        if (SKPaymentQueue.canMakePayments()) {
            let productID:NSSet = NSSet(array: [self.product_id! as NSString]);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            SVProgressHUD.show(withStatus: "Fetching Products")
        } else {
        }
    }
    func buyProduct(product: SKProduct) {
        SVProgressHUD.dismiss()
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
    }

    func share(sender : UIButton) {
        if categoty == "Audio" {
        } else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
            secondViewController.isShare = true
            secondViewController.trackId = "30"
            secondViewController.trackType = "5"
            self.present(secondViewController, animated: true, completion: nil)
        }
    }
         
    
    func showAlertPickerView( ) {
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_USER_PLIST)
       // print("addlistUrl",urlRequest)
        if let  userId = GLOBAL_USER_ID {
            Alamofire.request(urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"user_id":userId.stringValue])
                .responseJSON { response in
                    switch response.result {
                    case .success :
                        guard let json = response.result.value else {return}
                        let JSON = json as! NSDictionary
                        guard let val = JSON.value(forKey: "respon")  else {return}
                        self.items =  val as? NSArray
                        if self.items.count > 0 {
                            DispatchQueue.main.async() {
                                let picker = CZPickerView(headerTitle: "Playlist", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
                                picker?.delegate = self
                                picker?.dataSource = self
                                picker?.needFooterView = true
                                picker?.headerBackgroundColor = GREEN_COLOR
                                picker?.confirmButtonBackgroundColor = GREEN_COLOR
                                picker?.show()
                            }
                        }else  {
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
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ADD_TRACK_IN_PLIST)
       // print(urlRequest, trackId, playlistId)
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type":1,"X-API-KEY":API_GENERAL_KEY])
            .responseJSON { response in
                switch response.result {
                case .success :
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
    
    func languageSelect(_ album_Id: String, album_Name: String) {
        searchBar.text = ""
        searchActive = false
        searchBar.resignFirstResponder()
        album_id = album_Id
        album_name = album_Name
        languageLabel.text = album_Name
        if categoty == "Audio" {
            self.getQAAudiosByMediaId(media_type_id!, albumId: album_id!,search_Text: searchText)
        } else {
            self.getQAVideoByMediaId(media_type_id!, albumId: album_id!,search_Text: searchText)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lang_to_category"{
            let vc = segue.destination as! LanguagePopViewController
            vc.langDelegate = self
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
}

extension CategorywiseSearchVideoAudioViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
                if categoty == "Audio" {
                    self.getQAAudiosByMediaId(media_type_id!, albumId: album_id!, search_Text: searchText)
                } else {
                    self.getQAVideoByMediaId(media_type_id!, albumId: album_id!, search_Text: searchText)
                }
    }
}

extension CategorywiseSearchVideoAudioViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return items.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        let name  = (items[row] as AnyObject).value(forKey: "name") as! String
        return name
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        let plId  = (items[row] as AnyObject).value(forKey: "id") as! String
        saveTrackInPl(trackIds, playlistId: plId)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if row is Int {
            }
        }
    }
}

extension CategorywiseSearchVideoAudioViewController : SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    //print("response.products",response.products)
    let count : Int = response.products.count
    if (count>0) {
    let validProduct: SKProduct = response.products[0] as SKProduct
        if (validProduct.productIdentifier == self.product_id as! String) {
    self.buyProduct(product: validProduct)
        } else {
                print(validProduct.productIdentifier)
            }
        } else {
        SVProgressHUD.dismiss()
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
                let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                SCLAlertView().showTitle("", subTitle: "No product available", timeout: time, completeText: "Done", style: .success)
        }
    }
    //If an error occurs, the code will go to this function
    func paymentQueue(_ queue: SKPaymentQueue, view error: Error) {
        // Show some alert
    }
}
extension CategorywiseSearchVideoAudioViewController {
   func recentplayTrack( trackId : String) {
    SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_RECENT_PLAY_TRACK)
    if let  userId = GLOBAL_USER_ID {
        Alamofire.request(urlRequest,method: .post, parameters: ["user_id": userId.stringValue,"track_id":trackId,"track_type": 8,"X-API-KEY":API_GENERAL_KEY])
                   .responseJSON { response in
                       SVProgressHUD.dismiss()
                       switch response.result {
                       case .success :
                          // print("Trackresponse",response)
                           guard let json = response.result.value else {return}
                           let JSON = json as! NSDictionary
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
    
    func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
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
                    let mainDta = self.audioArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else{
                    let mainDta = self.videoArray[index] as NSDictionary
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
    
    func shareApiCall(index:Int,audio:Bool) {
        let urlRequest = "\(BASE_URL_BACKEND)/endpoint/appusers/generatelink/"
        print(urlRequest)
        
        
        
        var user_id = GLOBAL_USER_ID.intValue
        var av_id : Any?
        var media_type : Any?
        var media_category : Any?
        if audio == true {
            print(audioArray[index])
               
            let mainData = self.audioArray[index] as NSDictionary
            print(mainData)

            let mediaType = mainData["media_type_id"]
            print(mediaType ?? 0)
            media_type = mediaType ?? 0
            print(media_type)
           
            
            let category = mainData["category"]
            print(category ?? 0)
            media_category = category ?? 0
            print(media_category)
            
            
            let avId = mainData["id"]
            print(avId ?? 0)
            av_id = avId ?? 0
            print(av_id)
            
            
            
            let param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":1]
           // let param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":media_category ?? 0]
            print(param)
            SVProgressHUD.show()
            Alamofire.request( urlRequest,method: .post ,parameters: param)
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    print(response)
                    guard let item = response.result.value as! NSDictionary? else {return}
                    print(item)
                    guard let error = item["error"] as? NSInteger? else {return}
                    print(error)
                    if error == 1
                    {
                        print("error")
                        self.alert("Oops!", subTitle: "You are not a subscribed user")
                        
                    }else {
                        guard let resp = item["respon"] as! NSDictionary? else {return}
                        print(resp)
                        let titleStr = (resp["cover"] as? NSString) ?? ""
                        print(titleStr)
                        let nameStr = (resp["name"] as? NSString) ?? ""
                        print(nameStr)
                        let linkStr = (resp["link"] as? NSString) ?? ""
                        print(linkStr)
                        
                        
                        let textToShare = "\(nameStr) \n\(linkStr)"
                        print(textToShare)
                        
                     //   if let myWebsite = NSURL(string: "\(linkStr.replacingOccurrences(of: ",", with: ""))\(titleStr)") {
                            let objectsToShare: [Any] = [textToShare]
                            print(objectsToShare)
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityVC, animated: true, completion: nil)
                      //  }
                        

            
            
        }
                }
        }else{
            print(videoArray[index])
            let mainData = self.videoArray[index] as NSDictionary
            print(mainData)

            let mediaType = mainData["media_type_id"]
            print(mediaType ?? 0)
            media_type = mediaType ?? 0
            print(media_type)
            
            let category = mainData["category"]
            print(category ?? 0)
            media_category = category ?? 0
            print(media_category)
            
            
            let avId = mainData["id"]
            print(avId ?? 0)
            av_id = avId ?? 0
            print(av_id)

            
            let param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type":2,"media_category":2]
           // let param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":media_category ?? 0]
            print(param)
            SVProgressHUD.show()
            Alamofire.request( urlRequest,method: .post ,parameters: param)
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    print(response)
                    guard let item = response.result.value as! NSDictionary? else {return}
                    print(item)
                    guard let error = item["error"] as? NSInteger? else {return}
                    print(error)
                    if error == 1
                    {
                        print("error")
                        self.alert("Oops!", subTitle: "You are not a subscribed user")
                        
                    }else {
                        guard let resp = item["respon"] as! NSDictionary? else {return}
                        print(resp)
                        let titleStr = (resp["cover"] as? NSString) ?? ""
                        print(titleStr)
                        let nameStr = (resp["name"] as? NSString) ?? ""
                        print(nameStr)
                        let linkStr = (resp["link"] as? NSString) ?? ""
                        print(linkStr)
                        
                        
                        let textToShare = "\(nameStr) \n\(linkStr)"
                        print(textToShare)
                        
                     //   if let myWebsite = NSURL(string: "\(linkStr.replacingOccurrences(of: ",", with: ""))\(titleStr)") {
                            let objectsToShare: [Any] = [textToShare]
                            print(objectsToShare)
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityVC, animated: true, completion: nil)
                      //  }
                        

            
        }
       
        
       
                
            }
    }
                }
}
