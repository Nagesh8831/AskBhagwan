//
//  GetInfoUser.swift
//  spotimusic
//
//  Created by appteve on 15/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire

class GetInfoUser: NSObject {
     internal func getResponseUser(_ userId: String,completionHandler : @escaping ((_ isResponse : NSDictionary) -> Void)) {
        
        //let urlRequest = String(format:"%@%@%@%@%@" ,BASE_URL_BACKEND,ENDPOINT_USER_INFO,userId,X_API_KEY, API_GENERAL_KEY)
        let url = String(format: "%@%@%@%@%@", BASE_URL_BACKEND,ENDPOINT_USER_INFO,userId,X_API_KEY,API_GENERAL_KEY)
        print(url)
        Alamofire.request( url,method: .get, parameters: nil)
            .responseJSON { response in
                guard let json = response.result.value  else {return}
                let JSON = json as! NSDictionary
                print ("JSON",JSON)
                 completionHandler(JSON)        }   
    }

}
