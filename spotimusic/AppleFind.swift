//
//  AppleFind.swift
//  spotimusic
//
//  Created by appteve on 04/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire


class AppleFind: NSObject {
    
    var imageout: UIImage!
    
    internal func getResponseImageBig(_ trackData: String,completionHandler : @escaping ((_ isResponse : String) -> Void)) {
        
//        
//        let queryURL = String(format: "https://itunes.apple.com/search?term=%@&limit=1", trackData)
//        let escapedURL = queryURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        
//        Alamofire.request(escapedURL!, method: .get)
//            .responseJSON { response in
//                
//                
//                let resp = response.result.value as! NSDictionary
//                let count  = resp.value(forKey: "resultCount") as! NSNumber
//                
//                if count == 0 {
//                    
//                    
//                    completionHandler(DEF_IMAGE)
//                    
//                    
//                } else {
//                    
//                    let dats = resp.value(forKey: "results") as! NSArray
//                    let resu = dats.object(at: 0) as! NSDictionary
//                    let art = resu.value(forKey: "artworkUrl100") as! String
//                    let bigArtwork = art.replacingOccurrences(of: "100", with: "800")
//                  //  let uratr = String(format: "%@",art)
//                    completionHandler(bigArtwork)
//                    
//                   
//                    
//                    
//                    
//                }
//                
//                
//                
//           }

        
    }
    
    internal func getResponseImageMin(_ trackData: String,completionHandler : @escaping ((_ isResponse : String) -> Void)) {
        
       
        
        let queryURL = String(format: "https://itunes.apple.com/search?term=%@&limit=1", trackData)
        let escapedURL = queryURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(escapedURL!, method: .get)
            .responseJSON { response in
                
                
                let resp = response.result.value as! NSDictionary
                let count  = resp.value(forKey: "resultCount") as! NSNumber
                
                if count == 0 {
                    
                    
                    completionHandler(DEF_IMAGE)
                    
                    
                } else {
                    
                    let dats = resp.value(forKey: "results") as! NSArray
                    let resu = dats.object(at: 0) as! NSDictionary
                    let art = resu.value(forKey: "artworkUrl100") as! String
                    let bigArtwork = art.replacingOccurrences(of: "100", with: "800")
                    //  let uratr = String(format: "%@",art)
                    completionHandler(art)
                    
        
                }
                
                
                
        }
        
        
    }


}
