//
//  BlogDescriptionViewController.swift
//  spotimusic
//
//  Created by Mac on 06/05/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

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
import StoreKit
class BlogDescriptionViewController: BaseViewController,UIWebViewDelegate {

    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webViewDes: UIWebView!
    var htmlString = ""
    var isFromMagazine = false
    var subscriptionStatus  = false
    var adsTimer: Timer!
    var titleStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        webViewDes.delegate = self
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
        activityIndicator.sizeToFit()
        title = titleStr
        view.addSubview(activityIndicator)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(callBack), userInfo: nil, repeats: true)
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.addCallBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        if isFromMagazine {
            //SVProgressHUD.show()
//            if let pdf = Bundle.main.url(forResource: "1594629452Normal_USER_Year__report_2019", withExtension: "pdf", subdirectory: nil, localization: nil)  {
//                let req = NSURLRequest(url: pdf)
//                webViewDes.loadRequest(req as URLRequest)
//                webViewDes.scalesPageToFit = true
//                SVProgressHUD.dismiss()
            let docLink = "http://drive.google.com/viewerng/viewer?embedded=true&url=https://avapplication.s3.amazonaws.com/onlinemagazines/" + htmlString
                let request = URLRequest(url: URL(string:docLink)!)
               // DispatchQueue.main.async {
                   // self.wkBWEB.load(request)
                    self.webViewDes.loadRequest(request)
                   // SVProgressHUD.dismiss()
                //}
            //}
//            let url: URL! = URL(string: "1594629452Normal_USER_Year__report_2019")
//            webViewDes.loadRequest(URLRequest(url: url))
//            SVProgressHUD.dismiss()
            
        }else {
            webViewDidFinishLoad(webView: webViewDes)
            webViewDes.loadHTMLString(htmlString,baseURL: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    @objc func callBack(){
        activityIndicator.stopAnimating()
    }
    @objc func addCallBack(){
          subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
              if subscriptionStatus == true {
                  print("User subscribed")
              }else {
                showAdds()
                //IronSource.showRewardedVideo(with: self)
              }
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let zoom = webView.bounds.size.width / webView.scrollView.contentSize.width
        webView.scrollView.setZoomScale(zoom, animated: true)
         activityIndicator.stopAnimating()
    }
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
//        activityIndicator.startAnimating()
//        myProgressView.progress = 0
//        theBool = false
//        myTimer =  NSTimer.scheduledTimerWithTimeInterval(0.01667,target: self,selector: #selector(ViewController.timerCallback),userInfo: nil,repeats: true)
    }

//    func webViewDidFinishLoad(webView: UIWebView) {
//        activityIndicator.stopAnimating()
//        theBool = true
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIWebView {
    ///Method to fit content of webview inside webview according to different screen size
    func resizeWebContent() {
        let contentSize = self.scrollView.contentSize
        let viewSize = self.bounds.size
        let zoomScale = viewSize.width/contentSize.width
        self.scrollView.minimumZoomScale = zoomScale
        self.scrollView.maximumZoomScale = zoomScale
        self.scrollView.zoomScale = zoomScale
    }
}

