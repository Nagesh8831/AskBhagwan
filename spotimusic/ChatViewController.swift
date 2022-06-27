//
//  ChatViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 11/09/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
class ChatViewController: UIViewController {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    var communityId = ""
    var messagesArray = [[String : AnyObject]]()
    var chatArray: NSArray!
    var timer : Timer!
     var reachabilitysz: Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getAllCommentByCommunityId()
        print("communityId",communityId)
        messageTextField.delegate = self
       // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
        }
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
            
            SCLAlertView().showTitle("Internet not available" , subTitle: "Please try after sometime...", timeout: time, completeText: "Done", style:  .success)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
        
    }
    
    @objc func fetch() {
    self.getAllCommentByCommunityId()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllCommentByCommunityId() {
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_COMMUNITY_GET_ALL_COMMENT_POST + communityId + ADD_LIMIT)
        
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success:
                    
                    print("AllComments",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    guard let mes = itemss.value(forKey: "resultObject") else {return}
                    self.messagesArray =  mes as! [[String : AnyObject]]
                    self.chatTableView.reloadData()
                    let indexPath = IndexPath(row: self.messagesArray.count - 1, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    print("messagesArray",self.messagesArray.count)
                    if self.messagesArray.count > 0 {
                        DispatchQueue.main.async() {
                            self.chatTableView!.reloadData()
                             self.noDataLabel.isHidden = true
                            self.chatTableView!.isHidden = false
                        }
                    }else {
                        self.noDataLabel.isHidden = false
                        self.chatTableView!.isHidden = true
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
    
    
    
    func postComment(message: String){
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_COMMUNITY_COMMENT_POST)
        if let id = GLOBAL_USER_ID {
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"user_id" : id.stringValue,"community_id":communityId,"comment":message])
                       .responseJSON { response in
                           SVProgressHUD.dismiss()
                           switch response.result {
                           case .success:
                               
                               print("Comments",response)
                               self.getAllCommentByCommunityId()
                               self.chatTableView.reloadData()
                               
                               self.messageTextField.text = ""
                               guard let itms = response.result.value else {return}
                               
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

    @IBAction func sendButtonAction(_ sender: Any) {
        let str = messageTextField.text
        let trimmed = str?.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageTextField.text != "" && trimmed != "" {
            postComment(message:messageTextField.text ?? "")
        } else {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("Please enter message", subTitle: "", timeout: time, completeText: "Done", style: .success)
        }
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
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var messageCell: ChatTableViewCell?
        var mainData = NSDictionary()
        mainData = self.messagesArray[indexPath.row] as! NSDictionary
        let comment = mainData.value(forKey: "comment") as? String
        let user_id = mainData.value(forKey: "user_id") as? String
        let name = mainData.value(forKey: "username") as? String
        let imageUrl = mainData.value(forKey: "profile_photo") as? String

        if let id = GLOBAL_USER_ID {
            if user_id == id.stringValue {
                        messageCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? ChatTableViewCell
                   }else {
                   messageCell = tableView.dequeueReusableCell(withIdentifier: "FromMessageCell", for: indexPath) as? ChatTableViewCell
                           messageCell?.userNameLabel.text = name
                           
                           
                           if imageUrl == "none"{
                               messageCell?.userImageView.image = UIImage(named: "os_ho.jpg")
                           }
                           let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,imageUrl!)
                           print("imagePath",imgeFile)
                           let url = URL(string: imgeFile)
                           
                           DispatchQueue.main.async(execute: {
                               if let _ = messageCell?.userImageView {
                                   messageCell?.userImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                               }
                           })
                           
                   }
        }
           
        
        messageCell?.messageLabel.text = comment
        return messageCell!
    }
}
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
