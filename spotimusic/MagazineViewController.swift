//
//  MagazineViewController.swift
//  spotimusic
//
//  Created by Mac on 02/07/20.
//  Copyright © 2020 Appteve. All rights reserved.
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

class MagazineViewController: BaseViewController {
       @IBOutlet weak var magazineTableView: UITableView!
       @IBOutlet weak var noDataLabel: UILabel!
       @IBOutlet weak var menuBtn: UIBarButtonItem!
    var subscriptionStatus  = false
    var webLink = ""
       var magazineArray = [[String: AnyObject]]()
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
        self.title = "Magazines/Podcast"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
            self.getAllOnlineMagazine()
        Timer.scheduledTimer(timeInterval:300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MagazineViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return magazineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BlogDescriptionTableViewCell
        let mainDta = self.magazineArray[indexPath.row] as NSDictionary
        cell.postImages.isHidden = false
        cell.blogNumberLabel.isHidden = true
        if let title = mainDta.value(forKey: "title"){
            cell.titleLabel.text =  title as? String
           // print(title)
        }
        cell.blogNumberLabel.text = String(indexPath.row + 1) + "."
        let imageUrl = mainDta.value(forKey: "cover") as? String
        cell.postImages.layer.cornerRadius = 5.0
        cell.postImages.clipsToBounds = true
        cell.postImages.layer.borderWidth = 1.0
        cell.postImages.layer.borderColor = UIColor.clear.cgColor
        if imageUrl != "" {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,MAGAZIN,imageUrl!)
            let url = URL(string: imgeFile)
            DispatchQueue.main.async(execute: {
                if imgeFile != "" {
                    if let _ = cell.postImages {
                        cell.postImages.kf.setImage(with: url, placeholder: UIImage(named: "event"))
                    } else {
                        cell.postImages.image = UIImage(named: "event")
                    }
                }else {
                    cell.postImages.image = UIImage(named: "event")
                }
            })
        } else {
            cell.postImages.image = UIImage(named: "event")
        }
       return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainDta = self.magazineArray[indexPath.row] as NSDictionary
        
        if let websiteLink = mainDta.value(forKey: "website_link"){
            webLink = websiteLink as! String
        }
        if webLink != "" {
            if let url = URL(string: webLink){
                UIApplication.shared.open(url)
            }
        }else {
            let vc = storyboard?.instantiateViewController(withIdentifier:  "BlogDescriptionViewController") as! BlogDescriptionViewController
            if let title = mainDta.value(forKey: "doc_link"){
                vc.htmlString = title as! String
                vc.isFromMagazine = true
            }
            if let title = mainDta.value(forKey: "title"){
                vc.titleStr =  (title as? String)!
               // print(title)
            }

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        return 80
    }
    
}
extension MagazineViewController {
    func getAllOnlineMagazine(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ONLINE_MAGAZINE)
       // print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":"","limit":10000000,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                   // print("News_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.magazineArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.magazineArray.count > 0 {
                        DispatchQueue.main.async() {
                            self.magazineTableView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.magazineTableView!.isHidden = false
                        }
                    } else {
                        //self.view.bringSubview(toFront: self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No magazine available"
                        self.magazineTableView!.isHidden = true
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
