  

import UIKit
import AVFoundation
import MediaPlayer

let AudioPlayerDidStartPlayingNotification = "AudioPlayerDidStartPlayingNotification"

class AudioPlayer: NSObject, STKAudioPlayerDelegate, RadioStreamViewControllerDelegate {
    
    static let sharedAudioPlayer = AudioPlayer()
    let theSession = AVAudioSession.sharedInstance()
    
    var _stk_audioPlayer: STKAudioPlayer
    
    var currentlyPlayingURL: URL?
    var currentTrack: Audio? {
        didSet {
            RadioStreamViewController.sharedInstance.updateTackInfo()
        }
    }
    var playlist: Playlist?

    override init() {
        self._stk_audioPlayer = STKAudioPlayer(options: STKAudioPlayerOptions(
            flushQueueOnSeek: true,
            enableVolumeMixer: false,
            equalizerBandFrequencies: (50, 100, 200, 400, 800, 1600, 2600, 16000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            readBufferSize: 0,
            bufferSizeInSeconds: 0,
            secondsRequiredToStartPlaying: 0.0,
            gracePeriodAfterSeekInSeconds: 0.0,
            secondsRequiredToStartPlayingAfterBufferUnderun: 0.0)
        )
        super.init()
                // Init audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let error as NSError {
            NSLog("\(error)")
        }

        // Playback controls
        UIApplication.shared.beginReceivingRemoteControlEvents()        
        
        self._stk_audioPlayer.delegate = self
        RadioStreamViewController.sharedInstance.delegate = self

        // Register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayer.routeDidChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayer.handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: theSession)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    
    
    // MARK: - Public methods
    
    func play (_ audio: Audio, force: Bool = false) {
        if let URL = audio.fileURL {
            playAudio(fromURL: URL as URL, force: force)
        } else if let URL = audio.remoteURL {
            playAudio(fromURL: URL as URL, force: force)
        }
        self.currentTrack = audio        
    }
    
    
//    func play (_ audio: Audio, force: Bool = false) {
//        let urls = "http://avapplicationstaging.s3.amazonaws.com/audios/track/1532065619Bhula_Diya_Tujh_ko_Sunny_Leone_New_video_Song_2018.mp3"
//        let url = URL.init(fileURLWithPath: urls)
//        //if let URL = audio.fileURL {
//        playAudio(fromURL: url, force: force)
//        //        } else if let URL = audio.remoteURL {
//        //            playAudio(fromURL: URL as URL, force: force)
//        //        }
//        self.currentTrack = audio
//    }
    func pause() {
        self._stk_audioPlayer.pause()
        RadioStreamViewController.sharedInstance.configureControlButtons()
    }
    func stop(){
        self._stk_audioPlayer.stop()
        RadioStreamViewController.sharedInstance.configureControlButtons()
    }
    func resume() {
        self._stk_audioPlayer.resume()
        RadioStreamViewController.sharedInstance.configureControlButtons()
    }
    
    func togglePlayPause() {
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
        case
            STKAudioPlayerState(),
            STKAudioPlayerState.stopped,
            STKAudioPlayerState.error,
//            STKAudioPlayerState.disposed:
//            self.resume()
            STKAudioPlayerState.paused:
            AudioPlayer.sharedAudioPlayer.resume()
        case
            STKAudioPlayerState(),
            STKAudioPlayerState.paused:
           // self.pause()
            AudioPlayer.sharedAudioPlayer.pause()
        default: break
        }
    }
    
    
    
