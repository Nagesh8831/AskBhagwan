//
//  RecentPlayTrackData.swift
//  spotimusic
//
//  Created by Mac on 05/02/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
import UIKit
import Alamofire
import CoreData
import CZPicker
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
class RecentPlayTrackData: NSObject {

    static let shared = RecentPlayTrackData()
    func recentplayTrack1( trackId : String,trackType:Int) {
        // SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_RECENT_PLAY_TRACK)
        if let userId = GLOBAL_USER_ID {
            Alamofire.request(urlRequest,method: .post, parameters: ["user_id": userId.stringValue,"track_id":trackId,"track_type": trackType,"X-API-KEY":API_GENERAL_KEY])
                       .responseJSON { response in
                           SVProgressHUD.dismiss()
                           
                           switch response.result {
                           case .success :
                               
                               print("Trackresponse",response)
                               
                               guard let json = response.result.value else {return}
                               let JSON = json as! NSDictionary
                           case .failure(let error):
                               print(error)
                               let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                               DispatchQueue.main.async {
                                   //self.present(alert, animated: true, completion: nil)
                               }
                           }
                   }
        }
        // print("trackId", trackIds)
       
        
    }
}
