//
//  VideoPlayViewController.swift
//  spotimusic
//
//  Created by Mac on 06/08/18.
//

import UIKit
import AVKit
import AVFoundation
import IOSurface
class VideoPlayViewController: UIViewController, AVPlayerViewControllerDelegate {
    var videoUrl : URL?
    var name : String?
    var videoURLStr = ""
    var trackId = ""
    var playerController = AVPlayerViewController()
    var player:AVPlayer!
    let kAPPKEY = "a4fd26cd"
    @IBOutlet weak var videoView: UIView!
    var backButton : UIBarButtonItem!
    var shouldAnimate = false
    var isAdClosed = false
    var subscriptionStatus  = false
    var isFromDownloadedSong = false
    var songURL = ""
    var songImageURL = ""
    var imagName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
            self.navigationItem.leftBarButtonItem = backButton
        setupIronSourceSdk()
    }
   @objc func goBack() {
    playerController.player?.pause()
    self.navigationController?.popViewController(animated: true)
    }
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            playerController.player?.pause()
            print("back button was pressed ")
            // The back button was pressed or interactive gesture used
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        if isAdClosed {
            print("added",isAdClosed)
            playerController.player?.pause()
        }else{
        playVideo1()
    }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "videoBounds", let rect = change?[.newKey] as? NSValue {
            let playerRect: CGRect = rect.cgRectValue
            if playerRect.size.height <= 200 {
                print("Video not in full screen")
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                //isFullscreen = false
            } else {
                print("Video in full screen")
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
               // isFullscreen = true
            }
        }
    }
    @objc func callBack(){
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            //IronSource.showRewardedVideo(with: self)
        IronSource.showRewardedVideo(with: self)
            playerController.player?.pause()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVideo() {
                //let controller = AVPlayerViewController()
               // controller.player = self.videoView.player
                let window = UIApplication.shared.windows[0]
        if #available(iOS 11.0, *) {
            let bottomPadding = window.safeAreaInsets.bottom
            playerController.view.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.y, width: self.videoView.frame.width - bottomPadding, height: self.videoView.frame.height)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            let leftPadding = window.safeAreaInsets.left
        } else {
            // Fallback on earlier versions
        }
        playerController.showsPlaybackControls = true
        playerController.addObserver(self, forKeyPath: "videoBounds", options: NSKeyValueObservingOptions.new, context: nil)
                self.addChild(playerController)
                self.videoView.addSubview(playerController.view)
        playerController.didMove(toParent:self)
                self.videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.videoView.frame = self.view.bounds
        let urlwithPercentEscapes = videoURLStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!)
        let url =  URL(string: videoFile)
        let player = AVPlayer(url: url!)
        playerController.showsPlaybackControls = true
        videoView.addSubview(playerController.view)
        playerController.player = player
        //sender.isEnabled = false
        AudioPlayer.sharedAudioPlayer.pause()

        //present(playerController, animated: true) {
            self.playerController.player!.play()
            MiniPlayerView.sharedInstance.removeFromSuperview()
            UIView.animate(withDuration: 1, animations: {
                //sender.isEnabled = true
            })
    }


    func playVideo1() {
        if isFromDownloadedSong {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
          let url = NSURL(fileURLWithPath: path)
          let oldPath = songURL.prefix(86)
          print("oldPath",oldPath)
          let updateFile = UserDefaults.standard.value(forKey: "basePath") as! String
       let file_url =  songURL.replacingOccurrences(of: oldPath, with: updateFile)
          print(file_url)
         // dirPath /var/mobile/Containers/Data/Application/CCC4AAF3-5593-4433-B320-5126500501CB/Documents
          let pathArray = songURL.components(separatedBy: "/")
          var strPath = "music/"
          strPath.append((pathArray.last ?? nil)!)
          if let pathComponent = url.appendingPathComponent(strPath) {
              let filePath = pathComponent.path
              let fileManager = FileManager.default
              if fileManager.fileExists(atPath: filePath) {
                  print("FILE AVAILABLE")
              } else {
                  print("FILE NOT AVAILABLE")
              }
          } else {
              print("FILE PATH NOT AVAILABLE")
          }
          let destURL = URL.init(fileURLWithPath: file_url)
          _ = AVURLAsset(url: destURL).duration.seconds
           let destURL1 = URL.init(fileURLWithPath: songImageURL)
          print("destURL1",destURL1)
             // print(sender.tag)
              print("file path of bundle songs =",file_url)
               player = AVPlayer(url: URL(fileURLWithPath: file_url))
          if file_url.contains(".mp4") || file_url.contains(".m4v") {
              playerController.contentOverlayView?.isHidden = true
          }else {
              let playerCoverImageView = UIImageView.init(image: UIImage.init(named: "os_ho.jpg"))
              playerCoverImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)

              playerCoverImageView.center = self.view.center
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imagName)
              let url = URL(string: imgeFile)
             // DispatchQueue.main.async(execute: {
            playerCoverImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
             // })
              playerController.contentOverlayView?.isHidden = false
              playerController.contentOverlayView?.addSubview(playerCoverImageView)
          }
            let urlwithPercentEscapes = videoURLStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!)
            //let url =  URL(string: videoFile)
           // player = AVPlayer(url: url!)
            playerController.showsPlaybackControls = true
            videoView.addSubview(playerController.view)
            playerController.player = player
            //sender.isEnabled = false
            AudioPlayer.sharedAudioPlayer.pause()

            //present(playerController, animated: true) {
                self.playerController.player!.play()
                MiniPlayerView.sharedInstance.removeFromSuperview()
                UIView.animate(withDuration: 1, animations: {
                    //sender.isEnabled = true
                })
          //sender.isEnabled = false
