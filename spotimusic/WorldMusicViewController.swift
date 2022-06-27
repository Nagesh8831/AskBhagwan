//
//  WorldMusicViewController.swift
//  spotimusic
//
//  Created by Mac on 08/09/21.
//  Copyright © 2021 Appteve. All rights reserved.
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
class WorldMusicViewController: BaseViewController {
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var musicTableView: UITableView!
    var albumId = 0

    var subscriptionStatus  = false

    var bhajanArray = [[String : AnyObject]]()

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
        title = "World Music"
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
         self.musicTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        getAllBhajans()
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
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
    @objc func callBack(){
          subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
              if subscriptionStatus == true {
                  print("User subscribed")
              }else {
                showAdds()
                //IronSource.showRewardedVideo(with: self)
              }
    }

    func
    getAllBhajans(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_BHAJAN_SEARCH)
        // print(urlResponce)
        var parameters = [String: Any]()
        //self.getHideShow(istableReload: false)
        parameters = [
            "searchterm" :"",
        ]
        parameters["X-API-KEY"] = API_GENERAL_KEY
        parameters["limit"] = 1000
        parameters["offset"] = 0
        parameters["album_id"] = albumId
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
                                self.bhajanArray.append(array[i])
                                self.musicTableView!.reloadData()
                            }
                        }
                        if self.bhajanArray.count == 0 {
                            self.noDataLabel.isHidden = true
                        } else {
                            self.noDataLabel.isHidden = false
                        }
                    }else {
                        //self.getHideShow(istableReload: true)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension WorldMusicViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bhajanArray.count
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
            let mainDta = self.bhajanArray[indexPath.row] as NSDictionary
            trackIds = mainDta.value(forKey: "id") as? String
            trackType = 6
        self.showAlertPickerView()
          }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    @objc func downloadTagButton(sender: UIButton) {
        Utilities.displayToastMessage("Song already downloaded...!!!")
    }
    @objc func playSong(sender : UIButton){
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
        }
    @objc func downloadSongs(sender: UIButton) {
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
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
    }
    @objc func shareButton(sender: UIButton) {
       /* let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        mainData = self.bhajanArray[sender.tag] as NSDictionary
        secondViewController.isShare = true
        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
        secondViewController.trackType = "8"
        self.present(secondViewController, animated: true, completion: nil)*/
        let shareOnViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareOnViewController") as! ShareOnViewController
            shareOnViewController.mainData = self.bhajanArray[sender.tag] as NSDictionary
        
        shareOnViewController.isFromAudio = false
        shareOnViewController.isFromJokes = false
        shareOnViewController.isFromWorldMusic = true
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
}
extension  WorldMusicViewController {
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
                    let mainDta = self.bhajanArray[index] as NSDictionary
                    let id = mainDta.value(forKey: "id") as? String
                    for item in downloadFiles {
                        let idd = item.value(forKey: "id") as? String
                        //downloaadJokesArray.append(idd as! String)
                        if idd == id {
                            isDownloaded = true
                        }
                    }


            }
        } catch {

            print("Fetch Failed")
        }
        return isDownloaded
    }
}
extension WorldMusicViewController: CZPickerViewDelegate, CZPickerViewDataSource {
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
