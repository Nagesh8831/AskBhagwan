//
//  TrackInListTableViewController.swift
//  spotimusic
//
//  Created by appteve on 09/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

class TrackInListTableViewController: TableViewController,UISearchBarDelegate, SearchResultCellDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var privateBtn: UIButton!
    var playlistId:String!
    var plalistTitle:String!
    var isPrivate: String!
    var imageStr : String!
    var playListArray : NSArray!
    var loadMoreStatus = false
    var playButtonTag : Int?
    fileprivate let pageSize = 10
    var count = 0
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = plalistTitle
        countLabel.isHidden = true
        privateBtn.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.getData()
        UserDefaults.standard.set(true, forKey: "isTrackInList")
        UserDefaults.standard.synchronize()
//        if UserDefaults.standard.bool(forKey: "isAddClose") && UserDefaults.standard.bool(forKey: "isAudio") {
//            let videoButton = UIButton()
//            videoButton.tag =  playButtonTag! //saved id on play button click
//            self.playSong(sender: videoButton)
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func setPrivate(){
    }
    func setPrivatePl(_ privates:String){
    }
    func getData(){
        let urlReq = String(format: "%@%@%@",BASE_URL_BACKEND,ENDPOINT_TRAK_IN_PLIST, playlistId)
        Alamofire.request( urlReq,method: .get, parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                switch response.result {
                case .success :
                    guard let json = response.result.value else {return}
                    let JSON = json as! NSDictionary
                    let allsongs = JSON.value(forKey: "respon") as! NSArray
                    self.playListArray = JSON.value(forKey: "respon")  as! NSArray
                    print("playListArray",self.playListArray.count)
                    var songs: Array<Audio> = []
                    for music in allsongs {
                        let musicTrack = (music as! NSArray).object(at: 0) as! NSDictionary
                        let song = Audio(soundDictonary: musicTrack )
                        songs.append(song)
                        //print("musicTrack",musicTrack)
                    }
                    
                    self.songs = songs
                    if self.songs.count > 0 {
                        self.tableView.reloadData()
                        let songss = String(self.songs.count)
                        self.countLabel.text = String(format: "Total song: %@", songss)
                    } else {
                        let message = UILabel()
                        message.text = "No songs available"
                        message.translatesAutoresizingMaskIntoConstraints = false
                        message.textColor = UIColor.white
                        message.textAlignment = .center
                        self.view.addSubview(message)
                        message.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                        message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                        message.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
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


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((songs.count) < 1)  {
            if (count < 2){
                getData()
            }
            count += 1
            return 0
        } else {
            return songs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell2", for: indexPath) as! SearchResultCell
        cell.delegate = self
        let song = self.songs[indexPath.row]
        cell.titleLabel.text = song.title
        cell.play.tag = indexPath.row
        cell.play.addTarget(self, action: #selector(playSong), for:.touchUpInside)
        cell.download.tag = indexPath.row
        cell.download.addTarget(self, action: #selector(downlodSongs), for: .touchUpInside)
        cell.download.isHidden = true
       let imgStr = song.imageString
       let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imgStr!)
        DispatchQueue.main.async(execute: {
            if let url = URL(string: imgeFile){
                if let _ = cell.trackCover {
                    cell.trackCover.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
            }

        })
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    @objc func playSong(sender : UIButton){
//        UserDefaults.standard.set(true, forKey: "isAudio")
//        UserDefaults.standard.synchronize()
//        self.playButtonTag = sender.tag
//
//        if UserDefaults.standard.bool(forKey: "isAddClose") == true {
//            UserDefaults.standard.set(false, forKey: "isAddClose")
//            UserDefaults.standard.synchronize()
            // self.showVideosAdds()
            let count = self.songs.count
            //let x = UInt32(count)
            let randomIdx = Int(sender.tag)
            GLOBAL_CONTROLLER = "radio"
            if let track = self.playlist?.trackAtIndex(randomIdx) {
                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                AudioPlayer.sharedAudioPlayer.play(track)
            }
            let controller = RadioStreamViewController.sharedInstance
            controller.isFromPlayList = true
            controller.isFromAudios = false
            controller.isFromQA = true
            controller.isFromHome = false
            controller.isFromCommunity = false
            controller.isFromRecentPlayList = false
            controller.playList = playListArray
            controller.indexOfSong = sender.tag
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
//        }else {
//            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
//        }
       
    }
    func callBack(){
       // self.showVideosAdds()
    }
    @objc func downlodSongs(sender : UIButton){
        let button = sender as UIButton
        let index = button.tag
        var fileType = ""
        let mainDta = self.songs[index] as! NSDictionary
        print("mainDta",mainDta)
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
    
    func searchResultCell(_ searchResultCell: SearchResultCell!, downloadButtonPressed downloadButton: UIButton!) {
        if  RageProducts.store.isProductPurchased(RageProducts.unlockAll) {
        } else {
        }
    }
    
    func searchResultCell(_ searchResultCell: SearchResultCell!, stopButtonPressed stopButton: ProgressButton!) {
    }
    func playerDidStartPlaying() {
    }
}