//          playerController.player = player
//          AudioPlayer.sharedAudioPlayer.pause()
//         // sender.isEnabled = false
//          present(playerController, animated: true) {
//              self.playerController.player!.play()
//              MiniPlayerView.sharedInstance.removeFromSuperview()
//              UIView.animate(withDuration: 1, animations: {
//                  sender.isEnabled = true
//              })
//          }
        }else {
                let controller = AVPlayerViewController()
              //  controller.player = self.videoView.player
                let window = UIApplication.shared.windows[0]
        if #available(iOS 11.0, *) {
            let bottomPadding = window.safeAreaInsets.bottom
            controller.view.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.y, width: self.videoView.frame.width - bottomPadding, height: self.videoView.frame.height)
        } else {
            // Fallback on earlier versions
        }
        /*if #available(iOS 11.0, *) {
            let leftPadding = window.safeAreaInsets.left
            if leftPadding > 0.0 {
                self.backButtonWidthConstraint.constant = 40
                self.backButtonHeightConstraint.constant = 40
                self.backButton.layer.cornerRadius = 20
                self.shouldAnimate = false
            } else {
                self.backButtonWidthConstraint.constant = 60
                self.backButtonHeightConstraint.constant = 60
                self.backButton.layer.cornerRadius = 30
                self.shouldAnimate = true
                UIView.animateKeyframes(withDuration: 0.33, delay: 3, options: .beginFromCurrentState) {
                    self.backButton.alpha = 0
                } completion: { (_) in }
            }
        } else {
            // Fallback on earlier versions
        }*/
                controller.showsPlaybackControls = true
                controller.addObserver(self, forKeyPath: "videoBounds", options: NSKeyValueObservingOptions.new, context: nil)
                self.addChild(controller)
                self.videoView.addSubview(controller.view)
                controller.didMove(toParent:self)
                self.videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.videoView.frame = self.view.bounds
        //controller
                //self.indexOfVideo += 1
        let urlwithPercentEscapes = videoURLStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let videoFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PLAYVIDEO,urlwithPercentEscapes!)
        let url =  URL(string: videoFile)
        player = AVPlayer(url: url!)
            self.addChild(playerController)
           // self.view.addSubview(playerController.view)
            playerController.view.frame = self.view.frame
        playerController.showsPlaybackControls = true
        videoView.addSubview(playerController.view)
        playerController.player = player
        //sender.isEnabled = false
        AudioPlayer.sharedAudioPlayer.pause()

        //present(playerController, animated: true) {
            self.playerController.player!.play()
            MiniPlayerView.sharedInstance.removeFromSuperview()
            UIView.animate(withDuration: 1, animations: {
                //sender.isEnabled = true
            })
        }
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
extension VideoPlayViewController : ISRewardedVideoDelegate {
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
        player.pause()
    }

    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print("Rv Failed to show")
       // player.pause()
        //player.play()
        //Utilities.displayToastMessage("ads not present")
        //AudioPlayer.sharedAudioPlayer.resume()
        //IronSource.showRewardedVideo(with: self)
    }

    func rewardedVideoDidOpen() {
        self.isAdClosed = true
        print("RV Open",isAdClosed)
        IronSource.showRewardedVideo(with: self)
        AudioPlayer.sharedAudioPlayer.pause()
        player.pause()
    }

    func rewardedVideoDidClose() {
        print("RV Close",isAdClosed)
        self.isAdClosed = true
        AudioPlayer.sharedAudioPlayer.pause()
        player.pause()
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                self.player.pause()
                self.playerController.player?.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubsciptionPlanViewController") as! SubsciptionPlanViewController
                vc.isFromMusicPlayer = false
                self.navigationController?.pushViewController(vc, animated: true)
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
               // self.player.play()
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
        self.isAdClosed = true
        print("RV Start",isAdClosed)
        player.pause()
    }

    func rewardedVideoDidEnd() {
        self.isAdClosed = true
        print("RV End",isAdClosed)
    }

    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        self.isAdClosed = true
        print("RV clicked",isAdClosed)
        player.pause()
    }
}
