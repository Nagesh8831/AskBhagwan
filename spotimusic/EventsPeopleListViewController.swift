//
//  EventsPeopleListViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 29/06/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import  SCLAlertView
class EventsPeopleListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var peopleListTableView: UITableView!
    var eventId = ""
    var allUserEventId: NSArray!
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("eventId",eventId)
        super.viewDidLoad()
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            
            self.checkUserLogin()
            
        } else {
        }
    }
    override func viewWillAppear(_ animated: Bool) {
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
    func checkUserLogin(){
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            users = results as! [NSManagedObject]
            
            if results.count == 0 {
                
                let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginTableViewController
                 loginVC.modalTransitionStyle = .crossDissolve
                 //loginVC.modalTransitionStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
                
            } else {
                
                if let idss = users[0].value(forKey: "user_id") {
                    GLOBAL_USER_ID = idss as! NSNumber
                }
                self.getAllUserByEventId()
            }
            
        } catch {
            
            print("Fetch Failed")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getAllUserByEventId(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_USER_BY_EVENT_ID + eventId )
        
        print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print("ALLUSERBYEvent_ID",response)
                switch response.result {
                case .success:
                    
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    guard let evn = itemss.value(forKey: "resultObject")
                        else {
                            self.view.bringSubviewToFront(self.noDataLabel)
                            self.noDataLabel.isHidden = false
                            self.noDataLabel.text = "No people found"
                            self.peopleListTableView!.isHidden = true
                            
                            return
                    }
                    self.allUserEventId =  evn as! NSArray
                    if self.allUserEventId.count > 0  {
                        print("Array_response",self.allUserEventId)
                        DispatchQueue.main.async() {
                        }
                        self.peopleListTableView!.reloadData()
                        self.noDataLabel.isHidden = true
                        self.peopleListTableView!.isHidden = false
                    }else {
                        
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No people found"
                        self.peopleListTableView!.isHidden = true
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((allUserEventId) != nil)  {
            return self.allUserEventId.count
            
        } else {
            
            // self.checkUserLogin()
            
            //reachabilitysz = Reachability()
            do {
                reachabilitysz = try Reachability()
            }catch{
                
            }
            if (reachabilitysz?.isReachable)!{
                
                self.checkUserLogin()
                
            } else {
            }
            
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleListCell", for: indexPath) as! EventsPeopleListTableViewCell
        let mainDta = self.allUserEventId[indexPath.row] as! NSDictionary
        
        let name = mainDta.value(forKey: "username") as? String
        let eventName = mainDta.value(forKey: "name") as? String
        
        
        DispatchQueue.main.async(execute: {
            cell.peopleNameLabel.text = name
            cell.eventNameLabel.text = eventName
        })
        
        let imageUrl = mainDta.value(forKey: "profile_photo") as? String
        
        if imageUrl != "" {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,imageUrl!)
            
            print("imgeFileimgeFile",imgeFile)
            let url = URL(string: imgeFile)
            //print("imageurl",url)
            DispatchQueue.main.async(execute: {
                if imgeFile != "" {
                    if let _ = cell.peopleImageView {
                        cell.peopleImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        
                    } else {
                        cell.peopleImageView.image = UIImage(named: "os_ho.jpg")
                    }
                }else {
                    cell.peopleImageView.image = UIImage(named: "os_ho.jpg")
                }
            })
        } else {
            cell.peopleImageView.image = UIImage(named: "os_ho.jpg")
        }
        
        return cell
    }
    
    
    @IBAction func doneButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
