//
//  CommonMMIViewController.swift
//  spotimusic
//
//  Created by Mac on 19/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import  SVProgressHUD
import SCLAlertView
class CommonMMIViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var commonTableView: UITableView!
    @IBOutlet weak var menuItem: UIBarButtonItem!
    @IBOutlet weak var noDataLabel: UILabel!
    
    
    var musicArray = [[String : AnyObject]]()
    var interviewsArray = [[String : AnyObject]]()
    var searchMusicArray = [[String : AnyObject]]()
    var searchText = ""
    var searchInterviewsArray = [[String : AnyObject]]()
    var searchActive : Bool = false
    var categoty : String?
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    var reachabilitysz: Reachability!
    var refreshControl: UIRefreshControl!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommonMMIViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.commonTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        self.refreshControl = UIRefreshControl()
       // searchBar.searchTextField.textColor = .white
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.commonTableView.addSubview(self.refreshControl)
        menuItem.target = self.revealViewController()
        menuItem.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
//            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
//            }
//            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
//            
//            SCLAlertView().showTitle("Internet not available" , subTitle: "Please try after sometime...", timeout: time, completeText: "Done", style:  .success)
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
        //self.getAllCommunityByUserId()
        self.commonTableView.reloadData()
        self.refreshControl.endRefreshing()
        // refresh table view data here
    }
    override func viewWillAppear(_ animated: Bool) {
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
       if categoty == "Music" {
         self.title = "Music"
           self.getAllMusic()
        self.searchAudio(searchText)
        }else  if categoty == "Interview"{
            self.title = "Interviews"
            self.getAllInterviews()
            self.searchAudio(searchText)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBar), name: NSNotification.Name(rawValue: "showProgressBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressBarError), name: NSNotification.Name(rawValue: "showProgressBarError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    @objc  func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @objc func showProgressBar() {
//        DispatchQueue.main.async {
//            if self.progressView?.superview == nil {
//                self.progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
//                self.progressView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1)
//                self.progressView?.setProgress(1, animated: true)
//                //            progressView?.progressTintColor = .green
//                //            progressView?.trackTintColor = .white
//                let window = UIApplication.shared.keyWindow
//                window?.addSubview(self.progressView!)
//            }
//            let pValue = Float(UserDefaults.standard.double(forKey: "showProgressBar"))
//            self.progressView?.progress = pValue
//            if pValue >= 100 {
//                self.progressView?.removeFromSuperview()
//            }
//            UserDefaults.standard.set(0.0, forKey: "showProgressBar")
//            UserDefaults.standard.synchronize()
//        }
    }
    @objc func showProgressBarError() {
//        DispatchQueue.main.async {
//            if self.progressView?.superview != nil {
//                self.progressView?.removeFromSuperview()
//            }
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //all music
    func getAllMusic(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_MUSIC_SEARCH)
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"limit":500,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print("Music_response",response)
                guard let itms = response.result.value else {return}
                let itemss = itms as! NSDictionary
                self.musicArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                if self.musicArray.count > 0 {
                    DispatchQueue.main.async() {
                        self.commonTableView!.reloadData()
                        self.noDataLabel.isHidden = true
                         self.commonTableView!.isHidden = false
                    }
                } else {
                    self.view.bringSubviewToFront(self.noDataLabel)
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No Music file found"
                    self.commonTableView!.isHidden = true
                }
        }
    }
    
    //all interviews
    func getAllInterviews(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_INTERVIEW_SEARCH)
       // print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"limit":500,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print("Interview_response",response)
                guard let itms = response.result.value else {return}
                let itemss = itms as! NSDictionary
                self.interviewsArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                
                //print("interviewsArray",self.interviewsArray.count)
                if self.interviewsArray.count > 0 {
                    DispatchQueue.main.async() {
                        self.commonTableView!.reloadData()
                        self.noDataLabel.isHidden = true
                         self.commonTableView!.isHidden = false
                    }
                } else {
                    self.view.bringSubviewToFront(self.noDataLabel)
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No Interviews file found"
                    self.commonTableView!.isHidden = true
                }
//                DispatchQueue.main.async() {
//                    self.commonTableView!.reloadData()
//                }
        }
    }
    
    
    func searchAudio(_ searchText : String){
        if categoty == "Music" {
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_MUSIC_SEARCH)
       // print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":searchText,"limit":500,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
               // print("Dashboard_response",response)
                guard let itms = response.result.value else {return}
                let itemss = itms as! NSDictionary
                self.searchMusicArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                 if self.searchMusicArray.count > 0 {
               // print("musicArray",self.searchMusicArray.count)
                DispatchQueue.main.async() {
                    self.commonTableView!.reloadData()
                    self.noDataLabel.isHidden = true
                    self.commonTableView!.isHidden = false
                }
                 } else {
                    self.view.bringSubviewToFront(self.noDataLabel)
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No Music file found"
                    self.commonTableView!.isHidden = true
                }
        }
        }else  if categoty == "Interview"{
            SVProgressHUD.show()
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_INTERVIEW_SEARCH)
            //print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":searchText,"limit":500,"offset":0])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                   // print("Dashboard_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.searchInterviewsArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.searchInterviewsArray.count > 0 {
                   // print("interviewsArray",self.searchInterviewsArray.count)
                    DispatchQueue.main.async() {
                        self.commonTableView!.reloadData()
                        self.noDataLabel.isHidden = true
                         self.commonTableView!.isHidden = false
                        }
                    } else {
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No Interview file found"
                        self.commonTableView!.isHidden = true
                    }
            }
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if categoty == "Music" {
            if (searchActive) {
                 return searchMusicArray.count
            }
             return musicArray.count
        }else  if categoty == "Interview"{
            if (searchActive) {
                return searchInterviewsArray.count
            }
            return interviewsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
        cell.commonImageView.clipsToBounds = true
        //cell.commonImageView.layer.borderColor = UIColor.gray.cgColor
        cell.commonImageView.layer.borderWidth = 1.0
//        cell.shareButton.isHidden = true
//         cell.shareButtonWidthConstarint.constant = 0
        cell.unlockButton.isHidden = true
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playSong), for:.touchUpInside)
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for:.touchUpInside)
        if categoty == "Music" {
             if (searchActive) {
            let mainDta = self.searchMusicArray[indexPath.row] as NSDictionary
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
                
             }else {
                let mainDta = self.musicArray[indexPath.row] as NSDictionary
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
                
            }
            
        } else if categoty == "Interview" {
            if (searchActive) {
            let mainDta = self.searchInterviewsArray[indexPath.row] as NSDictionary
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
            }else {
                let mainDta = self.interviewsArray[indexPath.row] as NSDictionary
                let name = mainDta.value(forKey: "name") as? String
                
                let imageUrl = mainDta.value(forKey: "cover") as? String
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                cell.downloadButton.tag = indexPath.row
                cell.downloadButton.addTarget(self, action: #selector(downloadSongs), for:.touchUpInside)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = cell.commonImageView {
                        cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                    cell.commonName.text = name
                })
            }
            
        }
        cell.downloadButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func playSong(sender : UIButton){
                if categoty == "Music"{
            let selectedRadio = musicArray[sender.tag]
            // print(sender.tag)
            let song = Audio(soundDictonary: selectedRadio as NSDictionary)
            self.songs = [song]
            let count = self.songs.count
            let x = UInt32(count)
            let randomIdx = Int(arc4random_uniform(x)+0)
            GLOBAL_CONTROLLER = "radio"
            if let track = self.playlist?.trackAtIndex(randomIdx) {
                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                AudioPlayer.sharedAudioPlayer.play(track)
            }
                    let mainDta = self.musicArray[sender.tag] as NSDictionary
                    
                    let name = mainDta.value(forKey: "name") as? String
                    UserDefaults.standard.set(name, forKey: "audioFileName")
                    UserDefaults.standard.synchronize()
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                    UserDefaults.standard.synchronize()
            let controller = RadioStreamViewController.sharedInstance
                     controller.trackType = 3
                    controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
                } else if categoty == "Interview" {
                    let selectedRadio = interviewsArray[sender.tag]
                    // print(sender.tag)
                    let song = Audio(soundDictonary: selectedRadio as NSDictionary)
                    self.songs = [song]
                    let count = self.songs.count
                    let x = UInt32(count)
                    let randomIdx = Int(arc4random_uniform(x)+0)
                    GLOBAL_CONTROLLER = "radio"
                    if let track = self.playlist?.trackAtIndex(randomIdx) {
                        AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                        AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                        AudioPlayer.sharedAudioPlayer.play(track)
                    }
                    let mainDta = self.interviewsArray[sender.tag] as NSDictionary
                    
                    let name = mainDta.value(forKey: "name") as? String
                    UserDefaults.standard.set(name, forKey: "audioFileName")
                    UserDefaults.standard.synchronize()
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                    UserDefaults.standard.synchronize()
                    let controller = RadioStreamViewController.sharedInstance
                     controller.trackType = 4
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func playerDidStartPlaying() {
        
    }
    
    @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        if categoty == "Music" {
            mainData = self.musicArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "3"
            self.present(secondViewController, animated: true, completion: nil)

        } else {
            mainData = self.interviewsArray[sender.tag] as NSDictionary
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "4"
            self.present(secondViewController, animated: true, completion: nil)
            
            }
        }
    @objc func downloadSongs(sender: UIButton) {
        if categoty == "Music" {
            let selectMeditaionType = musicArray[sender.tag]
            
            let button = sender as UIButton
            let index = button.tag
            var fileType = ""
            let mainDta = self.musicArray[index] as NSDictionary
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
            let selectMeditaionType = interviewsArray[sender.tag]
            
            let button = sender as UIButton
            let index = button.tag
            var fileType = ""
            let mainDta = self.interviewsArray[index] as NSDictionary
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
    }
    
   
}
extension CommonMMIViewController : UISearchBarDelegate {
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
        self.searchText = searchText
        if categoty == "Music" {
            self.searchAudio(searchText)
             self.getAllMusic()
        }else if categoty == "Interview"{
            self.searchAudio(searchText)
            self.getAllInterviews()
        }
    }
}

