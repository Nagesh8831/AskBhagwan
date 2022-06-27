//
//  StateViewController.swift
//  spotimusic
//
//  Created by SCISPLMAC on 18/09/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
class StateViewController: UIViewController {
    @IBOutlet weak var stateTableView: UITableView!
     var reachabilitysz: Reachability!
    var stateArray = [[String:AnyObject]]()
    var countryArray = [[String:AnyObject]]()
    var isCountry = false
    var isSignUp = false
    var isSignUpCountry = false
    var countryId = ""
    

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
        super.viewWillAppear(true)
        let trackInlist = UserDefaults.standard.bool(forKey: "isTrackInList")
        if trackInlist == true {
            if ((AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) == .playing){
                UserDefaults.standard.set(false, forKey: "isTrackInList")
                UserDefaults.standard.synchronize()
            }
        }else {
            if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
                getAllStateByCountryId(countryId)
           
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @ objc  func back(){
        self.dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func getAllCountry(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlReq = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_GET_ALL_COUNTRY)
        
        Alamofire.request( urlReq,method: .get, parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                
                SVProgressHUD.dismiss()
                guard let json = response.result.value else {return}
                let JSON = json as! NSDictionary
                let result = JSON.value(forKey: "resultObject") as! [[String:AnyObject]]
                if result.count > 0 {
                    self.countryArray = result
                    self.stateTableView.reloadData()
                }
        }
        
        
    }
    
    func getAllStateByCountryId(_ id:String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "id": id
        ]
        APICall.getAllStateByCountryId(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                // print("data::::\(data)")
                if let result = data["resultObject"] as? [[String:AnyObject]] {
                    weakSelf.stateArray = result
                    // print(weakSelf.stateArray)
                    weakSelf.stateTableView.reloadData()
                }
            })
        }
        
    }
    
}

extension StateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stateTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.textColor = UIColor.white
        
        
                if let name = stateArray[indexPath.row]["name"] as? String {
                    cell.textLabel?.text = name
                }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
                isCountry = false
                if let id = stateArray[indexPath.row]["id"] as? String, let name = stateArray[indexPath.row]["name"] as? String {
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "OshoCenterViewController") as! OshoCenterViewController
                    secondViewController.stateId = id
                    secondViewController.stateName = name
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            
        
    }
}

