//
//  ImageWebUpload.swift
//  iCast
//
//  Created by appteve on 09/02/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit

class ImageWebUpload: NSObject {
    
    var urlimage :String!
    var success:Bool = false
    func imageUploadRequest(image: UIImage, uploadUrl: NSURL, param: [String:String]?, completion:@escaping (_ success: Bool) -> ()){
        
        let request = NSMutableURLRequest(url:uploadUrl as URL);
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.jpegData(compressionQuality: 1)
           // UIImageJPEGRepresentation(image, 1)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
    
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                                               completionHandler: {
                                                (data, response, error) -> Void in
                                                if let data = data {
                                                    print("response",data)
                                                    let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                                                    
                                                    let data = json!.value(forKey:"upload_data") as! NSDictionary
                                                    print("data",data)
                                                    self.urlimage = data.value(forKey: "file_name") as! String
                                                  //  self.urlimage = json!.value(forKey: "image") as! String
                                                   
                                                    self.success = true
                                                    completion(self.success)
                                                    
                                                  
                                                }
                                                
        })
        
        
        task.resume()
        
        
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "images.jpg"
        
        let mimetype = "image/jpg"
        
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
    
}


extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}