    func previousTrack (_ userAction: Bool = false) {
        // if more than 4 sec played, replay current track
        
        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else {
            
            return
        }
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            if count - 1 != index {
                if self._stk_audioPlayer.progress < 4 {
                    if let audio = self.playlist!.previousTrack() {
                        self.play(audio)
                    } else {
                        self._stk_audioPlayer.resume()
                    }
                } else {
                    self._stk_audioPlayer.seek(toTime: 0)
                }
            } else {
                if self._stk_audioPlayer.progress < 4 {
                    if let audio = self.playlist!.previousTrack() {
                        self.play(audio)
                    } else {
                        self._stk_audioPlayer.resume()
                    }
                } else {
                    self._stk_audioPlayer.seek(toTime: 0)
                }
            }
        }
        
        
    }
    
    func nextTrack (_ userAction: Bool = false) {
        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else {
            
            return
        }
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            if count - 1 != index {
        if let audio = self.playlist!.nextTrack() {
            self.play(audio)
        } else {
           
            //self.play(Audio)
           self._stk_audioPlayer.resume()
        }
            } else {
//                if let audio = self.playlist!.previousTrack() {
//                    self.play(audio)
//                }
            }
        }
    }
    
    func updatePlayingInfo () {
        
//        let songInfo = NSMutableDictionary()
//        
//        if let title = self.currentTrack?.title {
//            songInfo.setObject(title, forKey: MPMediaItemPropertyTitle as NSCopying)
//        }
//        
//        if let artist = self.currentTrack?.artist {
//            songInfo.setObject(artist, forKey: MPMediaItemPropertyArtist as NSCopying)
//        }
//        
//        
//       let find = AppleFind()
//        
//        find.getResponseImageBig((self.currentTrack?.artist)!) {(isResponse) -> Void in
//            
//            let URL = Foundation.URL(string: isResponse)!
//           // let cache = Shared.imageCache
//           // let fetcher = NetworkFetcher<UIImage>(URL: URL)
//           // cache.fetch(fetcher: fetcher).onSuccess { image in
//                // Do something with image
//              //  songInfo.setObject(MPMediaItemArtwork(image: image), forKey: MPMediaItemPropertyArtwork)
//             //   MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo.copy() as? [String: AnyObject]
//          //  }
//        }
    }
    
    // MARK: - Private methods
    
    fileprivate func playAudio (fromURL URL: URL, force: Bool = false) {
        if (URL != self.currentlyPlayingURL || force == true) {
            
            self._stk_audioPlayer.play(URL)
            self.currentlyPlayingURL = URL
        }
        if (URL == self.currentlyPlayingURL && self._stk_audioPlayer.state == .paused) {
            self.resume()
        }
        if (self._stk_audioPlayer.state == .stopped) {
            self._stk_audioPlayer.seek(toTime: 0)
            self.resume()
        }
    }
    
    // MARK: - STKAudioPlayerDelegate
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        self.updatePlayingInfo()

        NotificationCenter.default.post(name: Notification.Name(rawValue: AudioPlayerDidStartPlayingNotification), object: nil)
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject,
        with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
            switch (stopReason) {
            case .eof:
                self.nextTrack()
            case .none:
                self.resume()
            default: break
            }
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [AnyObject]) {
        
    }
    
    // MARK: - PlayerViewControllerDelegate
    
    func playerViewControllerPlayPauseButtonPressed(_ playerViewController: RadioStreamViewController!) {
        switch (self._stk_audioPlayer.state) {
        case
            STKAudioPlayerState(),
            STKAudioPlayerState.paused,
            STKAudioPlayerState.stopped,
            STKAudioPlayerState.error,
            STKAudioPlayerState.disposed:
            self._stk_audioPlayer.resume()
        case
            STKAudioPlayerState.playing,
            STKAudioPlayerState.buffering:
            self._stk_audioPlayer.pause()
        default: break
        }
    }

    func playerViewControllerPauseButtonPressed(_ playerViewController: RadioStreamViewController!) {
        self._stk_audioPlayer.resume()
    }
    
    func playerViewControllerPreviousTackButtonPressed(_ playerViewController: RadioStreamViewController!) {
        self.previousTrack(true)
    }
    
    func playerViewControllerNextTackButtonPressed(_ playerViewController: RadioStreamViewController!) {
        self.nextTrack(true)
    }
    
    func playerViewController(_ playerViewController: RadioStreamViewController!, progressSliderValueChanged value: Float) {
        let time = self._stk_audioPlayer.duration * Double(value)
        self._stk_audioPlayer.seek(toTime: time)
    }
    
    // MARK: - Notifications
    
    @objc func routeDidChange(_ notification: Notification!) {
        guard
            let routeChangeReasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let routeChangeReason = AVAudioSession.RouteChangeReason(rawValue: routeChangeReasonValue)
            else { return }
        
        switch routeChangeReason {
        case .oldDeviceUnavailable:
            self.pause()
        default: break
        }
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSession.InterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey])
                return }
        switch interruptionType {
        case .began:
            print("began")
//            vox.pause()
//            music.pause()
        
            pause()
//            print("audioPlayer.playing", vox.isPlaying)
            /**/
            do {
                try theSession.setActive(false)
                print("AVAudioSession is inactive")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            pause()
        default :
            print("ended")
            if let optionValue = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSession.InterruptionOptions(rawValue: optionValue) == .shouldResume {
                print("should resume")
                // ok to resume playing, re activate session and resume playing
                /**/
                do {
                    try theSession.setActive(true)
                    print("AVAudioSession is Active again")
                    resume()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
               resume()
            }
        }
    }
    
}
