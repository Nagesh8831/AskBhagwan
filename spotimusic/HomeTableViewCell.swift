//
//  HomeTableViewCell.swift
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
import SVProgressHUD
import SCLAlertView
import AVKit
import AVFoundation
protocol CollectionDelegate: class {
    func presentAudioViewController(trackType: Int,songIndex: Int,songArray: [[String : AnyObject]],isHome : Bool , isFromShowAdd: Bool , isFromQA : Bool)
    func presentAlert()
    func showAddForAudio()
    func presentVideoViewController(videoURL: URL,isHome : Bool)
    func presentRecentAudioViewController(trackType: Int,songIndex: Int,songArray: [[String : AnyObject]],isRecentHome : Bool, isFromShowAdd: Bool , isFromQA : Bool)
}

class HomeTableViewCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var imageArray = [String] ()
    var audiofile = ""
    var playAudioButtonTag : Int?
    var playAudioButtonCollectionViewTag : Int?
    var playRecentAudioButtonTag : Int?
    var playRecentAudioButtonCollectionViewTag : Int?

    var allsongs = [[String : AnyObject]]()
    var audiosQA = [[String : AnyObject]]()
    var audiosDiscourse = [[String : AnyObject]]()
    var musics  = [[String : AnyObject]]()
    var interviews  = [[String : AnyObject]]()
    var recentPlayTracks  = [[String : AnyObject]]()
    
    var randomAudiosQA = [[String : AnyObject]]()
    var randomAudiosDiscourse = [[String : AnyObject]]()
    var randomMusics  = [[String : AnyObject]]()
    var randomInterviews  = [[String : AnyObject]]()
    var imageUrl : String?
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    var isPlay = false
    var isAudioDiscoursePlay = false
    var isMusicPlay = false
    var isInterViewPlay = false
    weak var delegate: CollectionDelegate?
    
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    
    var isPurchased : Bool?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewCell.playerDidStartPlaying), name: NSNotification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
     //   reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            self.checkUserLogin()
        } else {
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
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
                
            } else {
                if let idds = users[0].value(forKey: "user_id") {
                    GLOBAL_USER_ID = idds  as? NSNumber
                }
            }
        } catch {
            
            print("Fetch Failed")
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            return recentPlayTracks != nil ? recentPlayTracks.count : 0
        }else if collectionView.tag == 1 {
            return randomAudiosQA != nil ? randomAudiosQA.count : 0
        }else if collectionView.tag == 2 {
             return randomAudiosDiscourse != nil ? randomAudiosDiscourse.count : 0
        }else if collectionView.tag == 3 {
           return randomMusics != nil ? randomMusics.count : 0
        }
