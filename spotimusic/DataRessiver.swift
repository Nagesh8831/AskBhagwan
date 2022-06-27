//
//  DataRessiver.swift
//  spotimusic
//
//  Created by appteve on 25/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire

class DataRessiver: NSObject {
    
    
    class func dataAudioProvideTop(_ offset: Int, size: Int, successBlock: @escaping (_ songs: Array<Audio>?) -> Void, failureBlock: ((_ error: NSError?) -> Void)? = nil) {
        
//        let urlReq = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_TREND)
//        
//        
//        Alamofire.request( urlReq,method: .post, parameters:["X-API-KEY": API_GENERAL_KEY, "offset":offset,"limit":size])
//            .responseJSON { response in
//                
//                do{
//                    guard let json = response.result.value  else {return}
//                let JSON =  json as! NSDictionary
//                let allsongs = JSON.value(forKey: "respon") as! NSArray
//                
//                print("COCO R - : ", allsongs.count)
//                
//                if allsongs.count == 0 {
//                    
//                }  else {
//                    
//                    var songs: Array<Audio> = []
//                    
//                    for music in allsongs {
//                        
//                        let song = Audio(soundDictonary: music as! NSDictionary)
//                        songs.append(song)
//                        
//                    }
//                    
//                    successBlock(songs)
//                    
//                    
//                }
//                    
//                }
//                
//        }
    }
    
                

}
