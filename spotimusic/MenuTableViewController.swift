//
//  MenuTableViewController.swift
//  spotimusic
//
//  Created by appteve on 06/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import SWRevealViewController
import Reachability
import CoreData
import MessageUI
import SCLAlertView
class MenuTableViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playListView: UIView!
    @IBOutlet weak var blogArticleView: UIView!
    @IBOutlet weak var donateView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var productBookView: UIView!
    @IBOutlet weak var communityView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var meditationView: UIView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var interviewView: UIView!
    @IBOutlet weak var jokesView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var magazineView: UIView!
    @IBOutlet weak var shareAppView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var subscribeView: UIView!

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var jokesCell: UITableViewCell!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var homeCell: UITableViewCell!
    @IBOutlet weak var videoCell: UITableViewCell!
    @IBOutlet weak var oshoCenterCell: UITableViewCell!
    @IBOutlet weak var downloadCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var termsAndConditionsCell: UITableViewCell!
    @IBOutlet weak var audioCell: UITableViewCell!
    @IBOutlet weak var playlistCell: UITableViewCell!
    @IBOutlet weak var communityCell: UITableViewCell!
    @IBOutlet weak var eventsCell: UITableViewCell!
    @IBOutlet weak var meditationCell: UITableViewCell!
    @IBOutlet weak var musicCell: UITableViewCell!
    @IBOutlet weak var interviewCell: UITableViewCell!
    @IBOutlet weak var shareAppCell: UITableViewCell!
    @IBOutlet weak var contactUsCell: UITableViewCell!
    @IBOutlet weak var blogArticleCell: UITableViewCell!
    @IBOutlet weak var donateCell: UITableViewCell!
    @IBOutlet weak var productBookCell: UITableViewCell!
    @IBOutlet weak var instructionCell: UITableViewCell!
    @IBOutlet weak var onlineMagazineCell: UITableViewCell!
    @IBOutlet weak var headerCell: UITableViewCell!
    @IBOutlet weak var subscribeCell: UITableViewCell!
    var email : String?
    var appVersion : String?
    let effect = UIBlurEffect(style: .dark)
    var user = [NSManagedObject]()
    var showSubMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha:0.5)
        return view
    }()
    fileprivate let longLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "", size: 14)
        label.textAlignment = .left
        return label
    }()
    fileprivate let shorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "", size: 14)
        label.textAlignment = .left
        return label
    }()
    var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "thblack.jpg"))
        tableView.estimatedRowHeight = 54.0
        tableView.rowHeight = UITableView.automaticDimension
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.layer.borderWidth = 1.0
    }
    

    override func viewWillAppear(_ animated: Bool) {
         print("Load menu2")
        self.fetchUser()
        self.revealViewController().frontViewController.view .isUserInteractionEnabled = true
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchUser), name: Notification.Name("UserLoggedIn"), object: nil)
        //reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as? String
        versionLabel.text = "Version :" + " " + appVersion!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.revealViewController().frontViewController.view .isUserInteractionEnabled = true
    }
    func buildBlurView() -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 211
        }else {
            return 54
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
        homeView.backgroundColor = RED_COLOR
        }else if indexPath.row == 2 {
        audioView.backgroundColor = RED_COLOR
        }else if indexPath.row == 3 {
        videoView.backgroundColor = RED_COLOR
        }else if indexPath.row == 4 {
        playListView.backgroundColor = RED_COLOR
        }else if indexPath.row == 7 {
        downloadView.backgroundColor = RED_COLOR
        }else if indexPath.row == 8 {
        productBookView.backgroundColor = RED_COLOR
        }else if indexPath.row == 9 {
        communityView.backgroundColor = RED_COLOR
        }else if indexPath.row == 10 {
        eventView.backgroundColor = RED_COLOR
        }else if indexPath.row == 11 {
        meditationView.backgroundColor = RED_COLOR
        }else if indexPath.row == 13 {
        musicView.backgroundColor = RED_COLOR
        }else if indexPath.row == 15 {
        jokesView.backgroundColor = RED_COLOR
        }else if indexPath.row == 16 {
        centerView.backgroundColor = RED_COLOR
        }else if indexPath.row == 17 {
        magazineView.backgroundColor = RED_COLOR
        }else if indexPath.row == 19 {
        aboutView.backgroundColor = RED_COLOR
        }
        
        
        if indexPath.row == 5 {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
            blogArticleView.backgroundColor = RED_COLOR
        }
       /* if indexPath.row == 6 {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
           // donateView.backgroundColor = RED_COLOR
           /* let alert = UIAlertController(title: "Ask Bhagwan",message: "Please donate to support, improve & maintain this app.We want to spread Bhagwan’s work to every corner of the world for free.", preferredStyle: .alert)
            let addEvent = UIAlertAction(title: "Donate", style: .default) { (_) -> Void in
                print("Yes")
                if let url = URL(string: "https://www.askbhagwan.org/paynow/") {
                    UIApplication.shared.open(url)
                }
            }
            let cancleEvent = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                print("No")
            }
            alert.addAction(addEvent)
            alert.addAction(cancleEvent)
            present(alert, animated: true, completion:  nil)*/
            
            //"https://ask-osho.net/paynow/"
            //
        }*/
        if indexPath.row == 6 {
            subscribeView.backgroundColor = RED_COLOR
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomIntegrationViewController") as! CustomIntegrationViewController
//            vc.isFromMusicPlayer = false
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 12 {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MeditationTechniqueViewController") as! MeditationTechniqueViewController
            instructionView.backgroundColor = RED_COLOR
        }
        if indexPath.row == 14 {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "JokesViewController") as! JokesViewController
            VC.isFromMenu = true
            interviewView.backgroundColor = RED_COLOR
        }
        
        if indexPath.row == 18 {
            shareAppView.backgroundColor = RED_COLOR
//            let pth = "http://ask-osho.net/paynow/"
//            if let url = NSURL(string: pth){
//                UIApplication.shared.openURL(url as URL)
//            }
            
            let iOS = " Ask Bhagwan download app link : \n"
            let iOSLink = "http://onelink.to/dycekq"

            let appLink = [ iOS, iOSLink] as [Any]

            let activityVC = UIActivityViewController(activityItems: appLink, applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
    
        }
        if indexPath.row == 20 {
            contactView.backgroundColor = RED_COLOR
            self.showContactSupportInfo()
        }
        if indexPath.row == 21 {
            logoutView.backgroundColor = RED_COLOR
            let alert = UIAlertController(title: "Ask Bhagwan",message: "Are you sure you want to logout?", preferredStyle: .alert)
            let addEvent = UIAlertAction(title: "Logout", style: .default) { (_) -> Void in
                print("Yes")
                AudioPlayer.sharedAudioPlayer.pause()
                self.logout()
            }
            let cancleEvent = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                print("No")
            }
            alert.addAction(addEvent)
            alert.addAction(cancleEvent)
            present(alert, animated: true, completion:  nil)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if  homeView.backgroundColor == RED_COLOR ||
            audioView.backgroundColor == RED_COLOR ||
            videoView.backgroundColor == RED_COLOR ||
            playListView.backgroundColor == RED_COLOR ||
            blogArticleView.backgroundColor == RED_COLOR ||
           // donateView.backgroundColor == RED_COLOR ||
            downloadView.backgroundColor == RED_COLOR ||
            productBookView.backgroundColor == RED_COLOR ||
            communityView.backgroundColor == RED_COLOR ||
            eventView.backgroundColor == RED_COLOR ||
            meditationView.backgroundColor == RED_COLOR ||
            instructionView.backgroundColor == RED_COLOR ||
            musicView.backgroundColor == RED_COLOR ||
            interviewView.backgroundColor == RED_COLOR ||
            jokesView.backgroundColor == RED_COLOR ||
            centerView.backgroundColor == RED_COLOR  ||
            magazineView.backgroundColor == RED_COLOR ||
            shareAppView.backgroundColor == RED_COLOR ||
            aboutView.backgroundColor == RED_COLOR ||
            contactView.backgroundColor == RED_COLOR ||
            logoutView.backgroundColor == RED_COLOR ||
                subscribeView.backgroundColor == RED_COLOR{
             print("it is white")
            homeView.backgroundColor = .clear
            audioView.backgroundColor = .clear
            videoView.backgroundColor = .clear
            playListView.backgroundColor = .clear
            blogArticleView.backgroundColor = .clear
           // donateView.backgroundColor = .clear
            downloadView.backgroundColor = .clear
            productBookView.backgroundColor = .clear
            communityView.backgroundColor = .clear
            eventView.backgroundColor = .clear
            meditationView.backgroundColor = .clear
            instructionView.backgroundColor = .clear
            musicView.backgroundColor = .clear
            interviewView.backgroundColor = .clear
            jokesView.backgroundColor = .clear
            centerView.backgroundColor = .clear
            magazineView.backgroundColor = .clear
            shareAppView.backgroundColor = .clear
            aboutView.backgroundColor = .clear
            contactView.backgroundColor = .clear
            logoutView.backgroundColor = .clear
            subscribeView.backgroundColor = .clear
            }
//            else {
//                 println("I don't know :)");
//              }
//        if  let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath){
////        if  let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath) {
////            cellToDeSelect.contentView.backgroundColor = .clear
////        }
//
//                   if (indexPath.row == 0){
//                    if(selectedCell.isSelected){
//                        selectedCell.backgroundColor = UIColor.clear
//                       }
//                   }
//        if(selectedCell.isSelected){
//                    selectedCell.backgroundColor = RED_COLOR
//                   }else{
//            selectedCell.backgroundColor = UIColor.clear
//                   }
//        }
       }
    
    func showContactSupportInfo() {
            print("Rename button tapped")
            let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
                 self.showSendMailErrorAlert()
            }
        }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@askbhagwan.com"])
        mailComposerVC.setSubject("ASK Bhagwan SUPPORT")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
        }))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Meditation") {
            UserDefaults.standard.set("Meditation", forKey: "category")
            UserDefaults.standard.set(false, forKey: "isFromDrawer")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Music") {
            UserDefaults.standard.set("Music", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Interview") {
            UserDefaults.standard.set("Interview", forKey: "category")
            UserDefaults.standard.set(false, forKey: "isFromDrawer")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Audio"){
            UserDefaults.standard.set("Audio", forKey: "category")
            UserDefaults.standard.set(false, forKey: "isFromDrawer")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Video"){
            UserDefaults.standard.set("Video", forKey: "category")
            UserDefaults.standard.set(false, forKey: "isFromDrawer")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Home"){
            UserDefaults.standard.set("Home", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Download"){
            UserDefaults.standard.set("Download", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "PlayList"){
            UserDefaults.standard.set("PlayList", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Event"){
            UserDefaults.standard.set("Event", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "OshoCenter"){
            UserDefaults.standard.set("OshoCenters", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "termAndCondition"){
            UserDefaults.standard.set("termAndCondition", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Profile"){
            UserDefaults.standard.set("Profile", forKey: "category")
            UserDefaults.standard.set(true, forKey: "isFromMenu")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Community"){
            UserDefaults.standard.set("Community", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "ContactUs"){
            UserDefaults.standard.set("ContactUs", forKey: "category")
            UserDefaults.standard.synchronize()
        } else if (segue.identifier == "Jokes"){
            UserDefaults.standard.set("Jokes", forKey: "category")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "HowToUse"){
            UserDefaults.standard.set("HowToUse", forKey: "HowToUse")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "InAppPurchase"){
            UserDefaults.standard.set("InAppPurchase", forKey: "InAppPurchase")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Blog"){
            UserDefaults.standard.set("Blog", forKey: "Blog")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Instruct"){
            UserDefaults.standard.set("Instruct", forKey: "Instruct")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "Magazine"){
            UserDefaults.standard.set("Magazine", forKey: "Magazine")
            UserDefaults.standard.synchronize()
        }else if (segue.identifier == "subscribe"){
            UserDefaults.standard.set("subscribe", forKey: "Subscribe")
            UserDefaults.standard.synchronize()
        }
    }
    @objc func fetchUser(){
        let find = GetInfoUser()
        if GLOBAL_USER_ID != nil {
            find.getResponseUser(String(describing: GLOBAL_USER_ID.stringValue)) {(isResponse) -> Void in
                print("isResponse",isResponse)
                if let name = isResponse.value(forKey: "username") as! String? {
                    
                    if name == "" {
                        self.userName.text =  "User Name"
                    }else {
                        self.userName.text =  name
                    }
                }
                if let emailId = isResponse.value(forKey: "email") as! String? {
                    self.email = emailId
                }
                
                let imageUrl = isResponse.value(forKey: "profile_photo") as? String
                
                if imageUrl == "none"{
                    self.profileImageView.image = UIImage(named: "os_ho.jpg")
                }
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,imageUrl!)
                print("imagePath",imgeFile)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = self.profileImageView {
                        self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                })
            }

        } else {
            
        }
    }
    @IBAction func logout(){
        
         UserDAO.clearDefaultUser()
         UserDefaults.standard.removeObject(forKey: "UserLoggedIn")
         UserDefaults.standard.removeObject(forKey: "stateName")
         UserDefaults.standard.removeObject(forKey: "countryName")
        UserDefaults.standard.removeObject(forKey: "isPurchased")
        UserDefaults.standard.removeObject(forKey: "loginUserID")
        UserDefaults.standard.removeObject(forKey: "isCountryPopUpShown")
       // self._stk_audioPlayer.stop()   
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        GLOBAL_USER_ID = nil
       // print(GLOBAL_USER_ID)
        do {
            let results = try context.fetch(request)
           let user = results as! [NSManagedObject]
            if results.count == 0 {
            } else {
                context.delete(user[0])
                print(user)
                print(context)
                do {
                    try context.save()
                } catch _ {
                }
                
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginTableViewController
                //loginVC.modalTransitionStyle = .coverVertical
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        } catch {
            print("Fetch Failed")
        }
    }
}
