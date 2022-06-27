//
//  LanguagePopViewController.swift
//  spotimusic
//
//  Created by Mac on 24/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
protocol languageDelegate {
    func languageSelect(_ album_Id : String,album_Name: String)
}

class LanguagePopViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var languageTableView: UITableView!
    var reachabilitysz: Reachability!
    @IBOutlet var hideView: UIView!
    var languagesArray = [[String : AnyObject]]()
    var langDelegate : languageDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
      //  reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAlllanguage()
    }
    
    func getAlllanguage() {
            SVProgressHUD.show()
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES_LANGUAGE)
            //  print(urlResponce)
            Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success:
                        
                        //print("Discource_response",response)
                        guard let itms = response.result.value else {return}
                        let itemss = itms as! NSDictionary
                        self.languagesArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                        
                        // print("Array_response",self.languageAudioArray)
                        DispatchQueue.main.async() {
                            self.languageTableView!.reloadData()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if categoty == "Audio" {
//            return languageAudioArray.count
//        } else {
//            return languageVideoArray.count
//        }
        return languagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath) as! LanguageTableViewCell
       // if categoty == "Audio" {
            let mainDta = self.languagesArray[indexPath.row] as NSDictionary
            let name = mainDta.value(forKey: "name") as? String
            cell.languageNameLabel.text = name
        
//        } else {
//            let mainDta = self.languageVideoArray[indexPath.row] as NSDictionary
//            let name = mainDta.value(forKey: "name") as? String
//            cell.languageNameLabel.text = name
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let  mainData = self.languagesArray[indexPath.row]
            let albumId = mainData["id"] as? String
            let albumName = mainData["name"] as? String
            UserDefaults.standard.set(albumId, forKey: "defaultLanguageId")
            UserDefaults.standard.set(albumName, forKey: "defaultLanguageName")
            self.langDelegate?.languageSelect(albumId!, album_Name: albumName!)

        dismiss(animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
/*{
 if categoty == "Audio" {
 SVProgressHUD.show()
 SVProgressHUD.setForegroundColor(UIColor.white)
 SVProgressHUD.setBackgroundColor(UIColor.clear)
 let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES_LANGUAGE)
 //  print(urlResponce)
 Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
 .responseJSON { response in
 SVProgressHUD.dismiss()
 
 switch response.result {
 case .success:
 
 //print("Discource_response",response)
 guard let itms = response.result.value else {return}
 let itemss = itms as! NSDictionary
 self.languageAudioArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
 
 // print("Array_response",self.languageAudioArray)
 DispatchQueue.main.async() {
 self.languageTableView!.reloadData()
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
 
 } else {
 SVProgressHUD.show()
 SVProgressHUD.setForegroundColor(UIColor.white)
 SVProgressHUD.setBackgroundColor(UIColor.clear)
 let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_VIDEO_QA_DISCOURSES_LANGUAGE)
 // print(urlResponce)
 Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
 .responseJSON { response in
 SVProgressHUD.dismiss()
 switch response.result {
 case .success:
 guard let itms = response.result.value else {return}
 let itemss = itms as! NSDictionary
 self.languageVideoArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
 
 // print("Array_response",self.languageVideoArray)
 DispatchQueue.main.async() {
 self.languageTableView!.reloadData()
 }
 
 case .failure(let error):
 print(error)
 let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
 DispatchQueue.main.async {
 self.present(alert, animated: true, completion: nil)
 }
 }
 // print("Discource_response",response)
 }
 }
 }*/
