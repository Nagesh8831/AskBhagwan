//
//  InterviewsViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 25/09/18.
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
import  SCLAlertView
import CZPicker
class InterviewsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,languageDelegate{

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var interviewTableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    var items : NSArray!
    var trackIds: String!
    var subscriptionStatus  = false
    var audioInterviewArray = [[String : AnyObject]]()
    var videoInterviewArray = [[String : AnyObject]]()
    var currentSelectedIndex = Int()
    var categoty = String()
    var selectedIndex = Int()
    var albId : String?
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    var progressView: UIProgressView?
    var downloadFiles = [NSManagedObject]()
    var fromDrawer : Bool?
    var adsTimer: Timer!
    //var downloaadJokesArray :[[String : AnyObject]]()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(InterviewsViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.interviewTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        self.title = "Interviews"
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()
        } else {
        }
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
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RED_COLOR as Any], for: .selected)
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
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
    override func viewWillAppear(_ animated: Bool) {
        categoty = (UserDefaults.standard.value(forKey: "category") as? String)!
        self.getAllAudioIntreviews()
        self.getAllVideoIntreviews()
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        albId = UserDefaults.standard.string(forKey: "defaultLanguageId")
        languageNameLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
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
        }else {
            if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
        segment.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
        
        self.title = "Interviews"
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    @objc func tapSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.selectedIndex = 0
            self.currentSelectedIndex = 0
            self.getAllAudioIntreviews()
            fromDrawer = false
        }else if sender.selectedSegmentIndex == 1{
              subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                  if subscriptionStatus == true {
                      print("User subscribed")
                  }else {
                    //showAdds()
                    //IronSource.showRewardedVideo(with: self)
                  }
            self.selectedIndex = 1
            self.currentSelectedIndex = 1
            self.getAllVideoIntreviews()
            fromDrawer = false
        }
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
    func languageSelect(_ album_Id: String, album_Name: String) {
        albId = album_Id
        languageNameLabel.text = album_Name
        self.getAllAudioIntreviews()
        self.getAllVideoIntreviews()
    }
    func getAllAudioIntreviews(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_INTERVIEWS_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
            parameters = [
                "searchterm" :"",
                "album_id" : albId ?? "" ,
            ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 500
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                //print("Dashboard_response",response)
                
                switch response.result {
                case .success :
                    if let itms = response.result.value {
                    let itemss = itms as! NSDictionary
                    let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if array.count > 0 {
                    if self.segment.selectedSegmentIndex == 0 {
                    self.noDataLabel.isHidden = true
                    self.interviewTableView.isHidden = false
                    self.audioInterviewArray = array
                    self.interviewTableView!.reloadData()
                    }
                    } else {
                    if self.segment.selectedSegmentIndex == 0 {
                    self.noDataLabel.isHidden = false
                    self.interviewTableView.isHidden = true
                    }
                    }
                    }else {
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
    
    func getAllVideoIntreviews(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_VIDEO_INTERVIEWS_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
        //self.getHideShow(istableReload: false)
            parameters = [
                "searchterm" :"",
                "album_id" : albId ?? "" ,
            ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 10000
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                    case .success :
                    print("Video_response",response)
                    if let itms = response.result.value {
                    let itemss = itms as! NSDictionary
                    let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if array.count > 0 {
                    if self.segment.selectedSegmentIndex == 1 {
                    self.noDataLabel.isHidden = true
                    self.interviewTableView.isHidden = false
                    self.videoInterviewArray = array
                    self.interviewTableView!.reloadData()
                    }
                    }else {
                    if self.segment.selectedSegmentIndex == 1 {
                    self.interviewTableView.isHidden = true
                    self.noDataLabel.isHidden = false
                    }
                    }
                    }else {
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
    func getHideShow(istableReload: Bool) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == 0 {
            return audioInterviewArray.count
        }else if selectedIndex == 1 {
            return videoInterviewArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = interviewTableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        var mainDta = NSDictionary()
        cell.unlockButton.isHidden = true
        cell.descriptionLabel.text = "Interviews"
        cell.commonImageView.isHidden = false
        cell.playingTrackGIFImageView.isHidden = true
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        cell.downloadSongTagButton.tag = indexPath.row
        cell.downloadSongTagButton.addTarget(self, action: #selector(downloadTagButton), for: .touchUpInside)
        if self.audioInterviewArray.count != 0 && selectedIndex == 0 {
            
            mainDta = self.audioInterviewArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playAudio), for:.touchUpInside)
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.isHidden = true
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            let name = mainDta.value(forKey: "name") as? String
            let imageUrl = mainDta.value(forKey: "cover") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
            let url = URL(string: imgeFile)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
                cell.commonName.text = name
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

        }else if self.videoInterviewArray.count != 0 && selectedIndex == 1 {
            
            mainDta = self.videoInterviewArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playVideo), for:.touchUpInside)
            
            cell.downloadButton.tag = indexPath.row
             cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            let name = mainDta.value(forKey: "name") as? String
            cell.commonName.text = name
            let imageUrl = mainDta.value(forKey: "cover") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
            let url = URL(string: imgeFile)

            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
            
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
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        //cell.commonImageView.layer.borderColor = UIColor.gray.cgColor
        cell.commonImageView.layer.borderWidth = 1.0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.audioInterviewArray.count != 0 && selectedIndex == 0 {
        let mainDta = self.audioInterviewArray[indexPath.row] as NSDictionary
        trackIds = mainDta.value(forKey: "id") as? String
        self.showAlertPickerView()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    @objc func downloadTagButton(sender: UIButton) {
        Utilities.displayToastMessage("Song already downloaded...!!!")
    }
    @objc func playAudio(sender : UIButton){
        if self.audioInterviewArray.count != 0 && selectedIndex == 0 {
            if audioInterviewArray.count == 0 {
            }  else {
                var songs: Array<Audio> = []
                for music in audioInterviewArray {
                    
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
                controller.trackType = 4
                controller.recentTrackType = 4
                controller.allAudioArray = audioInterviewArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = false
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.audioInterviewArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                
                interviewTableView.reloadData()
            }
        }
    }
    
    @objc func playVideo(sender : UIButton){
        if self.videoInterviewArray.count != 0 && selectedIndex == 1 {
        let mainDta = self.videoInterviewArray[sender.tag] as NSDictionary
       // let videoUrl = mainDta.value(forKey: "file") as? String
            if let trackId = mainDta.value(forKey: "id") as? String {
                //self.recentplayTrack(trackId: trackId)
                RecentPlayTrackData.shared.recentplayTrack1(trackId: trackId, trackType: 4)
            }
//        guard let videourl = videoUrl else {return}
//        let urlwithPercentEscapes = videourl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
//
//        let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!)
//        let url =  URL(string: videoFile)
//
//        let player = AVPlayer(url: url!)
//        print("videoUrl",url)
//        playerController.player = player
//            sender.isEnabled = false
//            AudioPlayer.sharedAudioPlayer.pause()
//            MiniPlayerView.sharedInstance.removeFromSuperview()
//            present(playerController, animated: true) {
//                self.playerController.player!.play()
//                MiniPlayerView.sharedInstance.removeFromSuperview()
//                UIView.animate(withDuration: 1, animations: {
//                    sender.isEnabled = true
//                })
//            }

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayViewController") as! VideoPlayViewController
            if let trackId = mainDta.value(forKey: "id") as? String {
                //self.recentplayTrack(trackId: trackId)
                vc.trackId = trackId
                vc.videoURLStr = (mainDta.value(forKey: "file") as? String)!
                RecentPlayTrackData.shared.recentplayTrack1(trackId: trackId, trackType: 4)
                adsTimer.invalidate()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
     @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            mainData = self.audioInterviewArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "4"
            self.present(secondViewController, animated: true, completion: nil)
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            mainData = self.videoInterviewArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "4"
            self.present(secondViewController, animated: true, completion: nil)
        }
    }
    
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
         if selectedIndex == 0 && currentSelectedIndex == 0 {
            let mainDta = self.audioInterviewArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }

        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            let mainDta = self.videoInterviewArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            
            fileType = "Video"
            if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            
        }
        
    }
    @objc func playerDidStartPlaying() {
        
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
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type":4,"X-API-KEY":API_GENERAL_KEY])
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "lang_to_interview"{
            let vc = segue.destination as! LanguagePopViewController
            vc.langDelegate = self
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InterviewsViewController {
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
                
                if selectedIndex == 0 {
                    let mainDta = self.audioInterviewArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else if selectedIndex == 1 {
                    let mainDta = self.videoInterviewArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                       // downloaadJokesArray.append(idd as! String)
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
extension InterviewsViewController : CZPickerViewDelegate, CZPickerViewDataSource {
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
