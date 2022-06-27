//
//  PlaylistDetailsViewController.swift
//  spotimusic
//
//  Created by Mac on 08/05/19.
//  Copyright © 2019 Appteve. All rights reserved.
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

class PlaylistDetailsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var playlistTableView: UITableView!
    var reachabilitysz: Reachability!
    var playlistId:String!
    var plalistTitle:String!
    var playlistArray = [[String : AnyObject]]()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistDetailsViewController.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "CommenTableViewCell", bundle: nil)
        self.playlistTableView.register(nib, forCellReuseIdentifier: "commonTableCell")
        self.title = plalistTitle
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllPlaylistData()
//        UserDefaults.standard.set(true, forKey: "isTrackInList")
//        UserDefaults.standard.synchronize()
        if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
            MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
        }else {
            MiniPlayerView.sharedInstance.cancelButtonClicked()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return playlistArray.count
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonTableCell", for: indexPath) as! CommenTableViewCell
        var mainData = NSDictionary()
        cell.unlockButton.isHidden = true
        cell.playingTrackGIFImageView.isHidden = true
        cell.downloadSongTagButton.isHidden = true
        cell.commonImageView.isHidden = false
        cell.downloadSongTagButton.isHidden = true
        cell.shareButton.isHidden = true
        
            cell.commonImageView.layer.cornerRadius = cell.commonImageView.frame.size.width/2
            cell.commonImageView.clipsToBounds = true
            cell.commonImageView.layer.borderWidth = 1.0
            mainData = self.playlistArray[indexPath.row] as NSDictionary
            
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playAudio), for:.touchUpInside)
        
            let imageUrl = mainData.value(forKey: "cover") as? String
            if imageUrl != "" {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                let name = mainData.value(forKey: "name") as? String
                DispatchQueue.main.async(execute: {
                    if let url = URL(string: imgeFile){
                        if let _ = cell.commonImageView {
                            cell.commonImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    }
                    cell.commonName.text = name
                })
            } else {
                cell.commonImageView.image = UIImage(named: "os_ho.jpg")
            }
        
            
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
        
        return cell
    }
    
    @objc func playAudio(sender : UIButton){
        if playlistArray.count == 0 {
        }  else {
            var songs: Array<Audio> = []
            for music in playlistArray {
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
            controller.isFromPlayList = true
            controller.isFromAudios = false
            controller.isFromQA = true
            controller.isFromHome = false
            controller.isFromCommunity = false
            controller.isFromRecentPlayList = false
            //controller.playList = playlistArray
            controller.indexOfSong = sender.tag
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
//            let mainData = self.audioArray[sender.tag] as NSDictionary
//            let name = mainData.value(forKey: "name") as? String
//            UserDefaults.standard.set(name, forKey: "audioFileName")
//            UserDefaults.standard.synchronize()
//
//            let imageUrl = mainData.value(forKey: "cover") as? String
//            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
//            UserDefaults.standard.synchronize()
//            SVProgressHUD.dismiss()
            playlistTableView.reloadData()
        }
        
    }
    func getAllPlaylistData(){
        let urlResponce = String(format: "%@%@%@",BASE_URL_BACKEND,ENDPOINT_TRAK_IN_PLIST, playlistId)
        print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success:
                    
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.playlistArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                    
                    
                    print("Discource_response",self.playlistArray)
//                    guard let itms = response.result.value else {return}
//                    let itemss = itms as! NSDictionary
//                    self.playlistArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
//                     print("Array_response",self.playlistArray)
//                    DispatchQueue.main.async() {
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
    @objc func playerDidStartPlaying() {
        
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
