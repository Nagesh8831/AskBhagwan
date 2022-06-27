//
//  MeditationTechniqueViewController.swift
//  spotimusic
//
//  Created by BQTMAC003 on 09/03/20.
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

class MeditationTechniqueViewController: BaseViewController {
    var searchText = ""
    var searchActive = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var meditationTechniqueTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    var meditationTechniqueArray = [[String: AnyObject]]()
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
        //self.title = "Meditation Techniques"
        self.title = "Instructions"
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getAllMeditationTechnique(searchText)
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
extension MeditationTechniqueViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meditationTechniqueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! meditationtechniqueTableViewCell
        let mainDta = self.meditationTechniqueArray[indexPath.row] as NSDictionary
        if let title = mainDta.value(forKey: "title"){
            cell.titleLabel.text =  title as? String
           // print(title)
        }
        cell.techniqueNumberLabel.text = String(indexPath.row + 1)
       return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainDta = self.meditationTechniqueArray[indexPath.row] as NSDictionary
        let vc = storyboard?.instantiateViewController(withIdentifier:  "MeditationTechniqueDiscriptionViewController") as! MeditationTechniqueDiscriptionViewController
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
extension MeditationTechniqueViewController {
    func getAllMeditationTechnique(_ searchText: String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_SHOWMEDITATIONS)
       // print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":searchText,"limit":10000,"offset":0])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                   // print("News_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.meditationTechniqueArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.meditationTechniqueArray.count > 0 {
                        DispatchQueue.main.async() {
                            self.meditationTechniqueTableView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.meditationTechniqueTableView!.isHidden = false
                        }
                    } else {
                        //self.view.bringSubview(toFront: self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No Meditation techniques available"
                        self.meditationTechniqueTableView!.isHidden = true
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

extension MeditationTechniqueViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.getAllMeditationTechnique(searchText)
    }
}

class meditationtechniqueTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var techniqueNumberLabel: UILabel!
}
