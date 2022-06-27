

import UIKit
import AVFoundation
import Reachability
import SCLAlertView
class Audio: NSObject {
    
    override var description: String { return fileName! }
    var fileURL: URL?
    var remoteURL: URL?
    var fileName: String?
    var title: String?
    var discourseTitle: String?
    var artist: String?
    var trackId: String?
    var artistId: String?
    var playCount: String?
    var imageString : String?
    var imageString1 : String?
    var coverImage:UIImageView!
    var reachabilitysz: Reachability!
    var size: Int = 0       // bytes
    var duration: Int = 0   // seconds
    var bitrate: Int {      // kbps
        if size > 0 && duration > 0 {
            return size * 8 / 1000 / duration
        }
        return 0
    }
    
    var downloadOperation: DownloadOperation?
    
    var soundDictonary: NSDictionary?
    var ImageDictonary: NSDictionary?
    
    init(fileURL: URL) {
        
        print("inturl")
        self.fileURL = fileURL
        self.fileName = fileURL.lastPathComponent
        
        
        let stringTitle  = fileURL.lastPathComponent as String
        let newStringA = stringTitle.replacingOccurrences(of: "_", with: " ")
        var newStringB = ""
        if newStringA.contains(".tmp") {
           newStringB = newStringA.replacingOccurrences(of: ".tmp", with: "")
        }else {
           newStringB = newStringA.replacingOccurrences(of: ".mp3", with: "")
        }
        var myStringArr = newStringB.components(separatedBy: "-")
        
        
        self.artist = myStringArr[0]
        if myStringArr.count >= 2 {
           self.title = myStringArr[1]
        }
        let filePath = fileURL.path
        var fileAttributes: NSDictionary?
        do {
            fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
        } catch {
            super.init()
            return
        }
        
        self.size = fileAttributes!.object(forKey: FileAttributeKey.size) as! Int
        
        super.init()
        
        self.loadMetadata(self.fileURL!)
    }
    
    init(soundDictonary: NSDictionary) {
        self.soundDictonary = soundDictonary
        self.ImageDictonary = soundDictonary
        if let artid = soundDictonary.object(forKey: "name") as? String {
            var artistAndTrack = artid.components(separatedBy: "")
            if (artistAndTrack.count > 1) {
                self.artist = artistAndTrack[0]
                self.title = artistAndTrack[1]
            } else {
                self.artist = artistAndTrack[0]
                self.title = artistAndTrack[0]
                
            }
        }
        if let artid = soundDictonary.object(forKey: "file_name") as? String {
            var artistAndTrack = artid.components(separatedBy: "")
            if (artistAndTrack.count > 1) {
                self.artist = artistAndTrack[0]
                self.discourseTitle = artistAndTrack[1]
            } else {
                self.artist = artistAndTrack[0]
                self.discourseTitle = artistAndTrack[0]
                
            }
        }
        
        if let file = soundDictonary.object(forKey: "file") as? String {
            do {
                reachabilitysz = try Reachability()
            }catch{
                
            }
            
            var urlPodcast = String()
                if (reachabilitysz?.isReachable)!{
                    urlPodcast = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO_TRACK,file)
                    print("URL_T: ",urlPodcast)
                } else {
//                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
//                    }
//                    let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
//                    
//                    SCLAlertView().showTitle("Internet not available" , subTitle: "Please try after sometime...", timeout: time, completeText: "Done", style:  .success)
                }
            
             
            var escapedURL = urlPodcast.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            self.fileURL = URL(string: escapedURL)
            self.remoteURL = URL(string: escapedURL)
        }
        
        self.trackId = soundDictonary.object(forKey: "id") as? String
        
        self.artistId = soundDictonary.object(forKey: "artist") as? String
        self.playCount = soundDictonary.object(forKey: "plays") as? String
        if let imagestr = soundDictonary.object(forKey: "cover") as? String{
            self.imageString = imagestr
        }
        var imgeFile = ""
            imgeFile = ""
        let url = URL(string: imgeFile)
        print("url",url)
        let controller = RadioStreamViewController.sharedInstance
        controller.imageUrl = imgeFile

        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "trackinlist") as! TrackInListTableViewController
           vc.imageStr = imgeFile
        super.init()
    }
    
    func loadMetadata(_ fileURL: URL) {
        let asset = AVURLAsset(url: fileURL, options: nil)
        duration = Int(CMTimeGetSeconds(asset.duration))
        
        if let value = (AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: AVMetadataKeySpace.common).first as? AVMutableMetadataItem)?.value { artist = value as? String }
        
        if let value = (AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common).first as? AVMutableMetadataItem)?.value { title = value as? String }
        
       
    }
    
    
}
