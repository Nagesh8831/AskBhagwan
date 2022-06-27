//
//  HomeViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 30/06/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import AACarousel
import SVProgressHUD
import SCLAlertView
import StoreKit
import AVKit
import AVFoundation
import MediaPlayer
//import GoogleMobileAds
class HomeViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource,AACarouselDelegate,languageDelegate{//GADBannerViewDelegate
    //@IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var imageSlider: AACarousel!
    @IBOutlet weak var gameZopImageView: UIImageView!
    @IBOutlet weak var gameZopButton: UIButton!
    var titleArray = [String]()
    @IBOutlet weak var languageLabel:UILabel!
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    let section = ["Recent Play Tracks","Audio Q & A","Audio Discourses","Music","Interview"]
    var sliderImgesArray : NSArray!
    var categoty = String()
    var sliderDataArray : NSArray!
    var sliderImageArray = [String] ()
    var sliderImgesNameArray  = [String] ()
    var image1 : UIImageView!
    var audios: NSArray!
    var musics: NSArray!
    var meditations: NSArray!
    var interviews: NSArray!
    var users = [NSManagedObject]()
    var userId : UserData!
    var quote = Int ()
    var reachabilitysz: Reachability!
    var isQA = true
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    var album_id : String?
    var album_name : String?
    //Inapp purchase
    var product_id: String?
    var isPurchased : Bool?
    var userID : String?
    var playingID : Int?
    var playingSongArray = [[String:AnyObject]]()
    var recentPlayingID : Int?
    var recentPlayingSongArray = [[String:AnyObject]]()
    var userEmailId = ""
    var userDeviceToken = ""
    var isfromDownload = false
    var subscriptionStatus  = false
    //gogle add
   // var adBannerView: GADBannerView?
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
        homeTableView.backgroundView = UIImageView(image: UIImage(named: "screen_1"))
        self.homeTableView.reloadData()
         //Inapp purchase
       //product_id = "com.askosho.Q_A"
        product_id = IN_APP_PURCHASE_PRODUCT_ID
        self.addGoogleAdMobs()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"",style:.plain,target:nil,action:nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        homeTableView.register(UINib(nibName: "HomeHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            self.checkUserLogin()
            
        } else {
            let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
       // bannerView.addSubview(adBannerView!)
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
        
    }
    @IBAction func gameZopButtonClick(_ sender: Any) {
       // let vc = storyboard.instantiateViewController(identifier: "GameZopViewController") as! GameZopViewController
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameZopViewController") as! GameZopViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("Banner loaded successfully")
//       // self.googleAddView.addSubview(adBannerView!)
//    }
//
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print("Fail to receive ads")
//        print(error)
//    }
    func addGoogleAdMobs(){
//        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
//       // adBannerView?.adUnitID = BANNAER_ADD_UNIT_ID
//        adBannerView?.adUnitID = TEST_BANNER_ADD_UNIT_ID
//        adBannerView?.delegate = self
//        adBannerView?.rootViewController = self
//        adBannerView!.load(GADRequest())
    }
    override func viewWillAppear(_ animated: Bool) {
        getAdMobSubscriptionStatus()
        //IronSource.loadInterstitial()
         Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
        self.musicpalyerOnNotificationBar()
        saveUserDeviceToken()
        gameZopImageView.loadGif(name: "gameZop")
        let dirPath = DownloadManager.sharedManager.documentsDirectory as NSString
        UserDefaults.standard.set(dirPath, forKey: "basePath")
        UserDefaults.standard.synchronize()
        album_id = UserDefaults.standard.string(forKey: "defaultLanguageId")
        languageLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
        // print("dirPath",dirPath)
        self.title = "Ask Bhagwan"
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Quicksand-Regular", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        let trackInlist = UserDefaults.standard.bool(forKey: "isTrackInList") 
        
        if trackInlist == true  {
            if ((AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) == .playing){
                UserDefaults.standard.set(false, forKey: "isTrackInList")
                UserDefaults.standard.synchronize()
            }
        }else {
            if  ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        UserDefaults.standard.set(true, forKey: IN_APP_FROM_HOME)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchaseDone), name: NSNotification.Name(rawValue: IN_APP_PURCHASE_SUCCESS_HOME_NOTIFICATION), object: nil)
        if UserDefaults.standard.bool(forKey: "isAddClose")  && UserDefaults.standard.bool(forKey: "isRecntAudio") == false {
            self.presentAudioViewController(trackType: 1, songIndex: self.playingID!, songArray: self.playingSongArray, isHome: true , isFromShowAdd: false, isFromQA: true)
        }else if UserDefaults.standard.bool(forKey: "isAddClose") && UserDefaults.standard.bool(forKey: "isRecntAudio") == true  {
            self.presentRecentAudioViewController(trackType: 0, songIndex: self.recentPlayingID!, songArray: recentPlayingSongArray, isRecentHome: true, isFromShowAdd: false, isFromQA: true)
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(countryStateUpdateAlert), name: Notification.Name("popUp"), object: nil)
    }
    @objc func countryStateUpdateAlert(){
        showCountryStateUpdateAlert()
    }
    @objc func inAppPurchaseDone() {
        self.homeTableView.reloadData()
    }
        @objc func callBack(){
            //IronSource.showRewardedVideo(with: self)
        }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func checkUserLogin(){
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            users = results as! [NSManagedObject]
            
            if results.count == 0 {
                let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginTableViewController
                loginVC.modalTransitionStyle = .crossDissolve
                 //loginVC.modalTransitionStyle = .fullScreen
                self.present(loginVC, animated: false, completion: nil)
            } else {
                if let idss =  users[0].value(forKey: "user_id") {
                    GLOBAL_USER_ID = idss as? NSNumber
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("UserLoggedIn"), object: nil)
                    self.sliderImges()
                }
                
                if let countryid = UserDefaults.standard.value(forKey: "country_id") as? String, countryid == "0" , let isCountryPopUpShown = UserDefaults.standard.value(forKey: "isCountryPopUpShown") as? Bool, !isCountryPopUpShown {
                    self.updateCountryPopUp()
                }
            }
            
        } catch {
            print("Fetch Failed")
        }
    }
    
    func updateCountryPopUp() {
        UserDefaults.standard.set(true, forKey: "isFromMenu")
        UserDefaults.standard.set(true, forKey: "isCountryPopUpShown")
        let alert = UIAlertController(title: "Ask Bhagwan", message: "Please update country and state from profile section", preferredStyle: .alert)
        let update = UIAlertAction(title: "Update", style: .default) { (_) -> Void in
            // print("Yes")
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(update)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func musicpalyerOnNotificationBar () {
        let mpic = MPNowPlayingInfoCenter.default()
        func setInfoCenterCredentials(_ postion: NSNumber, _ duration: NSNumber, _ playbackState: Int) {
            mpic.nowPlayingInfo = [ MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                                    MPMediaItemPropertyPlaybackDuration: duration,
                                    MPNowPlayingInfoPropertyPlaybackRate: playbackState]
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? HomeTableViewCell
        
        cell?.collectionView.tag = indexPath.section
        cell?.delegate = self
        
        if indexPath.section == 0 {
            cell?.getRecentPlayTrack(completion: { (result :Any) in
                cell?.recentPlayTracks = result as! [[String : AnyObject]]
                cell?.collectionView.tag = indexPath.section
                cell?.collectionView.reloadData()
            })
        } else if indexPath.section == 1 {
            cell?.getAudioQA(completion: {
                (result: Any) in
                cell?.audiosQA = result as! [[String : AnyObject]]
                cell?.collectionView.tag = indexPath.section
                cell?.collectionView.reloadData()
            })
        }else if indexPath.section == 2 {
            cell?.getAudioDiscourse(completion: {
                (result: Any) in
                cell?.audiosDiscourse = result as! [[String : AnyObject]] 
                cell?.collectionView.tag = indexPath.section
                cell?.collectionView.reloadData()
            })
        }else if indexPath.section == 3 {
            cell?.getMusic(completion: {
                (result: Any) in
                cell?.musics = result as! [[String : AnyObject]]
                cell?.collectionView.tag = indexPath.section
                cell?.collectionView.reloadData()
            })
        }
//        else if indexPath.section == 4 {
//            cell?.getInterviews(completion: {
//                (result: Any) in
//                cell?.interviews = result as! [[String : AnyObject]]
//                cell?.collectionView.tag = indexPath.section
//                cell?.collectionView.reloadData()
//            })
//        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeHeaderTableViewCell
        cell.sectionNameLabel.text = self.section[section]
        if section == 0 {
         cell.moreButton.isHidden = true
        }
        cell.moreButton.tag = section
        cell.moreButton.addTarget(self, action: #selector(btnShowHideTapped), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc func btnShowHideTapped(sender : UIButton) {
        if sender.tag == 0 {
//            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioVideoViewController") as! AudioVideoViewController
//            UserDefaults.standard.set("Audio", forKey: "category")
//            vc.isQA = true
//            self.navigationController?.pushViewController(vc, animated: true)
//            print("audio QA")
        }else if sender.tag == 1 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioVideoViewController") as! AudioVideoViewController
            UserDefaults.standard.set("Audio", forKey: "category")
            vc.isQA = true
            self.navigationController?.pushViewController(vc, animated: true)
            // print("audio QA")
        }else if sender.tag == 2 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioVideoViewController") as! AudioVideoViewController
            UserDefaults.standard.set("Audio", forKey: "category")
            vc.isQA = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else if sender.tag == 3 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            UserDefaults.standard.set("Music", forKey: "category")
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
//        else  if sender.tag == 4 {
//            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InterviewsViewController") as! InterviewsViewController
//            UserDefaults.standard.set("Interview", forKey: "category")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    //require method
    func downloadImages(_ url: String, _ index:Int) {
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage.init(named: "defaultImage"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: { (downloadImage, error, cacheType, url) in
            if let downloadImage = downloadImage {
                self.imageSlider.images[index] = downloadImage
            }
        })
    }
    
     func didSelectCarouselView(_ view: AACarousel, _ index: Int) {
        view.tag = index
        let mainDta = self.sliderImageArray[index]
        // print(mainDta,mainDta)
        let vc = storyboard?.instantiateViewController(withIdentifier: "SliderImagePopUpViewController") as! SliderImagePopUpViewController
        vc.imageUrl = mainDta
        vc.modalPresentationStyle = .fullScreen
        //vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func sliderImges(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_HOME_SLIDER)
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                //print("Slider Data",response)
                
                switch response.result {
                case .success:
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.sliderDataArray = (itemss.value(forKey: "respon") as! NSArray)
                    // print("sliderDataArray",self.sliderDataArray)
                    // print("sliderDataArraycount",self.sliderDataArray.count)
                    
                    for obj in  self.sliderDataArray {
                        if let name = (obj as AnyObject).value(forKey: "name") as? String {
                            //print(self.sliderImgesNameArray.count)
                        }
                        if let image = (obj as AnyObject).value(forKey: "file") as? String {
                           // print("Oshoimage",image)
                            if let qt = (obj as AnyObject).value(forKey: "quote") as? Int {
                                self.quote = qt
                            }
                            if self.quote == 1{
                                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,QUOTE,image)
                                self.sliderImageArray.append(imgeFile)
                                // print("sliderImageArray",self.sliderImageArray)
                            }else {
                                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,SLIDER,image)
                                self.sliderImageArray.append(imgeFile)
                            }
                        }
                        self.imageSlider.delegate = self
                        self.imageSlider.setCarouselData(paths: self.sliderImageArray,  describedTitle: [""], isAutoScroll: true, timer: 4.0, defaultImage: "defaultImage")
                        //optional method
                        self.imageSlider.setCarouselOpaque(layer: false, describedTitle: false, pageIndicator: false)
                        self.imageSlider.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
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
    
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        imageView.kf.setImage(with: URL(string: url[index]), placeholder: UIImage.init(named: "defaultImage"), options: [.transition(.fade(1))])
    }
    //Image slider
    func startAutoScroll() {
        imageSlider.startScrollImageView()
    }
    
    
    @IBAction func playNowButtonClick(_ sender: Any) {
        
//        if (AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) {
//
//            let controller = RadioStreamViewController.sharedInstance
//
//            self.present(controller, animated: true, completion: nil)
//
//        } else {
//        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "LanguagePopViewController") as! LanguagePopViewController
        //vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
       //play vc.isFromHome = true
        vc.langDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func languageSelect(_ album_Id: String, album_Name: String) {
        album_id = album_Id
        album_name = album_Name
        languageLabel.text = album_Name
        UserDefaults.standard.synchronize()
    }
    @IBAction func notificationsButtonClicked() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func playerDidStartPlaying() {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func playerViewClicked() {
//        let button = UIButton()
//        self.playNowButtonClick(button)
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func userInAppSubscriptionSaveUser(){
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_iOS_ADD_INAPP_SUBSCRIPTION)
        print("urlResponce",urlResponce)
        
        if  let  userId = GLOBAL_USER_ID {
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"userId":userId.stringValue,"materId": 1,"orderId": "","productId": "","purchaseState": "","developerPayload": "","purchaseToken": ""])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                        print("subscription_response",response)
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
    func showCountryStateUpdateAlert(){
        let alert = UIAlertController(title: "Ask Bhagwan",message: "Please update your state and country", preferredStyle: .alert)
        let update = UIAlertAction(title: "Update", style: .default) { (_) -> Void in
            // print("Yes")
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancle = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            // print("No")
        }
        alert.addAction(update)
        alert.addAction(cancle)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        SVProgressHUD.dismiss()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func saveUserDeviceToken(){
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_SAVE_DEVICE_TOKEN)
        print("urlResponce",urlResponce)
        
        if  let  userId = GLOBAL_USER_ID {
         if let deviceToken = UserDefaults.standard.value(forKey: "deviceToken") as? String ,let emailID = UserDefaults.standard.value(forKey: "email") as? String {
                userEmailId = emailID
                userDeviceToken = deviceToken
            }
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"id":userId.stringValue,"email": userEmailId,"device_token": userDeviceToken])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                        print("save device token_response",response)
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
    /// Tells the delegate an ad request loaded an ad.
   /* func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }*/
}
extension HomeViewController {
    func getAdMobSubscriptionStatus() {
        if let userId = GLOBAL_USER_ID {
            userID = userId.stringValue
        }
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ADMOB_SUBSCRIPTION_STATUS + userID! )
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    print("itemss",itemss)
                self.subscriptionStatus = itemss.value(forKey: "subscriptionStatus") as! Bool
                UserDefaults.standard.set(self.subscriptionStatus, forKey: "subscriptionStatus")
                UserDefaults.standard.synchronize()
                if self.subscriptionStatus == true  {
                    print("User subscribed ")
                }else {
                    self.showPreSubscriptionPopUp()
                    print(" User Not subscribe")
                }
        }
    }
}
extension HomeViewController: CollectionDelegate {
    func presentAlert() {
        let alert = UIAlertController(title: "You have not unlocked premium Q&A episodes",message: "You need to purchase for continueing to listen. Do you want to proceed?", preferredStyle: .alert)
        let addEvent = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
            // print("Yes")
            self.makePaymentMethod()
            //IAPServices.shared.makePaymentMethod()
        }
        let cancleEvent = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            // print("No")
        }
        
        alert.addAction(addEvent)
        alert.addAction(cancleEvent)
        self.present(alert, animated: true, completion:  nil)
    }
    
    
    func presentAudioViewController(trackType: Int,songIndex: Int,songArray: [[String : AnyObject]],isHome : Bool , isFromShowAdd: Bool , isFromQA: Bool) {
        SVProgressHUD.show()
//        if isFromShowAdd {
//            self.playingSongArray = songArray
//            self.playingID = songIndex
//            self.showAddForAudio()
//            return
//        }else {
        if let isFromDwonlod = UserDefaults.standard.value(forKey: "isFromDownloadPlay") {
            isfromDownload = isFromDwonlod as! Bool
        }
       // if isfromDownload {}else {
            MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            let controller = RadioStreamViewController.sharedInstance
//            if isFromQA && !isFromShowAdd {
//                controller.isFromQA = true
//            }else {
//               controller.isFromQA = false
//            }
            controller.trackType = trackType
            controller.recentTrackType = trackType
            controller.indexOfSong = songIndex
            controller.AllHomeAudioArray = songArray
            controller.isFromHome = isHome
            controller.isFromAudios = false
            controller.isFromPlayList = false
            controller.isFromRecentPlayList = false
            controller.isFromCommunity = false
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
       // }
    }
    
    
    func presentRecentAudioViewController(trackType: Int,songIndex: Int,songArray: [[String : AnyObject]],isRecentHome : Bool,isFromShowAdd: Bool , isFromQA : Bool) {
        SVProgressHUD.show()
//        if isFromShowAdd {
//            self.recentPlayingSongArray = songArray
//            self.recentPlayingID = songIndex
//            self.showAddForAudio()
//            return
//        }else {
        MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
        let controller = RadioStreamViewController.sharedInstance
//            if isFromQA && !isFromShowAdd {
//                controller.isFromQA = true
//            }else {
//                controller.isFromQA = false
//            }
        controller.trackType = trackType
        controller.indexOfSong = songIndex
        controller.AllHomeAudioArray = songArray
        controller.isFromHomeRecetPlay = isRecentHome
        controller.isFromAudios = false
        controller.isFromPlayList = false
        controller.isFromRecentPlayList = false
        controller.isFromCommunity = false
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
   // }
    }
    
    
    func presentVideoViewController(videoURL: URL,isHome : Bool) {
        let player = AVPlayer(url: videoURL)
         AudioPlayer.sharedAudioPlayer.pause()
         MiniPlayerView.sharedInstance.removeFromSuperview()
        playerController.player = player
        self.playerController.player!.play()
        present(playerController, animated: true)
    }
    
    func showAddForAudio(){
        DispatchQueue.main.async {
            //self.showVideosAdds()
        }
        UserDefaults.standard.set(false, forKey: "isVideo")
        UserDefaults.standard.set(true, forKey: "isAudio")
        UserDefaults.standard.set(true, forKey: "isAddClose")
        UserDefaults.standard.synchronize()
    }
}

extension HomeViewController : SKProductsRequestDelegate {
    func makePaymentMethod (){
        if (SKPaymentQueue.canMakePayments()) {
            let productID:NSSet = NSSet(array: [self.product_id! as NSString]);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            // SVProgressHUD.show()
            SVProgressHUD.show(withStatus: "Fetching Products")
            // print("Fetching Products");
        } else {
            // print("can't make purchases");
        }
    }
    func buyProduct(product: SKProduct) {
        //// print("Sending the Payment Request to Apple");
        SVProgressHUD.dismiss()
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // print(response.products)
        let count : Int = response.products.count
        if (count>0) {
            
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.product_id as! String) {
                // print(validProduct.localizedTitle)
                // print(validProduct.localizedDescription)
                // print(validProduct.price)
                self.buyProduct(product: validProduct)
            } else {
                // print(validProduct.productIdentifier)
            }
        } else {
            SVProgressHUD.dismiss()
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "No product availabel", timeout: time, completeText: "Done", style: .success)
            // print("nothing")
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    UserDefaults.standard.synchronize()
                    self.userInAppSubscriptionSaveUser()
                    self.homeTableView.reloadData()
                    //Do unlocking etc stuff here in case of new purchase
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .failed:
                    // print("Purchased Failed");
                    self.homeTableView.reloadData()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    UserDefaults.standard.synchronize()
                    self.homeTableView.reloadData()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                    break;
                }
            }
        }
    }
    
    
    //If an error occurs, the code will go to this function
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // Show some alert
}
    
}
//auat-erdn-spjd-zuhe
//Can't end BackgroundTask: no background task exists with identifier 4 (0x4), or it may have already been ended. Break in UIApplicationEndBackgroundTaskError() to debug.
