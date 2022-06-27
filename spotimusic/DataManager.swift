
//

import UIKit

class DataManager {
    
    
    
    class func getStationDataWithSuccess(_ success: ((_ metaData: Data?) -> Void)) {

    }
    
    
    class func getDataFromFileWithSuccess(_ success: @escaping (_ data: Data) -> Void) {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            
            let filePath = Bundle.main.path(forResource: "stations", ofType:"json")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath!),
                    options: NSData.ReadingOptions.uncached)
                success(data)
            } catch {
                fatalError()
            }
        }
    }
    
    class func getTrackDataWithSuccess(_ queryURL: String, success: @escaping ((_ metaData: Data?) -> Void)) {
        
        loadDataFromURL(URL(string: queryURL)!) { data, _ in
            // Return Data
            if let urlData = data {
                success(urlData)
            } else {
               // if DEBUG_LOG { print("API TIMEOUT OR ERROR") }
            }
        }
    }

    
    
    
    class func getData(_ queryURL: String, success: @escaping ((_ metaData: Data?) -> Void)) {

        loadDataFromURL(URL(string: queryURL)!) { data, _ in
            if let urlData = data {
                success(urlData)
            } else {
               // if DEBUG_LOG { print("API TIMEOUT OR ERROR") }
            }
        }
    }
    
   
    
    class func loadDataFromURL(_ url: URL, completion:@escaping (_ data: Data?, _ error: NSError?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess          = true
        sessionConfig.timeoutIntervalForRequest     = 15
        sessionConfig.timeoutIntervalForResource    = 30
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: sessionConfig)
        
        let loadDataTask = session.dataTask(with: url, completionHandler: { data, response, error in
            if let responseError = error {
                completion(nil, responseError as NSError)
                
              //  if DEBUG_LOG { print("API ERROR: \(error)") }
                
                
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"io.codemarket", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    
                   // if DEBUG_LOG { print("API: HTTP status code has unexpected value") }
                    
                    completion(nil, statusError)
                    
                } else {
                    
                    completion(data, nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    class func audioFiles() -> [Audio] {
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let newDir = documentsDirectory.appendingPathComponent("music") as NSString
        let documentsDirectoryURL = URL(fileURLWithPath: newDir as String, isDirectory: true)
        
        var files: [AnyObject]?
        do {
            files = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL,
                                                                                includingPropertiesForKeys: nil, options: .skipsHiddenFiles) as [AnyObject]
        } catch let error as NSError {
            NSLog("error: \(error)")
            return [Audio]()
        }
        
        
        let sortedFiles: NSArray = (files as NSArray?)?.sortedArray (comparator: { (obj1, obj2) -> ComparisonResult in
            
            let attr1: NSDictionary = try! FileManager.default.attributesOfItem(atPath: (obj1 as! URL).path) as NSDictionary
            let date1 = attr1.object(forKey: FileAttributeKey.modificationDate) as! Date
            
            let attr2: NSDictionary = try! FileManager.default.attributesOfItem(atPath: (obj2 as! URL).path) as NSDictionary
            let date2 = attr2.object(forKey: FileAttributeKey.modificationDate) as! Date
            
            return date2.compare(date1)
        }) as! NSArray
        
        var audioFiles = [Audio]()
        for fileURL in sortedFiles {
            
         //   print(fileURL)
            audioFiles.append(Audio(fileURL: fileURL as! URL))
        }
        
        return audioFiles
    }
    
    class func removeFile(_ fileURL: URL, error: NSErrorPointer) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let fileError as NSError {
            error?.pointee = fileError
        }
    }
}
