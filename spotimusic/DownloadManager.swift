

import UIKit
import Foundation
import CoreData
import AVFoundation
let NewFilesAvailableNotification = "NewFilesAvailableNotification"

class DownloadOperation: Operation, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    fileprivate var done = false
    var URL: Foundation.URL!
    var suggestedFilename: String?
    var session: Foundation.URLSession!
    var downloadTask: URLSessionDownloadTask!
    var previouslyLoggedValue: Int = -1
    var downloadstatus = 0
    var downloadfileArray = Array<String>()
    var downloadFileURLArray = Array<URL>()
    init(URL: Foundation.URL, suggestedFilename: String?) {
        super.init()
        self.URL = URL
        self.suggestedFilename = suggestedFilename
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 5
        self.session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.downloadTask = session.downloadTask(with: self.URL)
        
    }
    
    override func main() {
        if self.isCancelled { return }
        self.downloadTask!.resume()
        repeat {
            if self.isCancelled {
                self.downloadTask.cancel()
            }
            RunLoop.current.run(mode:RunLoop.Mode.default, before: Date.distantFuture as Date)
        }
            while (!self.done)
    }
    
    func sanitizeFileName(_ fileName: String) -> String {
        let illegalFileNameCharacters = CharacterSet(charactersIn:" /\\?%*|\"<>")
        return fileName.components(separatedBy: illegalFileNameCharacters).joined(separator: "_")
    }
    // MARK: - NSURLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
             Utilities.displayToastMessage(error.localizedDescription)
        }
        NotificationCenter.default.post(name: Notification.Name("showProgressBarError"), object: nil)
        self.done = true
        let filename = self.downloadfileArray[3]
        let newStringA = filename.replacingOccurrences(of: ".mp3", with: "")
        if let url = DownloadManager.sharedManager.getDownloadedSongs(fileName: newStringA) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error as NSError {
                NSLog("error: \(error)");
                return
            }
        }
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let contentLenght = downloadTask.response?.expectedContentLength {
            let progress = Double(totalBytesWritten) / Double(contentLenght)
            let progressPercentage = Int(progress * 100)
            if (progressPercentage != self.previouslyLoggedValue) && contentLenght > 0{
                downloadstatus = self.downloadstatus + 1
                previouslyLoggedValue = progressPercentage
                Utilities.displayToastMessage("Downloading: \(progressPercentage)%")
               // print("completed: \(progressPercentage)%")
                if progressPercentage == 1 {
                    UserDefaults.standard.set(progressPercentage, forKey: "showProgressBar")
                    UserDefaults.standard.synchronize()
                }
                if downloadstatus == 10 {
                    downloadstatus = 0
                     NotificationCenter.default.post(name: Notification.Name("showProgressBar"), object: nil)
                }
                if progressPercentage == 100 {
                    Utilities.displayToastMessage("Download completed...")
                }
               
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        var fileName = self.suggestedFilename
        if fileName == nil {
            fileName = downloadTask.response?.suggestedFilename
        }
        fileName = self.sanitizeFileName(fileName!)
        
        //let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        // let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path:NSArray =         NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        // let documentsDirectory: AnyObject = paths[0] as AnyObject
        let documentsDirectory = path.object(at: 0) as! NSString
        let dataPath = documentsDirectory.appendingPathComponent("music")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        let dirPath = DownloadManager.sharedManager.documentsDirectory as NSString
        print(dirPath,dirPath)

        let folder = "/music" as NSString
        let dirPathMusic = String(format: "%@%@",dirPath,folder) as NSString
        
        UserDefaults.standard.set(dirPathMusic, forKey: "disPath")
        UserDefaults.standard.synchronize()
        print("My song",dirPathMusic)
        
        let filePath = dirPathMusic.appendingPathComponent(fileName!)
        let destURL = Foundation.URL(fileURLWithPath: filePath)
        
        do {
            try FileManager.default.moveItem(at: location, to: destURL)
        } catch let error as NSError {
            NSLog("error: \(error)");
            return
        }
        let duration = AVURLAsset(url: destURL).duration.seconds
        print(duration)
        DispatchQueue.main.async(execute: {
            if duration == 0 {
                Utilities.displayToastMessage("Opps.. download failed....")
                return
            }
        })
        
        let time: String
        if duration > 3600 {
            time = String(format:"%dh %dm %ds",
                          Int(duration/3600),
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%dm %ds",
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        }
        print(time)
        DispatchQueue.main.async {
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDel.managedObjectContext
            let newFav = NSEntityDescription.insertNewObject(forEntityName: "DownloadedFile", into: context)
            newFav.setValue(self.downloadfileArray[0] , forKey: "imageName")
            newFav.setValue(self.downloadfileArray[1], forKey: "name")
            newFav.setValue(self.downloadfileArray[2] , forKey: "type")
            newFav.setValue(self.downloadfileArray[3], forKey: "fileID")
            newFav.setValue(self.downloadfileArray[4] , forKey: "id")
            newFav.setValue(self.downloadfileArray[5], forKey: "artist")
            newFav.setValue(self.downloadfileArray[6], forKey: "plays")
            newFav.setValue(filePath, forKey: "url")
            do {
                try context.save()
            } catch {
            }
        }
        NSLog("saved as: \(fileName!)");
        NotificationCenter.default.post(name: Notification.Name(rawValue: NewFilesAvailableNotification), object: nil)
    }
}

class DownloadManager: NSObject {
    static let sharedManager = DownloadManager()
    var documentsDirectory: String!
    var operationQueue: OperationQueue!
    var dFileArray = Array<String>()
    override init() {
        super.init()
        self.documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
    func startDownload(_ URL: Foundation.URL!, suggestedFilename: String? = nil) -> DownloadOperation {
        let operation = DownloadOperation(URL: URL, suggestedFilename: suggestedFilename)
        self.operationQueue.addOperation(operation)
        operation.downloadfileArray = dFileArray
        Utilities.displayToastMessage("Store offline...")
        return operation
    }
    func downloadTaskData(type: String , fileName: String ,fileImageStr: String ,fileId: String, id: String , artist: String, plays: String) {
        var fileType = String()
        if type == "Audio" {
            fileType = AUDIO_TRACK
        }else {
            fileType = PLAYVIDEO
        }
        if  fileId == "" {
            return
        }else {
            let urlwithPercentEscapes = fileId.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let fileURL = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,fileType,urlwithPercentEscapes!)
            
            let url =  URL(string: fileURL)
            dFileArray = Array(arrayLiteral: fileImageStr , fileName , type , fileId ,id , artist , plays)
            _ = DownloadManager.sharedManager.startDownload(url)
        }
    }
    
   class func downloadSongs(mainDta: NSDictionary , type: String) {
        var fileName = ""
        var fileId = ""
        var imageName = ""
        var trackId = ""
        var artistId = ""
        var plays = ""
        fileName = mainDta.value(forKey: "name") as! String
        imageName = mainDta.value(forKey: "cover") as! String
        fileId = mainDta.value(forKey: "file") as! String
        trackId = (mainDta.object(forKey: "id") as? String)!
        artistId = (mainDta.object(forKey: "artist") as? String)!
        plays = (mainDta.object(forKey: "plays") as? String)!
        DownloadManager.sharedManager.downloadTaskData(type: type , fileName: fileName, fileImageStr: imageName, fileId: fileId, id: trackId, artist: artistId, plays: plays)
    }
    
    class func downloadSongsForDiscoures(mainDta: NSDictionary , type: String) {
        var fileName = ""
        var fileId = ""
        var imageName = ""
        var trackId = ""
        var artistId = ""
        var plays = ""
        fileName = mainDta.value(forKey: "file_name") as! String
        imageName = mainDta.value(forKey: "cover") as! String
        fileId = mainDta.value(forKey: "file") as! String
        trackId = (mainDta.object(forKey: "id") as? String)!
        artistId = (mainDta.object(forKey: "artist") as? String)!
        plays = (mainDta.object(forKey: "plays") as? String)!
        DownloadManager.sharedManager.downloadTaskData(type: type , fileName: fileName, fileImageStr: imageName, fileId: fileId, id: trackId, artist: artistId, plays: plays)
    }
    
    
    class func getDownloadedObject(predicate: String) -> Bool {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedFile")
        request.predicate =  NSPredicate(format: "fileID = %@", predicate)
        var isdownloaded = true
        request.returnsObjectsAsFaults = false
        if let result = try? context.fetch(request) {
            if result.count > 0 {
                isdownloaded = false
            }
        }
        return isdownloaded
    }

    //func for get the list of downlaoded song
    func getDownloadedSongs(fileName: String)-> URL? {
        let dirPath = DownloadManager.sharedManager.documentsDirectory as NSString
        let folder = "/music" as NSString
        let dirPathMusic = String(format: "%@%@",dirPath,folder) as NSString
        
        print(dirPathMusic)
        
        let filePath = dirPathMusic.appendingPathComponent(fileName)
        let destUrl = NSURL(string: filePath)
        if let pathComponent = destUrl {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath!) {
                return pathComponent as URL
            } else {
                print("FILE NOT AVAILABLE")
                return nil
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
            return nil
        }

    }
//    Printing description of fileURL:
//    "https://avapplicationstaging.s3.amazonaws.com/audios/track/153249741610.mp3"
}
