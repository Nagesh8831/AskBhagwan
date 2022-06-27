//
//  JokesViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 04/09/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
import CZPicker
class JokesViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,languageDelegate{

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var jokeTableView: UITableView!
    
    var subscriptionStatus  = false
    var items : NSArray!
    var trackIds: String!
    var jokesArray = [[String : AnyObject]]()
    var searchJokesArray = [[String : AnyObject]]()
    var searchText = ""
    var searchActive : Bool = false
    var categoty : String?
    var album_id : String?
    var album_name : String?
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var reachabilitysz: Reachability!
    var isFromMenu = false
    var downloadFiles = [NSManagedObject]()
    var refreshControl: UIRefreshControl!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(JokesViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        search.text = ""
        //search.searchTextField.textColor = .white
        if let textfield = search.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.jokeTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.jokeTableView.addSubview(self.refreshControl)
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//        reachabilitysz = Reachability()
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
    }

    @objc func pullToRefreshHandler() {
        self.jokeTableView.reloadData()
        self.refreshControl.endRefreshing()
        // refresh table view data here
    }
    override func viewWillAppear(_ animated: Bool) {
        search.text = ""
        self.selectedLanguage()
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        search.delegate = self
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        categoty = UserDefaults.standard.value(forKey: "category") as? String
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
            self.title = "Jokes"
        
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBar), name: NSNotification.Name(rawValue: "showProgressBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBarError), name: NSNotification.Name(rawValue: "showProgressBarError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
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
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func selectedLanguage(){
       search.text  = ""
            album_id = UserDefaults.standard.string(forKey: "defaultLanguageId")
            languageLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
            self.getAllJokes()
            self.searchAudio(searchText)
    }
    func getAllJokes(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_JOKES_SEARCH)
        print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":"","album_id": album_id!,"limit":10000,"offset":0])
            
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    print("Jokes_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.jokesArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.jokesArray.count > 0 {
                        DispatchQueue.main.async() {
                            self.jokeTableView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.jokeTableView!.isHidden = false
                        }
                    } else {
                        //self.view.bringSubview(toFront: self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No Jokes file found"
                        self.jokeTableView!.isHidden = true
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

    func searchAudio(_ searchText : String){
            SVProgressHUD.show()
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_JOKES_SEARCH)
            // print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":searchText,"album_id": album_id!,"limit":1000,"offset":0])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
        
                        // print("Dashboard_response",response)
                        guard let itms = response.result.value else {return}
                        let itemss = itms as! NSDictionary
                        self.searchJokesArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        if self.searchJokesArray.count > 0 {
                            // print("musicArray",self.searchMusicArray.count)
                            DispatchQueue.main.async() {
                                self.noDataLabel.isHidden = true
                                self.jokeTableView!.isHidden = false
                                self.jokeTableView!.reloadData()
                            }
                        } else {
                            //self.view.bringSubview(toFront: self.noDataLabel)
                            self.noDataLabel.isHidden = false
                            self.noDataLabel.text = "No Jokes file found"
                            self.jokeTableView!.isHidden = true
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
       
            if (searchActive) {
                return searchJokesArray.count
              }
                return jokesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        cell.commonImageView.isHidden = false
        cell.playingTrackGIFImageView.isHidden = true
        cell.unlockButton.isHidden = true
        cell.descriptionLabel.text = "Jokes"
        cell.commonImageView.layer.borderWidth = 1.0
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for: .touchUpInside)
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
        cell.downloadSongTagButton.tag = indexPath.row
        cell.downloadSongTagButton.addTarget(self, action: #selector(downloadTagButton), for: .touchUpInside)
        let isdownloaded = self.checkDownloadSongs(index: indexPath.row)
        
            if (searchActive) {
                let mainDta = self.searchJokesArray[indexPath.row] as NSDictionary
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
                //download song tag
                if isdownloaded {
                    cell.downloadButton.isHidden = true
                    cell.downloadSongTagButton.isHidden = false
                }else {
                    cell.downloadButton.isHidden = false
                    cell.downloadSongTagButton.isHidden = true
                }
                
            }else {
                let mainDta = self.jokesArray[indexPath.row] as NSDictionary
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
                //download song tag
                if isdownloaded {
                    cell.downloadButton.isHidden = true
                    cell.downloadSongTagButton.isHidden = false
                }else {
                    cell.downloadButton.isHidden = false
                    cell.downloadSongTagButton.isHidden = true
                }
                
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mainDta = self.searchJokesArray[indexPath.row] as NSDictionary
        trackIds = mainDta.value(forKey: "id") as? String
        self.showAlertPickerView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func playSong(sender : UIButton){
        if jokesArray.count == 0 {
            
        }  else {
            
            var songs: Array<Audio> = []
            
            for music in jokesArray {
                
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
            controller.trackType = 5
            controller.recentTrackType = 5
            controller.allAudioArray = jokesArray
            controller.indexOfSong = sender.tag
            controller.isFromAudios = true
            controller.isFromQA = false
            controller.isFromHome = false
            controller.isFromPlayList = false
            controller.isFromRecentPlayList = false
            controller.isFromCommunity = false
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
            let mainData = self.jokesArray[sender.tag] as NSDictionary
            let name = mainData.value(forKey: "name") as? String
            UserDefaults.standard.set(name, forKey: "audioFileName")
            UserDefaults.standard.synchronize()
            
            let imageUrl = mainData.value(forKey: "cover") as? String
            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
            UserDefaults.standard.synchronize()
            SVProgressHUD.dismiss()
            
            jokeTableView.reloadData()
            
        }
    }
    
    @objc func playerDidStartPlaying() {
        
    }
    
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""

            let mainDta = self.jokesArray[index] as NSDictionary
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
    
    @objc func downloadTagButton(sender: UIButton) {
        Utilities.displayToastMessage("Song already downloaded...!!!")
    }
    @objc func shareButton(sender: UIButton) {
//        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        let shareOnViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareOnViewController") as! ShareOnViewController
        var mainData = NSDictionary()
        if (searchActive){
            mainData = self.searchJokesArray[sender.tag] as NSDictionary
            shareOnViewController.mainData = self.searchJokesArray[sender.tag] as NSDictionary
        } else {
            mainData = self.jokesArray[sender.tag] as NSDictionary
            shareOnViewController.mainData = self.jokesArray[sender.tag] as NSDictionary
        }
//        secondViewController.isShare = true
//        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
//        secondViewController.trackType = "7"
//        self.present(secondViewController, animated: true, completion: nil)
        
        shareOnViewController.isFromAudio = false
        shareOnViewController.isFromJokes = true
        shareOnViewController.isFromWorldMusic = false
        shareOnViewController.modalTransitionStyle = .crossDissolve
        shareOnViewController.modalPresentationStyle = .overCurrentContext
        self.present(shareOnViewController, animated: true, completion: nil)
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
        Alamofire.request(urlRequest,method: .post, parameters: ["playlist_id": playlistId,"track_id":trackId,"track_type":5,"X-API-KEY":API_GENERAL_KEY])
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
    @IBAction func languageButtonAction(_ sender: Any) {
    }
    func languageSelect(_ album_Id: String, album_Name: String) {
        search.text = ""
        searchActive = false
        search.resignFirstResponder()
        album_id = album_Id
        album_name = album_Name
        languageLabel.text = album_Name
        self.getAllJokes()
        self.searchAudio(searchText)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "lang_to_joke"{
            let vc = segue.destination as! LanguagePopViewController
            vc.langDelegate = self
            search.resignFirstResponder()
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
                
                if (searchActive) {
                    let mainDta = self.searchJokesArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        if idd == id {
                            isDownloaded = true
                        }
                    }
                }else{
                    let mainDta = self.jokesArray[index] as NSDictionary
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension JokesViewController : UISearchBarDelegate, UITextFieldDelegate{
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
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()       }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.searchAudio(searchText)
        self.getAllJokes()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension JokesViewController            : CZPickerViewDelegate, CZPickerViewDataSource {
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




