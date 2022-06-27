//
//  RadioStreamViewController.swift
//  spotimusic
//
//  Created by appteve on 02/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer
import CoreData
import CZPicker
import KVNProgress
import Kingfisher
import SVProgressHUD
import MarqueeLabel
import SCLAlertView
import Reachability
private var _sharedPlayerViewController: RadioStreamViewController!

protocol RadioStreamViewControllerDelegate: NSObjectProtocol {
    func playerViewControllerPlayPauseButtonPressed(_ playerViewController: RadioStreamViewController!)
    func playerViewControllerPauseButtonPressed(_ playerViewController: RadioStreamViewController!)
    func playerViewControllerPreviousTackButtonPressed(_ playerViewController: RadioStreamViewController!)
    func playerViewControllerNextTackButtonPressed(_ playerViewController: RadioStreamViewController!)
    func playerViewController(_ playerViewController: RadioStreamViewController!, progressSliderValueChanged value: Float)
}

class RadioStreamViewController: UIViewController, HalfModalPresentable{
    
    static let sharedInstance = RadioStreamViewController.instantiateFromStoryBoard()
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastRewindButton: UIButton!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var mixName: MarqueeLabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    weak var delegate: RadioStreamViewControllerDelegate?
    var subscriptionStatus  = false
    var trackType = 1
    var recentTrackType = 1
    var users = [NSManagedObject]()
    var stationId: String!
    var countTrack = 0
    var trackImage: UIImage!
    var titleSound: String!
    var userIds: String!
    var trackIds: String!
    var pickerWithImage: CZPickerView?
    var artistIds: String!
    var shareTxt: String!
    var isLike = true
    var items : NSArray!
    //var interstitial: GADInterstitial!
    var timerListen: Timer!
    var countTime = 0
    var imageUrl : String!
    var reachabilitysz: Reachability!
    var allAudioArray = [[String : AnyObject]]()
    var AllHomeAudioArray = [[String : AnyObject]]()
   // var playList = [[String : AnyObject]]()
    var playList  : NSArray!
    var recentPlayList : NSArray!
    var indexOfSong = Int ()
    var isFromHome = Bool ()
    var isFromHomeRecetPlay = Bool ()
    var isFromPlayList = Bool ()
    var isFromRecentPlayList = Bool ()
    var isFromAudios = Bool ()
    var isFromCommunity = Bool ()
    var trackNum = Int ()
    var currentIndex = Int ()
    var isPurchase : Bool?
    var isFromDiscourse : Bool?
    var isFromQA : Bool?
    let kAPPKEY = "a4fd26cd"
    var adsTimer: Timer!
    fileprivate class func instantiateFromStoryBoard() -> RadioStreamViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "rsViewController") as! RadioStreamViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIronSourceSdk()
        self.musicpalyerOnNotificationBar()
        mixName.type = .continuous
        mixName.animationCurve = .easeInOut
        self.mixName.speed = .duration(50)
        //reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()            
        } else {
        }
        progressSlider.addTarget(self, action: #selector(RadioStreamViewController.userReleasedSlider(_:)), for: UIControl.Event.touchUpInside)
        progressSlider.addTarget(self, action: #selector(RadioStreamViewController.userTapSlider(_:)), for: UIControl.Event.touchDown)
       
        
        timerListen = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RadioStreamViewController.update), userInfo: nil, repeats: true)
        
        if let idss = GLOBAL_USER_ID {
            self.userIds = idss.stringValue
        }
        self.titleSound = ""
        self.stationId = GLOBAL_CONTROLLER
       // let thumbImageNormal = UIImage(named: "vol")
       // progressSlider.setThumbImage(thumbImageNormal, for: UIControl.State())
       // progressSlider.setThumbImage(thumbImageNormal, for: UIControl.State.selected)
       
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RadioStreamViewController.updateProgress), userInfo: nil, repeats: true)
        
        countTrack = AudioPlayer.sharedAudioPlayer.playlist!.count()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(RadioStreamViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timerListen.invalidate()
    }
    
    fileprivate func loadInterstitial() {
        //interstitial = GADInterstitial(adUnitID: GOOGLE_ADMOB_INTER)
        //interstitial!.delegate = self
        //interstitial!.load(GADRequest())
    }
