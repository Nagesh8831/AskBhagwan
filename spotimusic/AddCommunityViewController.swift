//
//  AddCommunityViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 13/07/18.
//

import UIKit
import MobileCoreServices
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView

enum AttachentType: String {
    case image = "Image"
}
let MAX_IMAGE_UPLOAD_LIMIT = 5

class AddCommunityViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{


    @IBOutlet weak var communityNameTextField: UITextField!
    
    @IBOutlet weak var pitctureButton: UIButton!
    
    @IBOutlet weak var communityImageView: UIImageView!
    var reachabilitysz: Reachability!
    var update_CommunityId : String?
    var update_CommunityName : String?
    var update_CommunityImage : String?
    var isUpdate = false
    var attachmentType: AttachentType = .image
    var imageArray = [UIImage]()
    var photoimage: UIImage!
    var commImage: String?
    var albumPhoto = UIImagePickerController()
    var users = [NSManagedObject]()
    var userId : UserData!
    var user_Id = ""
    @IBOutlet weak var createButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("id",update_CommunityId)
        print("name",update_CommunityName)
        if isUpdate {
            communityNameTextField.text = update_CommunityName
            communityImageView.isHidden = false
            commImage = update_CommunityImage

            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,COMMUNITY,update_CommunityImage!)
            let url = URL(string: imgeFile)
            communityImageView.kf.setImage(with: url)
            createButton.setTitle("Update", for: .normal)
        } else {
            createButton.setTitle("Create", for: .normal)
        }
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
       // reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        pitctureButton.leftImage(image: UIImage(named: "camera")!, renderMode: .alwaysOriginal)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = UserDefaults.standard.value(forKey: "loginUserID") {
            user_Id = user as! String
            print(user_Id)
        }
        self.title = "Add community"
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
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    func chooseAlbum(){
        
        let alert = UIAlertController(title: "select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
        
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes	=   [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photoLibrary = UIAlertAction(title: "PhotoLibrary", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes    =   [kUTTypeImage as String]
                self.present(imagePicker, animated: true, completion: nil)
            }
        }

        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibrary)
        alert.addAction(cancleAction)
        present(alert, animated: true, completion: nil)

    }
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let pickedImage = info[.editedImage] as? UIImage {
           // info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.communityImageView.image = pickedImage
        }
        dismiss(animated: true, completion: {
            self.changez()
           
        })
    }
 
    func changez(){
        let url = URL(string:String(format: "%@%@", BASE_URL_BACKEND, ENDPOINT_UPLOAD_COMMUNITY_IMAGE))
      //  print("Updateurl",url)
        let goupload = ImageWebUpload()
        goupload.imageUploadRequest(image: self.communityImageView.image!, uploadUrl: url! as NSURL, param: ["X-API-KEY":API_GENERAL_KEY]) { (success) in
            if(success){
                let thisImage = goupload.urlimage
                self.commImage = thisImage
                print(self.commImage ?? "")
            }
        }
    }

    func addCommunity(communityName : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
       // let  userId = GLOBAL_USER_ID.string
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ADD_COMMUNITY)
            //print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"parent_user_id":user_Id,"name":communityName,"type": 1,"short_info": "Osho","long_info":"Osho","image_url": self.commImage ?? ""])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                         print("response",response)
                        guard let item = response.result.value as! NSDictionary? else {return}
                        if let message = item.value(forKey: "message") as? String {
                           self.alert("Add Community", subTitle: message)
                            self.navigationController?.popViewController(animated: true)
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

        //}
    }
    
    func updateCommunity(_ editImageUrl : String ,editCommunityName : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        if let  userId = GLOBAL_USER_ID {
            let urlResponce = String(format:  "%@%@",BASE_URL_BACKEND,ENDPOINT_UPDATE_COMMUNITY)
            
            print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"community_id":update_CommunityId!,"parent_user_id":userId.stringValue,"name":editCommunityName,"type": 1,"short_info":"Osho","long_info":"Osho","image_url": editImageUrl])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success :
                        print("response",response)
                        guard let item = response.result.value as! NSDictionary? else {return}
                        if let message = item.value(forKey: "message") as? String {
                            self.alert("Update Community", subTitle: message)
                            self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func pictureButtonAction(_ sender: Any) {
       self.chooseAlbum()
    }
    
    @IBAction func createButtonAction(_ sender: Any) {
            let trimeName = communityNameTextField.text
            let com_Name = trimeName?.trimmingCharacters(in: .whitespacesAndNewlines)
    
            if (communityNameTextField.text == "" || com_Name == ""){
                self.alert("Empty Name", subTitle: "Please Enter Community Name")
            } else if isUpdate {
                if let name = communityNameTextField.text, name != "" {
                    
                    self.updateCommunity(self.commImage!, editCommunityName: self.communityNameTextField.text!)
                }
            } else {
                if let name = communityNameTextField.text, name != "" {
                        self.addCommunity(communityName: self.communityNameTextField.text!)
                }
            }
    }
    
    func alert(_ title : String, subTitle: String) {
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
        }
        let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
        
        SCLAlertView().showTitle(title , subTitle: subTitle, timeout: time, completeText: "Done", style:  .success)
    }
    
    func alertUser(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
}
