//
//  ShareOnViewController.swift
//  spotimusic
//
//  Created by KO158S8 on 20/06/22.
//  Copyright © 2022 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class ShareOnViewController: BaseViewController {
    var isFromAudio = false
    var isFromJokes = false
    var isFromWorldMusic = false
    var mainData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    @IBAction func socialMediaButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        shareApiCall(index: sender.tag)
    }
    @IBAction func communityButtonAction(_ sender: UIButton) {
        if isFromJokes {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
            
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "7"
            self.present(secondViewController, animated: true, completion: nil)
        } else if isFromAudio {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
            
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "1"
            self.present(secondViewController, animated: true, completion: nil)
        } else if isFromWorldMusic {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
            
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "8"
            self.present(secondViewController, animated: true, completion: nil)

        } else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
            
            secondViewController.isShare = true
            secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
            secondViewController.trackType = "5"
            self.present(secondViewController, animated: true, completion: nil)
        }
        self.dismiss(animated: true)
    }
    
    func shareApiCall(index:Int) {
        self.dismiss(animated: true)
        let urlRequest = "\(BASE_URL_BACKEND)/endpoint/appusers/generatelink/"
        print(urlRequest)
        let user_id = GLOBAL_USER_ID.intValue
        let category = mainData["category"]
        print(category ?? 0)
        
        let av_id = mainData["id"]
        var param = [String:Any]()
        if isFromJokes {
            param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":4]
        } else if isFromWorldMusic {
            param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":3]
        } else if isFromAudio {
            param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type": 1,"media_category":1]
        } else {
            param = ["user_id": user_id,"av_id":av_id ?? 0,"media_type":2,"media_category":2]
        }
        print(param)
        SVProgressHUD.show()
        Alamofire.request( urlRequest,method: .post ,parameters: param)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print(response)
                guard let item = response.result.value as! NSDictionary? else {return}
                print(item)
                guard let error = item["error"] as? NSInteger? else {return}
                //  print(error)
                if error == 1 {
                    //  print("error")
                    self.alert("Oops!", subTitle: "You are not a subscribed user")
                    
                } else {
                    guard let resp = item["respon"] as! NSDictionary? else {return}
                    print(resp)
                    let titleStr = (resp["cover"] as? NSString) ?? ""
                    print(titleStr)
                    let nameStr = (resp["name"] as? NSString) ?? ""
                    print(nameStr)
                    let linkStr = (resp["link"] as? NSString) ?? ""
                    print(linkStr)
                    
                    
                    let textToShare = "\(nameStr) \n\n\(linkStr)"
                    print(textToShare)
                    
                    let objectsToShare: [Any] = [textToShare]
                    //                        print(objectsToShare)
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    DispatchQueue.main.async {
                        self.getTopMostViewController()?.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
}
