//
//  CountryStateViewController.swift
//  spotimusic
//
//  Created by BQ_08 on 7/23/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
class CountryStateViewController: BaseViewController {
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var stateTableView: UITableView!
    var subscriptionStatus  = false

    @IBOutlet weak var cancelButton: UIButton!
    var reachabilitysz: Reachability!
    var stateArray = [[String:AnyObject]]()
    var countryArray = [[String:AnyObject]]()
    var isCountry = false
    var isSignUp = false
    var isSignUpCountry = false
    
    var isProfile = false
    var isProfileCountry = false
    var countryId = ""
    
    @IBOutlet weak var cancelButtonHight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        if isSignUp {
            
        } else if isProfile {
            
        } else {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            cancelButton.isHidden = true
            cancelButtonHight.constant = 0
            navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            self.navigationController!.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            self.navigationController?.navigationBar.tintColor = UIColor.white
            
            //        categoty = UserDefaults.standard.value(forKey: "category") as? String
            self.title = "Meditation Centers"
            getAllCountry()
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
        if isSignUp {
            if isSignUpCountry {
                getAllCountry()
            } else{
                getAllStateByCountryId(countryId)
            }
        } else if isProfile {
            if isProfileCountry {
                getAllCountry()
            } else{
                getAllStateByCountryId(countryId)
            }
        } else {
        getAllCountry()
        }
        Timer.scheduledTimer(timeInterval:300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
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
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }

  @objc func back(){
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
                switch response.result {
                case .success:
                    guard let json = response.result.value else {return}
                    let JSON = json as! NSDictionary
                    
                    let result = JSON.value(forKey: "resultObject") as! [[String:AnyObject]]
                    if result.count > 0 {
                        self.countryArray = result
                        self.stateTableView.reloadData()
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
                    weakSelf.stateTableView.reloadData()
                }
            })
        }

    }

}

extension CountryStateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSignUp {
            if isSignUpCountry {
                return countryArray.count
            } else{
                return stateArray.count
            }
        } else if isProfile {
            if isProfileCountry {
                return countryArray.count
            } else{
                return stateArray.count
            }
        }else {
        return countryArray.count
        
    }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stateTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.textColor = UIColor.white
        if isSignUp {
            if isSignUpCountry {
                if let name = countryArray[indexPath.row]["name"] as? String {
                    
                    cell.textLabel?.text = name
                }
            } else {
                if let name = stateArray[indexPath.row]["name"] as? String {
                    cell.textLabel?.text = name
                }
            }
        }else if isProfile {
            if isProfileCountry {
                if let name = countryArray[indexPath.row]["name"] as? String {
                    
                    cell.textLabel?.text = name
                }
            } else {
                if let name = stateArray[indexPath.row]["name"] as? String {
                    cell.textLabel?.text = name
                }
            }
        }else {
        
        if let name = countryArray[indexPath.row]["name"] as? String {

            cell.textLabel?.text = name
        }
        
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(false, forKey: "isFromMenu")
        UserDefaults.standard.synchronize()
        if isSignUp {
            if isSignUpCountry {
            if let id = countryArray[indexPath.row]["id"] as? String , let name = countryArray[indexPath.row]["name"] as? String {
                UserDefaults.standard.set(id, forKey: "countryId")
                UserDefaults.standard.set(name, forKey: "countryName")
                UserDefaults.standard.set("", forKey: "stateId")
                UserDefaults.standard.set("", forKey: "stateName")
            }
                            } else {
                if let id = stateArray[indexPath.row]["id"] as? String , let name = stateArray[indexPath.row]["name"] as? String {
                    UserDefaults.standard.set(id, forKey: "stateId")
                    UserDefaults.standard.set(name, forKey: "stateName")
                }
            }
           self.dismiss(animated: false, completion: nil)
        } else if isProfile {
            if isProfileCountry {
                if let id = countryArray[indexPath.row]["id"] as? String , let name = countryArray[indexPath.row]["name"] as? String {
                    UserDefaults.standard.set(id, forKey: "coun_Id")
                    UserDefaults.standard.set(name, forKey: "coun_Name")
                    UserDefaults.standard.set("", forKey: "stat_Id")
                    UserDefaults.standard.set("", forKey: "stat_Name")
                }
                
            } else {
                if let id = stateArray[indexPath.row]["id"] as? String , let name = stateArray[indexPath.row]["name"] as? String {
                    UserDefaults.standard.set(id, forKey: "stat_Id")
                    UserDefaults.standard.set(name, forKey: "stat_Name")
                }
            }
            self.dismiss(animated: false, completion: nil)
        }else {
        
        isCountry = true
        if let id = countryArray[indexPath.row]["id"] as? String {
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "StateViewController") as! StateViewController
                secondViewController.countryId = id
                self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        }
    }
}
