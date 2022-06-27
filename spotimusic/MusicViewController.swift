//
//  MusicViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 24/09/18.


import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
import CZPicker
class MusicViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var musicTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var wolrdMusicView: UIView!

    var subscriptionStatus  = false
    var meditationMusicArray = [[String : AnyObject]]()
    var bhajanArray = [[String : AnyObject]]()
    var eveningSatsangArray = [[String : AnyObject]]()
    var categoty = String()
    var selectedIndex = Int()
    var currentSelectedIndex = Int()
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    var progressView: UIProgressView?
    var items : NSArray!
    var trackIds: String!
    var trackType :Int?
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MusicViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.musicTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        //reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        self.title = "Music"
        
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
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
        self.getAllMeditationMusics()
        self.getAllBhajans()
        self.getAllSatsang()
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        categoty = (UserDefaults.standard.value(forKey: "category") as? String)!
        self.title = categoty
        let trackInlist = UserDefaults.standard.bool(forKey: "isTrackInList")
        if trackInlist == true  {
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
    @objc func tapSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
            if subscriptionStatus == true {
                print("User subscribed")
            }else {
                //  showAdds()
                //IronSource.showRewardedVideo(with: self)
            }
            self.selectedIndex = 0
            self.currentSelectedIndex = 0
            self.getAllMeditationMusics()
            wolrdMusicView.isHidden = true
            musicTableView.isHidden = false
            // searchBar.text = nil
        }else if sender.selectedSegmentIndex == 1 {
            subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
            if subscriptionStatus == true {
                print("User subscribed")
            }else {
                //  showAdds()
                //IronSource.showRewardedVideo(with: self)
            }
            self.selectedIndex = 1
            self.currentSelectedIndex = 1
            self.getAllBhajans()
            wolrdMusicView.isHidden = false
            musicTableView.isHidden = true
        }else {
            subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
            if subscriptionStatus == true {
                print("User subscribed")
            }else {
                // showAdds()
                // IronSource.showRewardedVideo(with: self)
            }
            self.selectedIndex = 2
            self.currentSelectedIndex = 2
            self.getAllSatsang()
            wolrdMusicView.isHidden = true
            musicTableView.isHidden = false
        }
    }
    @IBAction func englishButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WorldMusicViewController") as! WorldMusicViewController
        vc.albumId = 1
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func hindiButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WorldMusicViewController") as! WorldMusicViewController
        vc.albumId = 2
        navigationController?.pushViewController(vc, animated: true)
    }

    func getAllMeditationMusics(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_MEDITATION_MUSIC_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
        self.getHideShow(istableReload: false)
        parameters = [
            "searchterm" :"",
        ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 1000
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    
                    print("MusicDashboard_response",response)
                    if let itms = response.result.value {
                        let itemss = itms as! NSDictionary
                        let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        if array.count > 0 {
                            for i in (0..<array.count) {
                                if self.selectedIndex == 0 {
                                    self.meditationMusicArray.append(array[i])
                                    self.musicTableView!.reloadData()
                                }
                            }
                            self.noDataLabel.isHidden = true
                        }else {
                            self.noDataLabel.isHidden = false
                            
                            self.getHideShow(istableReload: true)
                        }
                    }else {
                        self.getHideShow(istableReload: true)
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
    func getAllBhajans(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_BHAJAN_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
        self.getHideShow(istableReload: false)
        parameters = [
            "searchterm" :"",
        ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 1000
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    print("BhajanDashboard_response",response)
                    if let itms = response.result.value {
                        let itemss = itms as! NSDictionary
                        let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        if array.count > 0 {
                            for i in (0..<array.count) {
                                if self.selectedIndex == 1{
                                    self.bhajanArray.append(array[i])
                                    self.musicTableView!.reloadData()
                                }
                            }
                            self.noDataLabel.isHidden = true
                        }else {
                            self.noDataLabel.isHidden = false
                            self.getHideShow(istableReload: true)
                        }
                    }else {
                        self.getHideShow(istableReload: true)
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
    
    func getAllSatsang(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_SATSANG_MUSIC_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
        self.getHideShow(istableReload: false)
        parameters = [
            "searchterm" :"",
        ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 1000
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    print("SatsangDashboard_response",response)
                    if let itms = response.result.value {
                        let itemss = itms as! NSDictionary
                        let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        if array.count > 0 {
                            for i in (0..<array.count) {
                                if self.selectedIndex == 2 {
                                    self.eveningSatsangArray.append(array[i])
                                    self.musicTableView!.reloadData()
                                }
                            }
                            self.noDataLabel.isHidden = true
                        }else {
                            self.noDataLabel.isHidden = false
                            self.getHideShow(istableReload: true)
                        }
                    }else {
                        self.getHideShow(istableReload: true)
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
    // hide show array and table {
    func getHideShow(istableReload: Bool) {
        if self.meditationMusicArray.count != 0 && self.selectedIndex == 0 {
            self.meditationMusicArray.removeAll()
            self.noDataLabel.isHidden = true
        }else if self.bhajanArray.count != 0 && self.selectedIndex == 1 {
            self.bhajanArray.removeAll()
            self.noDataLabel.isHidden = true
        }else if self.eveningSatsangArray.count != 0 && self.selectedIndex == 2 {
            self.eveningSatsangArray.removeAll()
            self.noDataLabel.isHidden = true
        }
        if istableReload {
            self.musicTableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == 0 {
            return meditationMusicArray.count
        }else if selectedIndex == 1 {
            return bhajanArray.count
        }else if selectedIndex == 2 {
            return eveningSatsangArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = musicTableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        var mainDta = NSDictionary()
        cell.unlockButton.isHidden = true
        cell.descriptionLabel.text = "Bhagwan Music"
        cell.commonImageView.isHidden = false
        cell.playingTrackGIFImageView.isHidden = true
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        cell.downloadSongTagButton.tag = indexPath.row
        cell.downloadSongTagButton.addTarget(self, action: #selector(downloadTagButton), for: .touchUpInside)
        if self.meditationMusicArray.count != 0 && selectedIndex == 0 {
            
            mainDta = self.meditationMusicArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
            
            cell.downloadButton.tag = indexPath.row
            //cell.downloadButton.isHidden = true
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
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
        }else if self.bhajanArray.count != 0 && selectedIndex == 1 {

            mainDta = self.bhajanArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)

            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
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
            
        }else if self.eveningSatsangArray.count != 0 && selectedIndex == 2 {
            mainDta = self.eveningSatsangArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
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
            
        }else  {
            return cell
        }
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        //cell.commonImageView.layer.borderColor = UIColor.gray.cgColor
        cell.commonImageView.layer.borderWidth = 1.0
        
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
        
        //cell.downloadButton.isHidden = true
        //cell.shareButton.isHidden = true
        //cell.shareButtonWidthConstarint.constant = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.searchBar.resignFirstResponder()
        if self.meditationMusicArray.count != 0 && selectedIndex == 0 {
            let mainDta = self.meditationMusicArray[indexPath.row] as NSDictionary
            trackIds = mainDta.value(forKey: "id") as? String
            trackType = 3
            self.showAlertPickerView()
        }else  if self.bhajanArray.count != 0 && selectedIndex == 1 {
            let mainDta = self.bhajanArray[indexPath.row] as NSDictionary
            trackIds = mainDta.value(forKey: "id") as? String
            trackType = 6
            self.showAlertPickerView()
        }else  if self.eveningSatsangArray.count != 0 && selectedIndex == 2 {
            let mainDta = self.eveningSatsangArray[indexPath.row] as NSDictionary
            trackIds = mainDta.value(forKey: "id") as? String
            trackType = 7
            self.showAlertPickerView()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type":trackType!,"X-API-KEY":API_GENERAL_KEY])
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
    
    @objc func playSong(sender : UIButton){
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            if currentSelectedIndex == selectedIndex {
                if meditationMusicArray.count == 0 {
                    
                }  else {
                    
                    var songs: Array<Audio> = []
                    for music in meditationMusicArray {
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
                    controller.trackType = 3
                    controller.recentTrackType = 3
                    controller.allAudioArray = meditationMusicArray
                    controller.indexOfSong = sender.tag
                    controller.isFromAudios = true
                    controller.isFromQA = false
                    controller.isFromHome = false
                    controller.isFromPlayList = false
                    controller.isFromRecentPlayList = false
                    controller.isFromCommunity = false
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                    
                    let mainData = self.meditationMusicArray[sender.tag] as NSDictionary
                    let name = mainData.value(forKey: "name") as? String
                    UserDefaults.standard.set(name, forKey: "audioFileName")
                    UserDefaults.standard.synchronize()
                    
                    let imageUrl = mainData.value(forKey: "cover") as? String
                    UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                    UserDefaults.standard.synchronize()
                    SVProgressHUD.dismiss()
                    
                    musicTableView.reloadData()
                    
                }
            }
            
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {

            if bhajanArray.count == 0 {
            }  else {
                var songs: Array<Audio> = []
                
                for music in bhajanArray {
                    
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
                controller.trackType = 6
                controller.recentTrackType = 6
                controller.allAudioArray = bhajanArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = false
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.bhajanArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                
                musicTableView.reloadData()
            }
            
        }else {
            if eveningSatsangArray.count == 0 {
                
            }  else {
                
                var songs: Array<Audio> = []
                
                for music in eveningSatsangArray {
                    
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
                controller.trackType = 7
                controller.recentTrackType = 7
                controller.allAudioArray = eveningSatsangArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = false
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.eveningSatsangArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                musicTableView.reloadData()
            }
            
            
            //            let selectMeditaionType = eveningSatsangArray[sender.tag]
            //
            //            // print(sender.tag)
            //            let song = Audio(soundDictonary: selectMeditaionType as NSDictionary)
            //            self.songs = [song]
            //            let count = self.songs.count
            //            let x = UInt32(count)
            //            let randomIdx = Int(arc4random_uniform(x)+0)
            //
            //            GLOBAL_CONTROLLER = "radio"
            //
            //            if let track = self.playlist?.trackAtIndex(randomIdx) {
            //
            //                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
            //                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
            //                AudioPlayer.sharedAudioPlayer.play(track)
            //            }
            //            let mainDta = self.eveningSatsangArray[sender.tag] as NSDictionary
            //
            //            let name = mainDta.value(forKey: "name") as? String
            //            UserDefaults.standard.set(name, forKey: "audioFileName")
            //            UserDefaults.standard.synchronize()
            //            let imageUrl = mainDta.value(forKey: "cover") as? String
            //            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
            //            UserDefaults.standard.synchronize()
            //            let controller = RadioStreamViewController.sharedInstance
            //            controller.trackType = 7
            //            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        //        secondViewController.communityId = id
        //        secondViewController.parentId = parentId
        var mainData = NSDictionary()
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            mainData = self.meditationMusicArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "3"
            self.present(secondViewController, animated: true, completion: nil)
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            mainData = self.bhajanArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "8"
            self.present(secondViewController, animated: true, completion: nil)
            
        } else {
            mainData = self.eveningSatsangArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "9"
            self.present(secondViewController, animated: true, completion: nil)
        }
    }
    
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            let mainDta = self.meditationMusicArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                //self.showProgressBar()
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            let mainDta = self.bhajanArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                //self.showProgressBar()
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            
        }else {
            let mainDta = self.eveningSatsangArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                // self.showProgressBar()
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
            
        }
        
    }
    @objc func downloadTagButton(sender: UIButton) {
        Utilities.displayToastMessage("Song already downloaded...!!!")
    }
    @objc func playerDidStartPlaying() {
        
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
extension MusicViewController {
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
                    let mainDta = self.meditationMusicArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else if selectedIndex == 1 {
                    let mainDta = self.bhajanArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                    
                }else if selectedIndex == 2 {
                    let mainDta = self.eveningSatsangArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
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
extension MusicViewController: CZPickerViewDelegate, CZPickerViewDataSource {
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
