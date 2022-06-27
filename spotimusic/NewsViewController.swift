//
//  NewsViewController.swift
//  spotimusic
//
//  Created by Mac on 05/02/19.
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
class NewsViewController: BaseViewController {

    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    var newsArray = [[String: AnyObject]]()
    var subscriptionStatus  = false
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
         navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Blogs/Articles"
        // Do any additional setup after loading the view.
    }
    @objc func callBack(){
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
             if subscriptionStatus == true {
                 print("User subscribed")
             }else {
                showAdds()
               // IronSource.showRewardedVideo(with: self)
             }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getAllNews()
        Timer.scheduledTimer(timeInterval:300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
//        if self.newsArray.count > 0 {
//            Utilities.displayToastMessage("Swipe left for more news")
//        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NewsViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BlogDescriptionTableViewCell
        let mainDta = self.newsArray[indexPath.row] as NSDictionary
        if let title = mainDta.value(forKey: "title"){
            cell.titleLabel.text =  title as? String
           // print(title)
        }
        cell.blogNumberLabel.text = String(indexPath.row + 1) + "."
       return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainDta = self.newsArray[indexPath.row] as NSDictionary
        let vc = storyboard?.instantiateViewController(withIdentifier:  "BlogDescriptionViewController") as! BlogDescriptionViewController
        if let title = mainDta.value(forKey: "description"){
            vc.htmlString = title as! String
        }
        
//        if let image = mainDta.value(forKey: "image"){
//            vc.imageString = image as! String
//        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        return 80
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
}
extension NewsViewController {
    func getAllNews(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_NEWS_SEARCH)
       // print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":"","limit":10000,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                   // print("News_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.newsArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.newsArray.count > 0 {
                        DispatchQueue.main.async() {
                            self.newsTableView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.newsTableView!.isHidden = false
                        }
                    } else {
                        //self.view.bringSubview(toFront: self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No blogs/aricles available"
                        self.newsTableView!.isHidden = true
                    }
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }
}
class BlogDescriptionTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blogNumberLabel: UILabel!
    @IBOutlet weak var postImages: UIImageView!
}
