//
//  AppUtility.swift
//  Sovica
//
//  Created by apple on 28/04/17.
//  Copyright © 2017 Concat Softwares. All rights reserved.
//

import UIKit

import Reachability

class AppUtility: NSObject {

    //declare this property where it won't go out of scope relative to your listener
   // let reachability = Reachability()
    let reachability = try! Reachability()
    var mIsNetworkAvailable = false
    
    //MARK:- Singleton
    static var instance: AppUtility? = nil
    class var sharedInstance: AppUtility {
        
        if instance == nil {
            self.instance = AppUtility()
        }
        return self.instance!
    }
    
    //MARK:- Reachability Utility
    
    func initializeReachabilityCallbacks() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            mIsNetworkAvailable = true
        } else {
            print("Network not reachable")
            mIsNetworkAvailable = false
        }
    }
    
    
    
}
