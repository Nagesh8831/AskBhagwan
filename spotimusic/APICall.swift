//
//  APICall.swift
//  lilubi
//
//  Created by Muqtadir Ahmed on 02/12/15.
//  Copyright © 2015 Bitjini. All rights reserved.
//

import Foundation
import UIKit

class APICall {


        static var baseURL = "https://ask-osho.net/"
       //static var baseURL = "http://35.154.125.187/"
    

    class func getAllStateByCountryId(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
                let urlPath = baseURL + "endpoint/country/getAllStateByCountryId"
                HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
                    if error != nil {
                        callback(error! as AnyObject)
                    } else {
                        callback(data)
                    }
                }
    }
    
    class func searchUser(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/appusers/search/"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }
    
    class func searchCommunity(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/community/search/"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }
    
    class func acceptRejectCommunity(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/community/acceptrejectcomrequest"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }
    
    class func addUserToCommunity(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/community/addusrtocom"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }
    
    class func addPostToCommunity(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/community/addcompost"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }
    
    class func getAllAshramByStateId(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/country/getAllAshramByStateId"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }

    class func addEventUser(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/event/addeventuser"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }

    class func removeEventUser(_ credentials: [String : AnyObject], callback: @escaping (AnyObject) -> Void) {
        let urlPath = baseURL + "endpoint/event/removeeventuser"
        HttpUtility.HTTPPostJSON(urlPath, jsonObj: credentials as AnyObject) { (data, error) -> Void in
            if error != nil {
                callback(error! as AnyObject)
            } else {
                callback(data)
            }
        }
    }

    class func getAllPost(_ id: String, callback: @escaping (AnyObject) -> Void) {
        let url = baseURL + "endpoint/community/allpostbycommunityid?id=\(id)&limit=500&offset=0"
        print(url)
        HttpUtility.HTTPGetJSON(url, callback: { (data, error) in
            print(data)
            if let _ = error {
                callback("Error" as AnyObject)
                return
            }
            callback(data)
            })

    }
    
    class func getFriends(_ id: String, callback: @escaping (AnyObject) -> Void) {
        let url = baseURL + "endpoint/community/allcomusrbycomid?id=\(id)&limit=500&offset=0"
        print(url)
        HttpUtility.HTTPGetJSON(url, callback: { (data, error) in
            print(data)
            if let _ = error {
                callback("Error" as AnyObject)
                return
            }
            callback(data)
        })
        
    }

}

