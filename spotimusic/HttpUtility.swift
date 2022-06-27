//
//  HttpUtility.swift
//  lilubi
//
//  Created by Girish Rathod on 30/11/15.
//  Copyright © 2015 Bitjini. All rights reserved.
//

import Foundation
import UIKit

//API documentations http://api.bar-gains.com:8080/api_docs/

class HttpUtility: NSObject {
    static var currentTask : URLSessionTask?
    //variable to check if previous http request was completed in categories view
    static var isCompleted = true
    
    class func cancelPreviousRequest() {
        if currentTask?.state == .running {
            isCompleted = false
            currentTask?.cancel()
        } else { isCompleted = true }
    }
    
    class func HTTPSendRequest(_ request: NSMutableURLRequest, callback: @escaping (AnyObject, String?) -> Void) {

        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 60.0
        
        currentTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else {
                callback("" as AnyObject, "Error: Request Timed Out I suppose...")
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                guard let json = result as? NSDictionary else { callback("" as AnyObject, ""); return }
                isCompleted = true
                print(json)
                callback(json as AnyObject, nil)
            } catch _ {
                print("Error", error?.localizedDescription)
                callback("" as AnyObject, error?.localizedDescription)
            }
        }
        
        currentTask!.resume()
    }
    
    class func JSONStringify(_ value: AnyObject,prettyPrinted:Bool = false) -> String {
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                
            }
        }
        return ""
    }
    
    
    class func HTTPPostJSON(_ url: String, jsonObj: AnyObject, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        request.addValue("testkey", forHTTPHeaderField: "X-API-KEY")
        let jsonString = JSONStringify(jsonObj)
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        request.httpBody = data
        
        HTTPSendRequest(request, callback: callback)
    }
    
    class func HTTPPostJSONString(_ url: String, jsonObj: String, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
        let jsonString = jsonObj
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        request.httpBody = data
        
        HTTPSendRequest(request, callback: callback)
    }
    
    
    class func HTTPPostData(_ url: String, token: String, mimeType: String, dataObj: Data, callback: @escaping (AnyObject, String?) -> Void) {
        
        let mutableURLRequest = NSMutableURLRequest(url: URL(string: url)!)
        mutableURLRequest.httpMethod = "POST"
        let boundaryConstant = generateBoundaryString()
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue(String(dataObj.count), forHTTPHeaderField: "Content-Length")
        mutableURLRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let uploadData = NSMutableData()
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"Sample\"; filename=\"file.jpg\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(dataObj)
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        mutableURLRequest.httpBody = uploadData as Data
      
        
        let task = URLSession.shared.dataTask(with: mutableURLRequest as URLRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                print(error)
                callback("" as AnyObject, "Error: Request Timed Out I suppose...")
                return
            }
            
            let returnString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(returnString)
            callback(returnString!, error?.localizedDescription)
        }) 
        
        task.resume()
    }
    
    class func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    class func HTTPPatchJSON(_ url: String, jsonObj: AnyObject, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
        let jsonString = JSONStringify(jsonObj)
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        request.httpBody = data
        
        HTTPSendRequest(request, callback: callback)
    }
    
    class func HTTPGetJSON(_ url: String, callback: @escaping (AnyObject, String?) -> Void) {
        var urlPath = url
        //let customSet = CharacterSet(charactersIn:" ").inverted
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(urlPath)
        let request = NSMutableURLRequest(url: URL(string:urlPath)!)
        
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        request.addValue("testkey", forHTTPHeaderField: "X-API-KEY")
        request.timeoutInterval = 30.0
        HTTPSendRequest(request, callback: callback)
    }
    
    class func HTTPGetJSONWithAuth(_ url: String, token: String, callback: @escaping (AnyObject, String?) -> Void) {
        
        var urlPath = url
        let customSet = CharacterSet(charactersIn:" ").inverted
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: customSet)!
        print(urlPath)
        
        let request = NSMutableURLRequest(url: URL(string:urlPath)!)
        print("Token = \(token)")
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("testkey", forHTTPHeaderField: "X-API-KEY")
        HTTPSendRequest(request, callback: callback)
    }

    
    class func HTTPGetJSONWithAuthAndParam(_ url: String, token: String, jsonObj: String, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string:url)!)
        
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
        let jsonString = JSONStringify(jsonObj as AnyObject)
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        request.httpBody = data

        HTTPSendRequest(request, callback: callback)
        
        
    }

    
    class func HTTPPostJSONWithAuth(_ url: String,token : String, jsonObj: AnyObject, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
        let jsonString = JSONStringify(jsonObj)
        let data: Data = jsonString.data(using: String.Encoding.utf8)!
        
        request.httpBody = data
        
        HTTPSendRequest(request, callback: callback)
    }
    
    class func HTTPGetImageData(_ url : URL, callback : @escaping (AnyObject, String?) -> Void) {
        print(url)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            guard let data = data else {
                callback("" as AnyObject, "Error")
                return
            }
            
            if error == nil {
                
                let image = UIImage(data: data)
                print(image)
                callback(data as AnyObject,nil)
            } else {
                print("Error")
                callback("" as AnyObject, error!.localizedDescription)
            }
        }) 
        task.resume()
    }
    
    class func HTTPDeleteWithAuth(_ url: String,token: String, completionHandler: @escaping (AnyObject, String?) -> Void) {
        
        let _url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //let _url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed())!
        let request = NSMutableURLRequest(url: URL(string: _url!)!)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/lilubi.com; version=1", forHTTPHeaderField: "Accept")
        
//        let jsonString = JSONStringify(parameter as AnyObject)
//        let data: Data = jsonString.data(using: String.Encoding.utf8)!
//        request.httpBody = data
        
        HTTPSendRequest(request, callback: completionHandler)
    }
    
    
    
    class func imageUploadRequest(url: String, token: String, fileName: String, mimeType: String, dataObj: Data, callback: @escaping (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(url:URL(string: url)!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", imageDataKey: dataObj as NSData, boundary: boundary, mimeType: mimeType, fileName: fileName) as Data
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                                                                     completionHandler: {
                                                                        (data, response, error) -> Void in
                                                                        if let data = data {
                // You can print out response object
                print("******* response = \(response)")
                print(data.count)
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")
                let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                
                print("json value \(json)")
                callback(json!, nil)
            } else if let error = error {
                print(error.localizedDescription)
                callback(error as AnyObject, error.localizedDescription)
            }
        })
        task.resume()
    }
    
    
    class func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, mimeType: String, fileName: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = fileName
        let mimetype = mimeType
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    class func downloadPDFFileWithUrl(fileURL: URL, fileName: String, callback: @escaping (Bool, String?) -> Void) {
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: fileURL)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    callback(true, nil)
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                    callback(false, "error")
                }
                
            } else {
                callback(false, error?.localizedDescription)
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
}


// extension for impage uploading
//extension NSMutableData {
//
//    func appendString(string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
//        append(data!)
//    }
//}









