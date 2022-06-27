//
//  EventsViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 22/06/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import  SCLAlertView
let SHORT_DATE_FORMAT = "dd-MMM-YYYY"
let DDMMMYYYYFORMAT = "dd MMM yyyy"
let TIME_FORMAT = "hh:mm a"
let SHORT_DATE_TIME_FORMAT = "dd/MM/yy h:mm a"
let SHORTEST_DATE_FORMAT = "d MMM"

class EventsViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    var users = [NSManagedObject]()
    var userId : UserData!
    var reachabilitysz: Reachability!
    var eventsArray = [[String:AnyObject]]()
    var allUserEventId: NSArray!
    var eventId : String?
    var subscriptionStatus  = false
    var updateEventId : String?
    var updateEventName : String?
    var updateEventAddress : String?
    var updateEventFromDate : String?
    var updateEventToDate : String?
    var updateEventImage : String?
    var update_EventWebsiteLink : String?
    var isUpdate = false
    var items = [[String:AnyObject]]()
    var webLinkStr = ""
    var refreshControl: UIRefreshControl!
    var adsTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        let nib = UINib.init(nibName: "EventsTableViewCell", bundle: nil)
        self.eventsTableView.register(nib, forCellReuseIdentifier: "eventsCell")
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self,
                                      action: #selector(CategorywiseSearchVideoAudioViewController.pullToRefreshHandler),
                                      for: .valueChanged)
        
        self.eventsTableView.addSubview(self.refreshControl)
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        //print(reachabilitysz.currentReachabilityStatus, reachabilitysz.isReachable)
       // reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        
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
        self.title = "Events"
    }

    @objc func pullToRefreshHandler() {
        self.eventsTableView.reloadData()
        self.refreshControl.endRefreshing()
        // refresh table view data here
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
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
        self.checkUserLogin()
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    @objc func callBack(){
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showAdds()
            //IronSource.showRewardedVideo(with: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
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
                self.getAllEventsByUserId()
            }
            
        } catch {
            
            print("Fetch Failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getAllEventsByUserId(){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        self.items.removeAll()
        self.eventsTableView.reloadData()
        if  let userId = GLOBAL_USER_ID {
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_EVENT_BY_USERID + userId.stringValue )
            
            //print(urlResponce)
            Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                          print("Event_response",response)
                        
                        SVProgressHUD.dismiss()
                        guard let itms = response.result.value else {return}
                        let itemss = itms as! NSDictionary
                        let status = itemss.value(forKey: "status") as! Bool
                        if status {
                            self.noDataLabel.isHidden = true
                            self.eventsTableView.isHidden = false
                            self.eventsArray = itemss.value(forKey: "userobject") as! [[String:AnyObject]]
                            print("Event_response",self.eventsArray)
                            if let data = self.eventsArray as? [[String:AnyObject]] {
                                for i in (0..<data.count){
                                    if let dict = data[i] as? [String:AnyObject] , let id1 = dict["user_id"] as? String ,  userId.stringValue == id1  {
                                        if let action = dict["is_banned"] as? String , action == "1"  {
                                            self.items.append(dict)
                                        }
                                    } else {
                                        if let dict = data[i] as? [String:AnyObject] , let action = dict["is_banned"] as? String , action == "0" {
                                            self.items.append(dict)
                                        }
                                    }
                                }
                            }
                        }else{
                            print("no events")
                            SVProgressHUD.dismiss()
                            self.noDataLabel.isHidden = false
                            self.eventsTableView.isHidden = true
                        }

                        DispatchQueue.main.async() {
                            self.eventsTableView!.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((items) != nil)  {
            
            // print(eventsArray.count)
            return self.items.count
            
        } else {
          //  reachabilitysz = Reachability()
            do {
                reachabilitysz = try Reachability()
            }catch{
            }
            if (reachabilitysz?.isReachable)!{
               // self.checkUserLogin()
            } else {
            }
            
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventsTableViewCell
        //cell.layer.borderWidth = 2.0
        cell.willAttendButton.tag = indexPath.row
        cell.peopleListButton.tag = indexPath.row
        cell.updateEventButton.tag = indexPath.row
        cell.eventImageView.layer.borderColor = UIColor.gray.cgColor
        cell.eventImageView.layer.borderWidth = 1.0
        let mainDta = self.items[indexPath.row] as! NSDictionary
        
            eventId = mainDta.value(forKey: "id") as? String
            let name = mainDta.value(forKey: "name") as? String
            let address = mainDta.value(forKey: "address") as? String
            let weblink = mainDta.value(forKey: "website_link") as? String
        webLinkStr = weblink!
        if weblink == ""{
            cell.imageWebsiteLinkButton.isHidden = true
           // cell.websiteLinkLabel.text = "Not provided"
            //cell.websiteLinkButton.isHidden = true
        }else {
         //  cell.websiteLinkLabel.text =  weblink
            //cell.websiteLinkButton.isHidden = false
            cell.imageWebsiteLinkButton.isHidden = false
            cell.imageWebsiteLinkButton.tag = indexPath.row
            cell.imageWebsiteLinkButton.addTarget(self, action: #selector(openWebSite), for:.touchUpInside)
          //  cell.websiteLinkButton.tag = indexPath.row
           // cell.websiteLinkButton.addTarget(self, action: #selector(openWebSite), for:.touchUpInside)
        }
        if   let parentUserId = GLOBAL_USER_ID {
         
            let userID = mainDta.value(forKey: "user_id") as? String
            if let user_id = mainDta.value(forKey: "user_id") as? String , user_id == parentUserId.stringValue {
                cell.updateEventButton.isHidden = false
            } else {
                cell.updateEventButton.isHidden = true
            }
            if let like = mainDta.value(forKey: "like") as? Int , like == 1 {
                cell.willAttendButton.setTitle("Attending Event", for: .normal)
            } else {
                cell.willAttendButton.setTitle("will attend", for: .normal)
            }
            
            if let from_date = mainDta.value(forKey: "from_date") as? String {
                cell.startDateLabel.text = "Start:\(from_date.stringFromUTCDate(format: SHORT_DATE_FORMAT))"
            }
            
            if let to_date = mainDta.value(forKey: "to_date") as? String {
                cell.endDateLabel.text = "End:\(to_date.stringFromUTCDate(format: SHORT_DATE_FORMAT))"
            }
            
            
            if let is_banned = mainDta.value(forKey: "is_banned") as? String , is_banned == "1" &&  userID == parentUserId.stringValue {
                cell.willAttendButton.isHidden = true
                cell.peopleListButton.isHidden = true
                cell.eventShareButton.isHidden = true
                cell.firstView.isHidden = true
                cell.secondView.isHidden = true
                cell.approvalPendingLabel.isHidden = false
            } else {
                cell.willAttendButton.isHidden = false
                cell.peopleListButton.isHidden = false
                cell.eventShareButton.isHidden = false
                cell.firstView.isHidden = false
                cell.secondView.isHidden = false
                cell.approvalPendingLabel.isHidden = true
            }
        }
            let imageUrl = mainDta.value(forKey: "image") as? String
            
            if imageUrl != "" {
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,EVENTS,imageUrl!)
                let url = URL(string: imgeFile)
                DispatchQueue.main.async(execute: {
                    cell.eventNameLabel.text = name
                    cell.eventAddressLabel.text = address
                    if imgeFile != "" {
                        if let _ = cell.eventImageView {
                            cell.eventImageView.kf.setImage(with: url, placeholder: UIImage(named: "event"))
                        } else {
                            cell.eventImageView.image = UIImage(named: "event")
                        }
                    }else {
                        cell.eventImageView.image = UIImage(named: "event")
                    }
                })
            } else {
                cell.eventImageView.image = UIImage(named: "event")
            }
            
            cell.eventImageView.tag = indexPath.row
            
            cell.peopleListButton.addTarget(self, action: #selector(peopleList), for:.touchUpInside)
            cell.willAttendButton.addTarget(self, action: #selector(willAttendEvent), for: .touchUpInside)
            cell.updateEventButton.addTarget(self, action: #selector(updateEvent), for: .touchUpInside)
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector (imageTapped))
            cell.eventShareButton.tag = indexPath.row
            cell.eventShareButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            cell.eventImageView.addGestureRecognizer(tapGesture)
            cell.eventImageView.isUserInteractionEnabled = true
    
        return cell
    }
    
   @objc func imageTapped(gesture: UIGestureRecognizer) {
    let imageView = gesture.view as! UIImageView
    let newImageView = UIImageView(image: imageView.image)
    newImageView.frame = UIScreen.main.bounds
    newImageView.backgroundColor = .black
    newImageView.contentMode = .scaleAspectFit
    newImageView.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
    newImageView.addGestureRecognizer(tap)
    self.view.addSubview(newImageView)
    self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    @objc func peopleList(sender : UIButton){
        // print(sender.tag)
        let mainDta = self.items[sender.tag] as NSDictionary
        eventId = mainDta.value(forKey: "id") as? String
        self.performSegue(withIdentifier: "event_to_peoplelist", sender: self)
    }
    @objc func openWebSite(sender : UIButton){
        // print(sender.tag)
        let mainDta = self.items[sender.tag] as NSDictionary
       let weblink = mainDta.value(forKey: "website_link") as? String
        if let url = URL(string: weblink!){
            UIApplication.shared.open(url)
        }
    }
    
    
    @objc func updateEvent(sender : UIButton) {
        let mainDta = self.items[sender.tag] as NSDictionary
        isUpdate = true
        updateEventId = mainDta.value(forKey: "id") as? String
        updateEventName = mainDta.value(forKey: "name") as? String
        updateEventAddress = mainDta.value(forKey: "address") as? String
        updateEventFromDate = mainDta.value(forKey: "from_date") as? String
        updateEventToDate = mainDta.value(forKey: "to_date") as? String
        updateEventImage = mainDta.value(forKey: "image") as? String
        update_EventWebsiteLink = mainDta.value(forKey: "website_link") as? String
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddEventViewController") as! AddEventViewController
        
            vc.isUpdate = true
            vc.update_EventId = updateEventId
            vc.update_EventName = updateEventName
            vc.update_EventAddress = updateEventAddress
            vc.update_EventFromDate = updateEventFromDate
            vc.update_EventToDate = updateEventToDate
            vc.update_EventImage = updateEventImage
            vc.update_EventWebsiteLink = update_EventWebsiteLink
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func shareButton(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        var mainData = NSDictionary()
        mainData = self.items[sender.tag] as NSDictionary
        secondViewController.isShare = true
        secondViewController.trackId = (mainData.value(forKey: "id") as? String)!
        secondViewController.trackType = "6"
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    
    //func testAlert(){
    func eventPopup(title: String , message: String , posBtnTitle: String? , negBtnTitle: String? , eventId : String , willAttend : Bool) {
        let alert = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let addEvent = UIAlertAction(title: posBtnTitle, style: .default) { (_) -> Void in
            if willAttend {
                self.addEventUser(eventId)
            } else {
                self.removeEventUser(eventId)
            }
        }
        let cancleEvent = UIAlertAction(title: negBtnTitle, style: .cancel) { (_) -> Void in
        }
        
        // Accessing alert view backgroundColor :
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = GRAY_COLOR
        alert.view.tintColor = UIColor.white
        
        alert.addAction(addEvent)
        alert.addAction(cancleEvent)
        present(alert, animated: true, completion:  nil)
    }

    @objc func willAttendEvent(sender : UIButton){
        var eventId = ""
        if let id = eventsArray[sender.tag]["id"] as? String {
            eventId = id
        }

        if let like = eventsArray[sender.tag]["like"] as? Int , like == 0 {
            self.eventPopup(title: "The Bhagwan Event", message: "Are you sure you want to attend this event?", posBtnTitle: "Yes", negBtnTitle: "No", eventId: eventId, willAttend: true)
        } else {
            self.eventPopup(title: "The Bhagwan Event", message: "Are you sure you want to remove from this event?", posBtnTitle: "Yes", negBtnTitle: "No", eventId: eventId, willAttend: false)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "event_to_peoplelist" {
            let peopleList = segue.destination as? EventsPeopleListViewController
            peopleList?.eventId = self.eventId!
        }
        
    }
    
    @IBAction func addEventButtonAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddEventViewController") as! AddEventViewController
        
        if isUpdate == true {
            vc.update_EventId = updateEventId
            vc.update_EventName = updateEventName
            vc.update_EventAddress = updateEventAddress
            vc.update_EventFromDate = updateEventFromDate
            vc.update_EventToDate = updateEventToDate
            vc.update_EventWebsiteLink = update_EventWebsiteLink
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EventsViewController {
    func addEventUser (_ eventId : String) {
        var userId = ""
        if let id = UserDefaults.standard.value(forKey: "user_id") as? String {
            userId = id
        }
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "event_id": eventId,
            "user_id" : userId
        ]
       // print(parameter)
        APICall.addEventUser(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                weakSelf.getAllEventsByUserId()
            })
        }
    }

    func removeEventUser (_ eventId : String) {
        var userId = ""
        if let id = UserDefaults.standard.value(forKey: "user_id") as? String {
            userId = id
        }
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let parameter = [
            "event_id": eventId,
            "user_id" : userId
        ]
      //  print(parameter)
        APICall.removeEventUser(parameter as [String : AnyObject]) { [weak self] (data) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                weakSelf.getAllEventsByUserId()
            })
        }
    }
    
}