//    func interstitialDidDismissScreen (_ interstitial: GADInterstitial) {
//        print("interstitialDidDismissScreen")
//
//    }
    
    func banners(){
    }
    
    @objc func update() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func userReleasedSlider(_ slider: UISlider) {
    }
    
    @objc func userTapSlider(_ slider: UISlider) {
    }
    
    func putShadowOnView(_ viewToWorkUpon:UIView, shadowColor:UIColor, radius:CGFloat, offset:CGSize, opacity:Float)-> UIView{
        
        var shadowFrame = CGRect.zero
        shadowFrame.size.width = 0.0
        shadowFrame.size.height = 0.0
        shadowFrame.origin.x = 0.0
        shadowFrame.origin.y = 0.0
        
        let shadow = UIView(frame: shadowFrame)
        shadow.isUserInteractionEnabled = false;
        shadow.layer.shadowColor = shadowColor.cgColor
        shadow.layer.shadowOffset = offset
        shadow.layer.shadowRadius = radius
        shadow.layer.masksToBounds = false
        shadow.clipsToBounds = false
        shadow.layer.shadowOpacity = opacity
        viewToWorkUpon.superview?.insertSubview(shadow, belowSubview: viewToWorkUpon)
        shadow.addSubview(viewToWorkUpon)
        return shadow
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
           
            case UISwipeGestureRecognizer.Direction.down:
                self.dismiss(animated: true) {
                }
            
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkLikes(_ user: String, track:String){
    }
    
    
    func clearTrackInfo() {
        
       // albumArtImageView?.image = self.trackImage
        trackNumberLabel?.text = "1 of 1"
    }
    
    func updateTackInfo () {
        clearTrackInfo()
        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else {
            
            return
        }
        if isFromDiscourse == true {
            if let title = track.discourseTitle{
                //self.artistName?.text = "Global radio"
                self.mixName?.text = title
                //print("title",title)
                self.titleSound = title
                
            } else {
            }
        }else{
            if let title = track.title{
                //self.artistName?.text = "Global radio"
                self.mixName?.text = title
                //print("title",title)
                self.titleSound = title
                
            } else {
            }
        }
        
        
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            trackNumberLabel?.text = "\(index+1) of \(count)"
            currentIndex = index
            }
        trackIds = track.trackId
        artistIds = track.artistId
        
        UserDefaults.standard.set(trackIds, forKey: "playingtarckId")
        UserDefaults.standard.synchronize()
        print("currentIndex",currentIndex)
        if currentIndex != 0  {
            if rewindButton != nil{
                //   rewindButton.isHidden = false
            }
        }
        self.shareTxt = String(format: "%@ - %@",track.artist!,track.title!)
       
        findCover(track.artist!)
        findCoverDownload(track.artist!)
        
        if GLOBAL_CONTROLLER == "offline" {
           
        } else {
        }
    }
    
    func configureControlButtons() {
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
        case
        STKAudioPlayerState(),
        STKAudioPlayerState.paused,
        STKAudioPlayerState.stopped,
        STKAudioPlayerState.error,
        STKAudioPlayerState.disposed:
            if let play_Button = playButton {
                playButton.setImage(UIImage(named: "play-button-1.png"), for: UIControl.State())
            }
        case
        STKAudioPlayerState.playing,
        STKAudioPlayerState.buffering:
            if let play_button = playButton {
                playButton.setImage(UIImage(named: "pause-1.png"), for: UIControl.State())
            }
        default: break
        }
    }
    
    @objc func updateProgress() {
        progressSlider.value = Float(AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress / AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration)
        
        let elapsed = AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress as TimeInterval
        elapsedTimeLabel.text = Utilities.prettifyTime(elapsed)

        let remaining = (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration - AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress) as TimeInterval
        remainingTimeLabel.text = Utilities.prettifyTime(remaining)

    }
    
    func configure() {
        updateProgress()
        configureControlButtons()
    }
    
    func sliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = progressSlider.frame.origin
        let widthOfSlider: CGFloat = progressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(progressSlider.maximumValue) / widthOfSlider)
        progressSlider.setValue(Float(newValue), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            self.musicpalyerOnNotificationBar()
        UserDefaults.standard.set(false, forKey: "isTrackInList")
        UserDefaults.standard.synchronize()
            RecentPlayTrackData.shared.recentplayTrack1(trackId: trackIds, trackType: recentTrackType)
//        if isHome == true {
//        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
//        }

        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.adsCallBack), userInfo: nil, repeats: true)
       if let pur = UserDefaults.standard.value(forKey: "isPurchased") {
        self.isPurchase = pur as? Bool
        }
        updateTackInfo()
        
        if isFromCommunity == true || isFromPlayList == true || isFromRecentPlayList == true || isFromHomeRecetPlay == true{
            menuButton.isHidden = true
        } else {
           // menuButton.isHidden = false
        }
        
         if isFromCommunity == true {
               fastRewindButton.isHidden = true
               rewindButton.isHidden = true
         }else { //if isFromCommunity != true  || isFromHomeRecetPlay != true 
               fastRewindButton.isHidden = false
               rewindButton.isHidden = false
        }
                
        albumArtImageView.layer.shadowColor = UIColor.black.cgColor
        albumArtImageView.layer.shadowOpacity = 1
        albumArtImageView.layer.shadowOffset = CGSize.zero
        albumArtImageView.layer.shadowRadius = 10

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        tabBarController?.tabBar.isHidden = true
        
        self.stationId = GLOBAL_CONTROLLER
        if self.stationId != nil {
        } else {
            print("ID  nil")
            self.stationId = "library"
            GLOBAL_CONTROLLER = "library"
        }
        updateTackInfo()
        configure()
        updateProgress()
    }
    @objc func adsCallBack(){
         subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
                   if subscriptionStatus == true {
                       print("User subscribed")
                   }else {
                    IronSource.showRewardedVideo(with: self)
               }
    }
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

    @IBAction func playButtonPressed(_ sender: AnyObject) {
        delegate?.playerViewControllerPlayPauseButtonPressed(self)
        updateTackInfo()
        configureControlButtons()
    }
    
    @IBAction func rewindButtonPressed(_ sender: AnyObject) {
        RecentPlayTrackData.shared.recentplayTrack1(trackId: trackIds, trackType: recentTrackType)
//        if isFromQA == true {
//            Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
//        }
        fastRewindButton.isEnabled = true
        delegate?.playerViewControllerPreviousTackButtonPressed(self)
        updateTackInfo()
        configure()
        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else {
            return
        }
        if isFromDiscourse == true {
            if let title = track.discourseTitle{
                
                //self.artistName?.text = "Global radio"
                self.mixName?.text = title
                self.titleSound = title
                UserDefaults.standard.set(title, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
            } else {
            }
        }else{
            if let title = track.title{
                
                //self.artistName?.text = "Global radio"
                self.mixName?.text = title
                self.titleSound = title
                UserDefaults.standard.set(title, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
            } else {
            }
        }
       
        
        if let coverImage = track.imageString {
            print("coverImage",coverImage)
            UserDefaults.standard.set(coverImage, forKey: "audioFileImage")
            UserDefaults.standard.synchronize()
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,coverImage)
            
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = self.albumArtImageView {
                        self.albumArtImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
            
        }else {
        }
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            trackNumberLabel?.text = "\(index+1) of \(count)"
            
            trackNum = index
            print("trackNum",trackNum)

            
            if isFromHome == true {
                if (AllHomeAudioArray.count - 1) != index{
                }
            }else if isFromAudios == true{
                if (allAudioArray.count - 1) != index{
                }
            }else if isFromPlayList == true {
                if (playList.count - 1) != index{
                }
            }else if isFromRecentPlayList == true {
                if (recentPlayList.count - 1) != index{
                }
            }
            
            if index == 0 {
                Utilities.displayToastMessage("No more songs in Queue")
            }
            
        }
        
        
    }
    
    @IBAction func fastRewindButtonPressed(_ sender: AnyObject) {
        RecentPlayTrackData.shared.recentplayTrack1(trackId: trackIds, trackType: recentTrackType)
//        if isFromQA == true {
//            Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
//        }
        delegate?.playerViewControllerNextTackButtonPressed(self)
        updateTackInfo()
        configure()
        timerListen.invalidate()
        timerListen = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RadioStreamViewController.update), userInfo: nil, repeats: true)
        
        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else {
            
            return
        }
        if isFromDiscourse == true {
            if let title = track.discourseTitle{
                self.mixName?.text = title
                self.titleSound = title
                UserDefaults.standard.set(title, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
            } else {
            }
        }else {
            if let title = track.title{
                self.mixName?.text = title
                self.titleSound = title
                UserDefaults.standard.set(title, forKey: "audioFileName")
                UserDefaults.standard.synchronize()
            } else {
            }
        }
        
        if let coverImage = track.imageString {
            print("coverImage",coverImage)
            UserDefaults.standard.set(coverImage, forKey: "audioFileImage")
            UserDefaults.standard.synchronize()
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,coverImage)
            
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = self.albumArtImageView {
                        self.albumArtImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
            
        }else {
        }
        
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            trackNumberLabel?.text = "\(index+1) of \(count)"
            trackNum = index
            print("trackNum",trackNum)
            if isFromHome == true {
                if (AllHomeAudioArray.count - 1) == index {
                    Utilities.displayToastMessage("No more songs in Queue")
                    SVProgressHUD.dismiss()
                }
            } else  if isFromPlayList == true {
                if (playList.count - 1) == index {
                    Utilities.displayToastMessage("No more songs in Queue")
                    SVProgressHUD.dismiss()
                }
            }else if isFromAudios == true {
                if (allAudioArray.count - 1) == index{
                    Utilities.displayToastMessage("No more songs in Queue")
                    SVProgressHUD.dismiss()
                }
            }else  if isFromRecentPlayList == true {
                if (recentPlayList.count - 1) == index {
                    Utilities.displayToastMessage("No more songs in Queue")
                    SVProgressHUD.dismiss()
                }
            }
        }
        
        print("rwnd")
        
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        delegate?.playerViewController(self, progressSliderValueChanged: sender.value)
    }
    
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func findCover(_ song:String){
        
        let url = URL(string: imageUrl)
        //print("imageurl",url)
        
        DispatchQueue.main.async(execute: {
            if let url = URL(string: self.imageUrl){
                if let _ = self.albumArtImageView {
                    self.albumArtImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
            }
            
        })
    }
    
    func findCoverDownload(_ song:String){
        
        if  let imageUrl = UserDefaults.standard.value(forKey: "audioFileImage") as? String {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl)
            
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = self.albumArtImageView {
                        self.albumArtImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
                
            })
        }
       
    }
    
    @IBAction func menuAz(){
        
        let actionSheet: AHKActionSheet = AHKActionSheet(title: nil)
        actionSheet.blurTintColor = UIColor(white: 0.0, alpha: 0.75)
        actionSheet.blurRadius = 8.0
        actionSheet.buttonHeight = 50.0
        actionSheet.cancelButtonHeight = 50.0
        actionSheet.animationDuration = 0.5
        actionSheet.cancelButtonShadowColor = UIColor(white: 0.0, alpha: 0.1)
        actionSheet.separatorColor = UIColor(white: 1.0, alpha: 0.3)
        actionSheet.selectedBackgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let defaultFont: UIFont = UIFont(name: "Avenir", size: 17.0)!
        actionSheet.buttonTextAttributes = [NSAttributedString.Key.font: defaultFont, NSAttributedString.Key.foregroundColor: UIColor.white]
        actionSheet.disabledButtonTextAttributes = [NSAttributedString.Key.font: defaultFont, NSAttributedString.Key.foregroundColor: UIColor.gray]
        actionSheet.destructiveButtonTextAttributes = [NSAttributedString.Key.font: defaultFont, NSAttributedString.Key.foregroundColor: UIColor.red]
        actionSheet.cancelButtonTextAttributes = [NSAttributedString.Key.font: defaultFont, NSAttributedString.Key.foregroundColor: UIColor.white]

        actionSheet.addButton(withTitle: "Add to playlist", image: UIImage(named: "playlist.png"), type: .default, handler: {(AHKActionSheet) -> Void in
            
            self.showAlertPickerView()
        })
        actionSheet.addButton(withTitle: "Share", image: UIImage(named: "shareApp"), type: .default, handler: {(AHKActionSheet) -> Void in
            
            
            self.shareBtns()
        })
        
        actionSheet.show()
        
    }
    
    func shareBtns (){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        secondViewController.isShare = true
        secondViewController.trackId = trackIds
        secondViewController.trackType = "1"
         self.present(secondViewController, animated: true, completion: nil)
    }


    
    func addTrackToUserLibrary(_ user:String, track:String){
       // SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@", BASE_URL_BACKEND,ENDPOINT_USER_TRACK_SAVE)
        
        Alamofire.request( urlRequest,method: .post ,parameters: ["user_id": user,"track_id":track,"X-API-KEY":API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success :
                    
                    print("Save trak",response)
                    
                    guard let json = response.result.value else {return}
                    let JSON = json as! NSDictionary
                    print("TrackJSON",JSON)
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
    
    //////// plist
    
    func showAlertPickerView( ) {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_USER_PLIST)
        print("addlistUrl",urlRequest)
        if let  userId = GLOBAL_USER_ID {
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
                               self.items =  val as! NSArray
                               
                               if self.items.count > 0 {
                                   DispatchQueue.main.async() {
                                       
                                       let picker = CZPickerView(headerTitle: "Playlist", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
                                       picker?.dataSource = self
                                       picker?.delegate = self
                                       picker?.needFooterView = true
                                       picker?.headerBackgroundColor = UIColor(red:35/255, green:194/255, blue:14/255, alpha:1.00)//
                                    picker?.confirmButtonBackgroundColor =  UIColor.init(red:35/255, green:194/255, blue:14/255, alpha:1.00)
                                       picker?.show()
                                       
                                   }
                               } else {
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
    
    
    func dislikeTrack(){

    }
    
    @IBAction func likeS(){
    }
    
    
    @IBAction func backOn(){
        self.dismiss(animated: true) {
        }
    }
}

extension RadioStreamViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return items.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        let name  = (items[row] as AnyObject).value(forKey: "name") as! String
        
        return name
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print("A1- ",items[row])
        let plId  = (items[row] as AnyObject).value(forKey: "id") as! String
        
        saveTrackInPl(trackIds, playlistId: plId)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if let row = row as? Int {
                print("A2- ",items[row])
            }
        }
    }
}

extension RadioStreamViewController {
    
    func musicpalyerOnNotificationBar() {
        let mpic = MPNowPlayingInfoCenter.default()
        
        func setInfoCenterCredentials(_ postion: NSNumber, _ duration: NSNumber, _ playbackState: Int) {
        
            mpic.nowPlayingInfo = [ MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                                   MPMediaItemPropertyPlaybackDuration: duration,
                                   MPNowPlayingInfoPropertyPlaybackRate: playbackState]
        }
    }
   
}

extension RadioStreamViewController {
    
    func recentplayTrack( trackId : String) {
        // SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_RECENT_PLAY_TRACK)
        
       if  let userId = GLOBAL_USER_ID {
         print("trackId", trackIds)
                print("trackType",recentTrackType)
        Alamofire.request(urlRequest,method: .post, parameters: ["user_id": userId.stringValue,"track_id":trackId,"track_type": recentTrackType,"X-API-KEY":API_GENERAL_KEY])
                    .responseJSON { response in
                        SVProgressHUD.dismiss()
                        
                        switch response.result {
                        case .success :
                            
                            print("Trackresponse",response)
                           
                            guard let json = response.result.value else {return}
                            let JSON = json as! NSDictionary
                            
        //                    let success = JSON.value(forKey: "error") as! NSNumber
        //                    if success == 0 {
        //                        KVNProgress.showSuccess()
        //                    } else {
        //                        KVNProgress.showError()
        //                    }
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
extension RadioStreamViewController : ISRewardedVideoDelegate {
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
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print("Rv Failed to show")
        //Utilities.displayToastMessage("ads not present")
        //AudioPlayer.sharedAudioPlayer.resume()
        //IronSource.showRewardedVideo(with: self)
    }

    func rewardedVideoDidOpen() {
        print("RV Open")
        IronSource.showRewardedVideo(with: self)
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidClose() {
        print("RV Close")
        AudioPlayer.sharedAudioPlayer.pause()
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerSubsciptionPlanViewController") as! PlayerSubsciptionPlanViewController
                vc.isFromMusicPlayer = true
                self.present(vc, animated: true, completion: nil)
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

    func rewardedVideoDidStart() {
        print("RV Start")
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidEnd() {
        print("RV End")
    }

    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        print("RV clicked")
        AudioPlayer.sharedAudioPlayer.pause()
    }


}
extension UITableViewController {
    
}
extension UIViewController {
    
}
