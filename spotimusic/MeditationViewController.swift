//
//  MeditationViewController.swift
//  spotimusic
//
//  Created by Mac on 25/07/18.
//




import UIKit
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
import Alamofire
import CoreData
import Kingfisher
import CZPicker
class MeditationViewController: BaseViewController , UITableViewDataSource , UITableViewDelegate , languageDelegate,UISearchBarDelegate{

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var techView: UIView!
    @IBOutlet weak var techHeight: NSLayoutConstraint!
    @IBOutlet weak var langButton: UIBarButtonItem!
    @IBOutlet weak var langHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var langView: UIView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var meditationTableView: UITableView!
    
    @IBOutlet weak var langNameLabel: UILabel!
    @IBOutlet weak var langImageView: UIImageView!
    var subscriptionStatus  = false
    var searchMusicArray = [[String : AnyObject]]()
    var searchInterviewsArray = [[String : AnyObject]]()
    var meditationArray = [[String : AnyObject]]()
    var meditationThArray = [[String : AnyObject]]()
    var meditationtTechArray = [[String : AnyObject]]()
    var searchActive : Bool = false
    var downloadFiles = [NSManagedObject]()
    var categoty = String()
    var selectedIndex = Int()
    var fromDrawer : Bool?
    var searchText : String?
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var reachabilitysz: Reachability!
    var refreshControl: UIRefreshControl!
    var albId : String?
    var albName : String?
    var abid : String?
    var items : NSArray!
    var trackIds: String!
    var currentSelectedIndex = Int()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MeditationViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // searchBar.searchTextField.textColor = .white
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        albId = UserDefaults.standard.string(forKey: "defaultLanguageId")
        searchBar.delegate = self
        self.meditationTableView.delegate = self
        self.meditationTableView.dataSource = self
        self.langHeight.constant = 0
        self.techHeight.constant = 0
        self.langView.isHidden = true
        self.techView.isHidden = true
        self.langNameLabel.isHidden = true
        self.langImageView.isHidden = true
        self.langButton.image = UIImage.init(named: "")
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.meditationTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.meditationTableView.addSubview(self.refreshControl)
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
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
        for segmentViews in segmentControl.subviews {
            for segmentLabel in segmentViews.subviews {
                if segmentLabel is UILabel {
                    (segmentLabel as! UILabel).numberOfLines = 0
                }
            }
        }
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RED_COLOR as Any], for: .selected)
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
    @objc func pullToRefreshHandler() {
        albId = UserDefaults.standard.string(forKey: "defaultLanguageId")
        self.meditationTableView.reloadData()
        self.refreshControl.endRefreshing()
        // refresh table view data here
    }
    override func viewWillAppear(_ animated: Bool) {
        categoty = (UserDefaults.standard.value(forKey: "category") as? String)!
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        self.title = categoty
        self.getAllMeditations()
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        albId = UserDefaults.standard.string(forKey: "defaultLanguageId")
        langNameLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
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
        segmentControl.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
        print("selectedIndex",selectedIndex)
        self.currentSelectedIndex = selectedIndex
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBar), name: NSNotification.Name(rawValue: "showProgressBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBarError), name: NSNotification.Name(rawValue: "showProgressBarError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
        
    }
    @objc func callBack(){
        DispatchQueue.main.async(execute: {
            self.subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
            if self.subscriptionStatus == true {
                print("User subscribed")
            }else {
                //IronSource.showRewardedVideo(with: self)
                self.showAdds()
            }
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @objc func showProgressBar() {
    }
    @objc func showProgressBarError() {
    }
    
    func languageSelect(_ album_Id: String, album_Name: String) {
        albId = album_Id
        langNameLabel.text = album_Name
        self.getAllMeditations()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tapSegment(sender: UISegmentedControl) {
       // self.showAd()
            if sender.selectedSegmentIndex == 0 {
                subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                if subscriptionStatus == true {
                    print("User subscribed")
                }else {
                    //showAdds()
                    //IronSource.showRewardedVideo(with: self)
                }
                self.selectedIndex = 0
                self.currentSelectedIndex = 0
                searchBar.text = ""
                searchBar.resignFirstResponder()
                searchActive = false
                self.getAllMeditations()
                self.langHeight.constant = 0
                self.techHeight.constant = 0
                self.langView.isHidden = true
                self.techView.isHidden = true
                self.langNameLabel.isHidden = true
                self.langImageView.isHidden = true
                
                self.currentSelectedIndex = 0
                self.langButton.image = UIImage.init(named: "")
                self.title = "Meditation"
                self.langButton.isEnabled = false
                self.langNameLabel.textAlignment = .right
                searchBar.placeholder = "Search Here"
            }else if sender.selectedSegmentIndex == 1 {
                fromDrawer = false
                subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                if subscriptionStatus == true {
                    print("User subscribed")
                }else {
                   // showAdds()
                   // IronSource.showRewardedVideo(with: self)
                }
                self.selectedIndex = 1
                 self.currentSelectedIndex = 1
                searchBar.text = ""
                searchBar.resignFirstResponder()
                searchActive = false
                self.getAllMeditations()
                self.langHeight.constant = 60
                self.techHeight.constant = 30
                self.langView.isHidden = false
                self.techView.isHidden = true
                self.langNameLabel.isHidden = false
                self.langImageView.isHidden = false
                self.langButton.isEnabled = true
                self.langButton.image = UIImage.init(named: "filter")
                self.title = "Bhagwan Speaks"
                self.langButton.isEnabled = true
                searchBar.placeholder = "Search Here"
            }else {
                 subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                 if subscriptionStatus == true {
                     print("User subscribed")
                 }else {
                   // showAdds()
                    //IronSource.showRewardedVideo(with: self)
                 }
                self.selectedIndex = 2
                self.currentSelectedIndex = 2
                searchBar.text = ""
                searchBar.resignFirstResponder()
                searchActive = false
                self.getAllMeditations()
                self.langHeight.constant = 0
                self.techHeight.constant = 0
                self.langButton.isEnabled = false
                self.langView.isHidden = true
                self.techView.isHidden = false
                self.langNameLabel.isHidden = true
                self.langImageView.isHidden = true
                self.langButton.image = UIImage.init(named: "")
                self.title = "Gibberish"
            }
    }
    //all meditations
    func getAllMeditations(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_MEDITATION_SEARCH)
       // print(urlResponce)
        var parameters = [String: Any]()
        self.getHideShow(istableReload: false)
        if self.selectedIndex == 0 {
            parameters = [
                            "searchterm" :"",
                            "type" : "1",
            ]
        } else if self.selectedIndex == 1 {
            parameters = [
                            "searchterm" :"",
                            "type" : "2",
                            "album_id" : albId ?? "" ,
            ]
        }else {
            parameters = [
                            "searchterm" :"",
                            "type" : "3",
            ]
        }
        if searchActive == true {
            if let searchtext = self.searchText {
                parameters["searchterm"] = searchtext
            }
        }
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 100
        parameters["offset"] = 0
        Alamofire.request( urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                   // print("Dashboard_response",response)
                    if let itms = response.result.value {
                        let itemss = itms as! NSDictionary
                        let array = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        if array.count > 0 {
                            for i in (0..<array.count) {
                                if self.selectedIndex == 0 {
                                    self.meditationArray.append(array[i])
                                    self.meditationTableView!.reloadData()
                                }else if self.selectedIndex == 1 {
                                    self.meditationThArray.append(array[i])
                                    self.meditationTableView!.reloadData()
                                }else if self.selectedIndex == 2 {
                                    self.meditationtTechArray.append(array[i])
                                    // print("meditationThArray",self.meditationtTechArray)
                                    self.meditationTableView!.reloadData()
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
    // hide show array and table {
    func getHideShow(istableReload: Bool) {
        if self.meditationArray.count != 0 && self.selectedIndex == 0 {
            self.meditationArray.removeAll()
            self.noDataLabel.isHidden = true
        }else if self.meditationThArray.count != 0 && self.selectedIndex == 1 {
            self.meditationThArray.removeAll()
            self.noDataLabel.isHidden = true
        }else if self.meditationtTechArray.count != 0 && self.selectedIndex == 2 {
            self.meditationtTechArray.removeAll()
            self.noDataLabel.isHidden = true
        }
        if istableReload {
            self.meditationTableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == 0 {
            return meditationArray.count
        }else if selectedIndex == 1 {
            return meditationThArray.count
        }else if selectedIndex == 2 {
            return meditationtTechArray.count
        }
       return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = meditationTableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        var mainDta = NSDictionary()
        cell.commonImageView.isHidden = false
        cell.playingTrackGIFImageView.isHidden = true
        cell.unlockButton.isHidden = true
        cell.descriptionLabel.text = "Meditation"
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        cell.downloadSongTagButton.tag = indexPath.row
        cell.downloadSongTagButton.addTarget(self, action: #selector(downloadTagButton), for: .touchUpInside)
        if self.meditationArray.count != 0 && selectedIndex == 0 {
            
            mainDta = self.meditationArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
           //playing track GIF image
            for data in mainDta {
              if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
                   print("0123456",id)
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
            //playing track GIF image
            /*if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
                 print("0123456",id)
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
            }*/
            //download song tag
            if isdownloaded {
                cell.downloadButton.isHidden = true
                cell.downloadSongTagButton.isHidden = false
            }else {
                cell.downloadButton.isHidden = false
                cell.downloadSongTagButton.isHidden = true
            }
            
        }else if self.meditationThArray.count != 0 && selectedIndex == 1 {
            
            mainDta = self.meditationThArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            
            //playing track GIF image
            for data in mainDta {
              if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
                   print("0123456",id)
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
           /* if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
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
            }*/
            
            //download song tag
            if isdownloaded {
                cell.downloadButton.isHidden = true
                cell.downloadSongTagButton.isHidden = false
            }else {
                cell.downloadButton.isHidden = false
                cell.downloadSongTagButton.isHidden = true
            }
            
        }else if self.meditationtTechArray.count != 0 && selectedIndex == 2 {
            mainDta = self.meditationtTechArray[indexPath.row] as NSDictionary
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadSongs(sender:)), for:.touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            //playing track GIF image
            for data in mainDta {
              if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
                   print("0123456",id)
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
           /* if let playingId = UserDefaults.standard.value(forKey: "playingtarckId") , let id = mainDta.value(forKey: "id") as? String{
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
            }*/

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
            cell.commonImageView.layer.borderWidth = 1.0
    
            let name = mainDta.value(forKey: "name") as? String
            let imageUrl = mainDta.value(forKey: "cover") as? String
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT, AUDIO,imageUrl!)
            let url = URL(string: imgeFile)
            print("imgeFile",imgeFile)
            DispatchQueue.main.async(execute: {
                if let _ = cell.commonImageView {
                    cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
                cell.commonName.text = name
            })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
           if self.meditationArray.count != 0 && selectedIndex == 0 {
                   let mainDta = self.meditationArray[indexPath.row] as NSDictionary
                   trackIds = mainDta.value(forKey: "id") as? String
                   self.showAlertPickerView()
        }else if self.meditationThArray.count != 0 && selectedIndex == 1 {
                          let mainDta = self.meditationThArray[indexPath.row] as NSDictionary
                          trackIds = mainDta.value(forKey: "id") as? String
                          self.showAlertPickerView()
        }else if self.meditationtTechArray.count != 0 && selectedIndex == 2 {
                          let mainDta = self.meditationtTechArray[indexPath.row] as NSDictionary
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
    @objc func playSong(sender : UIButton){
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            if currentSelectedIndex == selectedIndex {
                if meditationArray.count == 0 {
                }  else {
                    var songs: Array<Audio> = []
                    for music in meditationArray {
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
                    controller.trackType = 2
                    controller.recentTrackType = 2
                    controller.allAudioArray = meditationArray
                    controller.indexOfSong = sender.tag
                    controller.isFromAudios = true
                    controller.isFromQA = false
                    controller.isFromHome = false
                    controller.isFromPlayList = false
                    controller.isFromRecentPlayList = false
                    controller.isFromCommunity = false
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                    
                    let mainData = self.meditationArray[sender.tag] as NSDictionary
                    let name = mainData.value(forKey: "name") as? String
                    UserDefaults.standard.set(name, forKey: "audioFileName")
                    UserDefaults.standard.synchronize()
                    
                    let imageUrl = mainData.value(forKey: "cover") as? String
                    UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                    UserDefaults.standard.synchronize()
                    SVProgressHUD.dismiss()
                    meditationTableView.reloadData()
                }
            }
            
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            
            if meditationThArray.count == 0 {
                
            }  else {
                
                var songs: Array<Audio> = []
                for music in meditationThArray {
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
                controller.trackType = 2
                controller.recentTrackType = 2
                controller.allAudioArray = meditationThArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = false
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.meditationThArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                
                meditationTableView.reloadData()
            }
        }else {
        
            
            if meditationtTechArray.count == 0 {
                
            }  else {
                
                var songs: Array<Audio> = []
                
                for music in meditationtTechArray {
                    
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
                controller.trackType = 2
                controller.recentTrackType = 2
                controller.allAudioArray = meditationtTechArray
                controller.indexOfSong = sender.tag
                controller.isFromAudios = true
                controller.isFromQA = false
                controller.isFromHome = false
                controller.isFromPlayList = false
                controller.isFromRecentPlayList = false
                controller.isFromCommunity = false
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
                
                let mainData = self.meditationtTechArray[sender.tag] as NSDictionary
                let name = mainData.value(forKey: "name") as? String
                UserDefaults.standard.set(name, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
                
                let imageUrl = mainData.value(forKey: "cover") as? String
                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                
                meditationTableView.reloadData()
                
            }
        }
        
    }
    
    @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
       if selectedIndex == 0  && currentSelectedIndex == 0 {
            mainData = self.meditationArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "2"
            self.present(secondViewController, animated: true, completion: nil)
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            mainData = self.meditationThArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "2"
            self.present(secondViewController, animated: true, completion: nil)
            
       } else {
        mainData = self.meditationtTechArray[sender.tag] as NSDictionary
        secondViewController.isShare = true
        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
        secondViewController.trackType = "2"
        self.present(secondViewController, animated: true, completion: nil)
        
        }
    }
    
    
    @objc func downloadSongs(sender: UIButton) {
    
        if selectedIndex == 0  && currentSelectedIndex == 0 {
            if currentSelectedIndex == selectedIndex {
                let button = sender as UIButton
                let index = button.tag
                var fileType = ""
                let mainDta = self.meditationArray[index] as NSDictionary
                let fileName = mainDta.value(forKey: "name") as! String
                let fileId = mainDta.value(forKey: "file") as! String
                 let fileImage = mainDta.value(forKey: "cover") as! String
                fileType = "Audio"
                if  DownloadManager.getDownloadedObject(predicate: fileId ) {
                    DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
                }else {
                    Utilities.displayToastMessage("Song already downloaded...!!!")
                }
                }
            
        } else if selectedIndex == 1 && currentSelectedIndex == 1 {
            
            let selectMeditaionType = meditationThArray[sender.tag]
            
            let button = sender as UIButton
            let index = button.tag
            var fileType = ""
            let mainDta = self.meditationThArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
            let fileImage = mainDta.value(forKey: "cover") as! String
            fileType = "Audio"
            if  DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
        }else {
            let selectMeditaionType = meditationtTechArray[sender.tag]
            let button = sender as UIButton
            let index = button.tag
            var fileType = ""
            let mainDta = self.meditationtTechArray[index] as NSDictionary
            let fileName = mainDta.value(forKey: "name") as! String
            let fileId = mainDta.value(forKey: "file") as! String
             let fileImage = mainDta.value(forKey: "cover") as! String
            fileType = "Audio"
            if DownloadManager.getDownloadedObject(predicate: fileId ){
                DownloadManager.downloadSongs(mainDta: mainDta, type: fileType)
            }else {
                Utilities.displayToastMessage("Song already downloaded...!!!")
            }
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
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type":2,"X-API-KEY":API_GENERAL_KEY])
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lang_to_medi"{
            let vc = segue.destination as! LanguagePopViewController
            vc.langDelegate = self
            searchBar.resignFirstResponder()
        }
    }
    
    //MARK: UISearchbar delegate
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
         self.getAllMeditations()
            self.searchText = searchText
        self.getHideShow(istableReload: false)
        
    }
    
    @objc func playerDidStartPlaying() {
        
    }
}
extension MeditationViewController {
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
                    let mainDta = self.meditationArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else if selectedIndex == 1 {
                    let mainDta = self.meditationThArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else if selectedIndex == 2 {
                    let mainDta = self.meditationtTechArray[index] as NSDictionary
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
extension MeditationViewController: CZPickerViewDelegate, CZPickerViewDataSource {
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