//        else if collectionView.tag == 4 {
//            return randomInterviews != nil ? randomInterviews.count : 0
//        }
        
        else{
          //  reachabilitysz = Reachability()
            do {
                reachabilitysz = try Reachability()
            }catch{
                
            }
            if (reachabilitysz?.isReachable)!{
                self.checkUserLogin()
            } else {
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath) as! HomeCollectionViewCell
        cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 7.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        switch (collectionView.tag){
        case 0 :
            if collectionView.tag == 0 {
                if recentPlayTracks.count != 0 {
                    let mainDta = self.recentPlayTracks[indexPath.row] as! NSDictionary
                    let name = mainDta.value(forKey: "file_name") as? String
                    cell.nameLabel.text = name
                    cell.lockButton.isHidden = true
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                    
                    let url = URL(string: imgeFile)
                    DispatchQueue.main.async(execute: {
                        cell.homeImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    })
                } else {
                    collectionView.isHidden = true
                    noDataLabel.isHidden = false
                }
                break
            }
            case 1 :
                if collectionView.tag == 1 {
                    let mainDta = self.randomAudiosQA[indexPath.row] as NSDictionary
                   // print("mainDta",mainDta)
                   // print(mainDta.count)
                    let name = mainDta.value(forKey: "name") as? String
                    audiofile = mainDta.value(forKey: "file") as! String
                    //print("audiofile",audiofile)
                    cell.nameLabel.text = name
                   // cell.playPauseImageView.isHidden = true
                    //cell.playPauseImageView.image = UIImage(named: "play-button-1")
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                   // print("imgeFile",imgeFile)
                    let url = URL(string: imgeFile)
                    
                    DispatchQueue.main.async(execute: {
                        if let _ = cell.homeImageView {
                            cell.homeImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    })
                    cell.lockButton.isHidden = true
                    /*if let pur  = UserDefaults.standard.value(forKey: "isPurchased") {
                        self.isPurchased = pur as! Bool
                        print("self.isPurchased1",self.isPurchased)
                    }
                    
                    if self.isPurchased == true{
                        cell.lockButton.isHidden = true
                        cell.playPauseImageView.isHidden = false
                        //collectionView.reloadData()
                    } else {
                        cell.lockButton.isHidden = false
                        cell.playPauseImageView.isHidden = true
                    }
                    
                    cell.lockButton.tag = indexPath.row
                    cell.lockButton.addTarget(self, action: #selector(subscription), for: .touchUpInside)*/
                    break
                }
            
            case 2 :
                
                if collectionView.tag == 2 {
                    let mainDta = self.randomAudiosDiscourse[indexPath.row] as! NSDictionary
                    let name = mainDta.value(forKey: "name") as? String
                    cell.nameLabel.text = name
                    cell.lockButton.isHidden = true
                        cell.playPauseImageView.image = UIImage(named: "play-button-1")
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                    
                    let url = URL(string: imgeFile)
                    
                    DispatchQueue.main.async(execute: {
                        cell.homeImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    })
                    break
                }
            
            case 3 :
                
                if collectionView.tag == 3 {
                    let mainDta = self.randomMusics[indexPath.row] as! NSDictionary
                    let name = mainDta.value(forKey: "name") as? String
                        cell.playPauseImageView.image = UIImage(named: "play-button-1")
                    cell.nameLabel.text = name
                    cell.lockButton.isHidden = true
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                    
                    let url = URL(string: imgeFile)
                    DispatchQueue.main.async(execute: {
                        if let _ = cell.homeImageView {
                            cell.homeImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    })
                    break
                }
             case 4 :
                if collectionView.tag == 4 {
                    if interviews.count != 0 {
                    let mainDta = self.interviews[indexPath.row] as! NSDictionary
                    let name = mainDta.value(forKey: "name") as? String
                    cell.nameLabel.text = name
                    cell.lockButton.isHidden = true
                    let imageUrl = mainDta.value(forKey: "cover") as? String
                    let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                    
                    let url = URL(string: imgeFile)
                    DispatchQueue.main.async(execute: {
                        cell.homeImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    })
                    } else {
                        collectionView.isHidden = true
                        noDataLabel.isHidden = false
                    }
                    break
                }
            default :
                break
            }
            return cell
    }
    
    func subscription(sender : UIButton){
        print("click subscription")
        delegate?.presentAlert()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath) as! HomeCollectionViewCell
        switch (collectionView.tag) {
        case 0 :
            
            if collectionView.tag == 0 {
                self.playRecentAudioButtonTag = indexPath.row
                self.playRecentAudioButtonCollectionViewTag = collectionView.tag
                UserDefaults.standard.set(false, forKey: "isVideo")
                UserDefaults.standard.set(true, forKey: "isAudio")
                UserDefaults.standard.set(true, forKey: "isRecntAudio")
                UserDefaults.standard.synchronize()
                UserDefaults.standard.set(false, forKey: "isAddClose")
                UserDefaults.standard.synchronize()
                if recentPlayTracks.count == 0 {
                }  else {
                    let mainDta1 = self.recentPlayTracks[indexPath.row] as! NSDictionary
                    if let file = mainDta1.value(forKey: "file") {
                        
                   let fileExtenton = file as? String
                        if (fileExtenton?.contains(".mp3"))!{
                         
                            var songs: Array<Audio> = []
                            
                            for music in recentPlayTracks {
                                let song = Audio(soundDictonary: music as! NSDictionary)
                                songs.append(song)
                            }
                            self.songs = songs
                            let count = self.songs.count
                            // let x = UInt32(count)
                            //let randomIdx = Int(arc4random_uniform(x)+0)
                            let randomIdx = indexPath.row
                            GLOBAL_CONTROLLER = "radio"
                            
                            if let track = self.playlist?.trackAtIndex(randomIdx) {
                                AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                                AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                                AudioPlayer.sharedAudioPlayer.play(track)
                            }
                            
                            let mainDta = self.recentPlayTracks[indexPath.row] as! NSDictionary
                            
                            let name = mainDta.value(forKey: "name") as? String
                            UserDefaults.standard.set(name, forKey: "audioFileName")
                            UserDefaults.standard.synchronize()
                            let imageUrl = mainDta.value(forKey: "cover") as? String
                            UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                            UserDefaults.standard.synchronize()
                            SVProgressHUD.dismiss()
                            delegate?.presentRecentAudioViewController(trackType: 0, songIndex: indexPath.row, songArray: recentPlayTracks as! [[String : AnyObject]], isRecentHome: true, isFromShowAdd: true, isFromQA: true)
                        } else if (fileExtenton?.contains("mp4"))! || (fileExtenton?.contains("mov"))! || (fileExtenton?.contains("m4v"))! {
                            
                            let mainDta = self.recentPlayTracks[indexPath.row] as NSDictionary
                            let videoUrl = mainDta.value(forKey: "file") as? String
                            guard let videourl = videoUrl else {return}
                            let urlwithPercentEscapes = videourl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                            let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!) 
                            let url =  URL(string: videoFile)
                            AudioPlayer.sharedAudioPlayer.pause()
                            delegate?.presentVideoViewController(videoURL: url!, isHome: true)
                        }
                    }
                }
            }
            
            break
            
            case 1 :
                //print("indexPath",indexPath.row)
                if collectionView.tag == 1 {
                    //if isPurchased == true{
                    self.playAudioButtonTag = indexPath.row
                    self.playAudioButtonCollectionViewTag = collectionView.tag
                    UserDefaults.standard.set(false, forKey: "isVideo")
                    UserDefaults.standard.set(true, forKey: "isAudio")
                    UserDefaults.standard.set(false, forKey: "isRecntAudio")
                    UserDefaults.standard.synchronize()

                        UserDefaults.standard.set(false, forKey: "isAddClose")
                        UserDefaults.standard.synchronize()
                        if audiosQA.count == 0 {
                        }  else {
                                var songs: Array<Audio> = []
                                for music in audiosQA {
                                    let song = Audio(soundDictonary: music as! NSDictionary)
                                    songs.append(song)
                                }
                                self.songs = songs
                                let count = self.songs.count
                                let x = UInt32(count)
                                let randomIdx = indexPath.row
                                // let randomIdx = Int(arc4random_uniform(x)+0)
                                GLOBAL_CONTROLLER = "radio"
                                if let track = self.playlist?.trackAtIndex(randomIdx) {
                                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                                    AudioPlayer.sharedAudioPlayer.play(track)
                                }
                                let mainDta = self.audiosQA[indexPath.row] as! NSDictionary
                                let name = mainDta.value(forKey: "name") as? String
                                UserDefaults.standard.set(name, forKey: "audioFileName")
                                UserDefaults.standard.synchronize()
                                let imageUrl = mainDta.value(forKey: "cover") as? String
                                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                                UserDefaults.standard.synchronize()
                                SVProgressHUD.dismiss()
                            delegate?.presentAudioViewController(trackType: 1,songIndex: indexPath.row, songArray: audiosQA, isHome: true , isFromShowAdd: true, isFromQA: true)
                                collectionView.reloadData()
                            }
//                    } else {
//                        delegate?.presentAlert()
//                       // print("lock")
//                    }
                }
                    break
            case 2 :
                        if collectionView.tag == 2 {
                            if audiosDiscourse.count == 0 {
                            }  else {
                                var songs: Array<Audio> = []
                                for music in audiosDiscourse {
                                let song = Audio(soundDictonary: music as! NSDictionary)
                                    songs.append(song)
                                }
                                self.songs = songs
                                let count = self.songs.count
                               // let x = UInt32(count)
                                let randomIdx = indexPath.row
                               // let randomIdx = Int(arc4random_uniform(x)+0)
                                
                                GLOBAL_CONTROLLER = "radio"
                                if let track = self.playlist?.trackAtIndex(randomIdx) {
                                    AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                                    AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                                    AudioPlayer.sharedAudioPlayer.play(track)
                                }
                                
                                let mainDta = self.audiosDiscourse[indexPath.row] as! NSDictionary
                                
                                let name = mainDta.value(forKey: "name") as? String
                                UserDefaults.standard.set(name, forKey: "audioFileName")
                                UserDefaults.standard.synchronize()
                                let imageUrl = mainDta.value(forKey: "cover") as? String
                                UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                                UserDefaults.standard.synchronize()
                                SVProgressHUD.dismiss()
                                delegate?.presentAudioViewController(trackType: 1, songIndex: indexPath.row, songArray: audiosDiscourse as! [[String : AnyObject]], isHome: true , isFromShowAdd: false, isFromQA: false)
                            }
                }
                    break
            case 3 :
                
                if collectionView.tag == 3 {
                    if musics.count == 0 {
                        
                    }  else {
                        var songs: Array<Audio> = []
                        for music in musics {
                            let song = Audio(soundDictonary: music as! NSDictionary)
                            songs.append(song)
                        }
                        self.songs = songs
                        let count = self.songs.count
                       // let x = UInt32(count)
                       // let randomIdx = Int(arc4random_uniform(x)+0)
                        let randomIdx = indexPath.row
                        GLOBAL_CONTROLLER = "radio"
                        
                        if let track = self.playlist?.trackAtIndex(randomIdx) {
                            AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                            AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                            AudioPlayer.sharedAudioPlayer.play(track)
                        }
                        
                        let mainDta = self.musics[indexPath.row] as! NSDictionary
                        let name = mainDta.value(forKey: "name") as? String
                        UserDefaults.standard.set(name, forKey: "audioFileName")
                        UserDefaults.standard.synchronize()
                        let imageUrl = mainDta.value(forKey: "cover") as? String
                        UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                        UserDefaults.standard.synchronize()
                        
                        SVProgressHUD.dismiss()
                        delegate?.presentAudioViewController(trackType: 3, songIndex: indexPath.row, songArray: musics as! [[String : AnyObject]], isHome: true, isFromShowAdd: false, isFromQA: false)
                    }
                }
                    break
            case 4 :
                
                if collectionView.tag == 4 {
                    
                    if interviews.count == 0 {
                        
                    }  else {
                        var songs: Array<Audio> = []
                        
                        for music in interviews {
                            let song = Audio(soundDictonary: music as! NSDictionary)
                            songs.append(song)
                        }
                        self.songs = songs
                        let count = self.songs.count
                       // let x = UInt32(count)
                        //let randomIdx = Int(arc4random_uniform(x)+0)
                        let randomIdx = indexPath.row
                        GLOBAL_CONTROLLER = "radio"
                        
                        if let track = self.playlist?.trackAtIndex(randomIdx) {
                            AudioPlayer.sharedAudioPlayer.playlist?.mode = .shuffle
                            AudioPlayer.sharedAudioPlayer.playlist = self.playlist
                            AudioPlayer.sharedAudioPlayer.play(track)
                        }
                        
                        let mainDta = self.interviews[indexPath.row] as! NSDictionary
                        
                        let name = mainDta.value(forKey: "name") as? String
                        UserDefaults.standard.set(name, forKey: "audioFileName")
                        UserDefaults.standard.synchronize()
                        let imageUrl = mainDta.value(forKey: "cover") as? String
                        UserDefaults.standard.set(imageUrl, forKey: "audioFileImage")
                        UserDefaults.standard.synchronize()
                        
                        SVProgressHUD.dismiss()
                        delegate?.presentAudioViewController(trackType: 4,songIndex: indexPath.row, songArray: interviews as! [[String : AnyObject]], isHome: true, isFromShowAdd: false, isFromQA: false)
                    }
                }
                
                    break
        default :
                    break
        }
    }
    
    @objc func playerDidStartPlaying() {
        
    }

    //Get AudiosQA
    func getAudioQA(completion: @escaping (_ result: Array<Any>)->Void) {
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES)
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        Alamofire.request( urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : "","quedisc":1,"album_id": 1,"should_orderby_name": true])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.audiosQA = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    let shuffel = self.audiosQA.shuffled()
                    let slice = self.audiosQA.count >= 10 ? 10 : self.audiosQA.count
                    let arraySlice = shuffel.prefix(upTo: slice)
                    self.randomAudiosQA = Array(arraySlice)
                completion(self.randomAudiosQA as! Array<Any>)
                    
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                    }
                }
            
        }
    }
    
    //Get AudiosDiacourse
    func getAudioDiscourse(completion: @escaping (_ result: Array<Any>)->Void){
        
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES)
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        Alamofire.request( urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : "","quedisc":2,"album_id": 1,"should_orderby_name": true])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.audiosDiscourse = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    let shuffel = self.audiosDiscourse.shuffled()
                    let slice = self.audiosDiscourse.count >= 10 ? 10 : self.audiosDiscourse.count
                    let arraySlice = shuffel.prefix(upTo: slice)
                    self.randomAudiosDiscourse = Array(arraySlice)
                    completion(self.randomAudiosDiscourse as! Array<Any>)
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                    }
                }
        }
    }
    
    
    //Get Music
    func getMusic(completion: @escaping (_ result: Array<Any>)->Void){
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_MUSIC_SEARCH)
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        Alamofire.request( urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : "","quedisc":2,"should_orderby_name": true])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.musics = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    let shuffel = self.musics.shuffled()
                    let slice = self.musics.count >= 10 ? 10 : self.musics.count
                    let arraySlice = shuffel.prefix(upTo: slice)
                    self.randomMusics = Array(arraySlice)
                    completion(self.randomMusics as! Array<Any>)
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                    }
                }
        }
    }
    //Get interviews
    func getInterviews(completion: @escaping (_ result: Array<Any>)->Void) {
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_INTERVIEW_SEARCH)
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        Alamofire.request( urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : "","album_id": 1,"should_orderby_name": true])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.interviews = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    
                    let shuffel = self.interviews.shuffled()
                    let slice = self.interviews.count >= 10 ? 10 : self.interviews.count
                    let arraySlice = shuffel.prefix(upTo: slice)
                    self.randomInterviews = Array(arraySlice)
                    
                    completion(self.randomInterviews as! Array<Any>)                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                    }
                }
        }
    }
    
    //get RecentPlayTracks
    
    func getRecentPlayTrack(completion: @escaping (_ result: Array<Any>)->Void){
        if  let  userId = GLOBAL_USER_ID {
            let idss = userId.stringValue
            let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_GET_RECENT_PLAY_TRACKS + idss + "&limit=10&offset=0" )
            SVProgressHUD.show()
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            Alamofire.request( urlRequest,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                        guard let itms = response.result.value else {return}
                        let itemss = itms as! NSDictionary
                        self.recentPlayTracks = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                        completion(self.recentPlayTracks as! Array<Any>)
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        DispatchQueue.main.async {
                        }
                    }
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
/*
 rm .DS_Store
 git add -A
 cd"*/
