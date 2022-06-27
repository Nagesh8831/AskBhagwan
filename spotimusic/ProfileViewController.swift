//
//  ProfileViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 31/07/18.
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

enum Attachent_Type: String {
    case image = "Image"
}
class ProfileViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var state_TextField: UITextField!
    @IBOutlet weak var country_TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var sanyasNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var profileImgeView: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var menuBtn :UIBarButtonItem!
    @IBOutlet weak var pickedProfileImgeView: UIImageView!
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    let imagePicker = UIImagePickerController()
    var updateCity : String?
    var updateCountryId : String?
    var updateStateId : String?
    var sanyasName : String?
    var phone : String?
    var countyId : String?
    var stateId : String?
    var albumPhoto = UIImagePickerController()
    var photoimage: UIImage!
    var proImage: String!
    var isFromImageUpload = Bool()
    var attachmentType: Attachent_Type = .image
    var reachabilitysz: Reachability!
    var country_ID : String?
    var state_ID : String?
    var user_name : String?
    var user_email : String?
    var ph_no : String?
    var cities : String?
    var userID = ""
    var isState = false
    var isCountry = false
    var stateArray = [[String:AnyObject]]()
    var countryArray = [[String:AnyObject]]()
    var cId = ""
    var sId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        self.mobileNumberTextField.delegate = self
        self.country_TextField.delegate = self
        self.state_TextField.delegate = self
        //eachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()
        } else {
            let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isFromMenu") {
            self.fetchUser()
        }else {
            if let name = UserDefaults.standard.value(forKey: "coun_Name") as? String {
                
                self.country_TextField.text = name
            }
            if let name = UserDefaults.standard.value(forKey: "stat_Name") as? String {
                self.state_TextField.text = name
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        getAllCountry()
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
        self.title = "profile"
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
        
        if #available(iOS 10.0, *) {
            mobileNumberTextField.keyboardType = .asciiCapableNumberPad
        } else {
            mobileNumberTextField.keyboardType = .numberPad
        }
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapDetected))
        profileImgeView.isUserInteractionEnabled = true
        profileImgeView.addGestureRecognizer(singleTap)
        if  self.isFromImageUpload {
            self.isFromImageUpload = false
            self.changez()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    func createPickerView() {
           pickerView.delegate = self
        pickerView.backgroundColor = UIColor.black
        pickerView.tintColor = UIColor.white
        toolbar.backgroundColor = UIColor.black
        toolbar.tintColor = UIColor.white
         pickerView.setValue(UIColor.white, forKey: "textColor")
           toolbar.sizeToFit()
           let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(action));
           toolbar.setItems([doneButton], animated: true)
           toolbar.isUserInteractionEnabled = true
       }
    @objc func action() {
        view.endEditing(true)
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
    
    @objc func tapDetected() {
        print("Imageview Clicked")
        self.chooseAlbum()
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        self.chooseAlbum()
    }
    
    func chooseAlbum(){
        let alert = UIAlertController(title: "select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.imagePicker.delegate = self
                
               self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.mediaTypes    =   [kUTTypeImage as String]
                self.present(self.imagePicker, animated: true, completion: nil)
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
        DispatchQueue.main.async(execute: {
            if let pickedImage = info[.originalImage] as? UIImage {
                
                self.profileImgeView.image = pickedImage
                self.isFromImageUpload = true
            }else {
                self.chooseAlbum()
            }
            self.dismiss(animated: false, completion: {
                
            })
        })
    }
    
    func changez(){
        let url = URL(string:String(format: "%@%@", BASE_URL_BACKEND, ENDPOINT_USER_UPLOAD))
          //print("Updateurl",url)
        let goupload = ImageWebUpload()
        goupload.imageUploadRequest(image: self.profileImgeView.image!, uploadUrl: url! as NSURL, param: ["X-API-KEY":API_GENERAL_KEY]) { (success) in
            
              print("success",success)
            if(success){
                if let thisImage = goupload.urlimage {
                    if let _ = self.proImage {
                       self.proImage = thisImage
                    }else {
                        self.proImage = String(thisImage)
                    }
                    self.proImage = thisImage
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mobileNumberTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 15
        } else if textField == userNameTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 24
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
   /* func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == state_TextField {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryStateViewController") as! CountryStateViewController
            vc.isProfile = true
            if let id = UserDefaults.standard.value(forKey: "coun_Id") as? String {
                vc.countryId = id
            }
            vc.isProfileCountry = false
            self.present(vc, animated: true, completion: nil)
            
        } else if textField == country_TextField  {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryStateViewController") as! CountryStateViewController
            vc.isProfile = true
            vc.isProfileCountry = true
            self.present(vc, animated: true, completion: nil)
        }
    }*/
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == state_TextField {
//            textField .resignFirstResponder()
//            }else if textField == country_TextField  {
//                textField .resignFirstResponder()
//            }
//        return true
//    }


    func updateProfile(_ imageUrl : String, user_Name: String , county_ID :String  ,State_ID : String ){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        if  let  userId = GLOBAL_USER_ID {
            userID = userId.stringValue
        }
        var parameters:[String: String] = ["X-API-KEY": API_GENERAL_KEY,"id":userID]
        
        parameters ["username"] =  user_Name
        parameters["country_id"] = cId
        parameters["state_id"] = sId
        if let city = cityTextField.text  {
            parameters["city"] = city
        }
        if let email = userEmailLabel.text {
            parameters["email"] = email
        }
        if let sanyas_name = self.sanyasName{
            parameters["sanyas_name"] = sanyas_name
        }
        if let phone_number = mobileNumberTextField.text {
            parameters["phone_number"] = phone_number
        }
        
        if let cName = UserDefaults.standard.value(forKey: "coun_Name") as? String {
            self.country_TextField.text = cName
        }
        if let stName = UserDefaults.standard.value(forKey: "stat_Name") as? String {
            self.state_TextField.text = stName
        }
        parameters["profile_photo"] = imageUrl
        print("parameters",parameters)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_USER_UPDATE)
        print(urlResponce)
        Alamofire.request(urlResponce,method: .post ,parameters: parameters)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print("Profileresponse",response)
                
                switch response.result {
                case .success:
                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                    }
                    let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                    SCLAlertView().showTitle("Update Profile", subTitle: "Successfully...", timeout: time, completeText: "Done", style: .success)
                    self.fetchUser()
                    self.navigationController?.popViewController(animated: true)
                    
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
   
    @IBAction func updateButonAction(_ sender: Any) {
        let trimeName = userNameTextField.text
        let userName = trimeName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimeMob = mobileNumberTextField.text
        let mob_no = trimeMob?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimeCity = mobileNumberTextField.text
        let cit = trimeCity?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.userNameTextField.text ==  ""  || userName == "" {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "enter user name", timeout: time, completeText: "Done", style: .success)
        }else if self.mobileNumberTextField.text ==  ""  || mob_no == "" || self.mobileNumberTextField.text!.count < 10 {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "enter valid mobile number", timeout: time, completeText: "Done", style: .success)
        }else if self.country_TextField.text ==  "" {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "enter country", timeout: time, completeText: "Done", style: .success)
        }else if self.state_TextField.text ==  ""  {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "enter state", timeout: time, completeText: "Done", style: .success)
        }else if self.cityTextField.text ==  ""  || cit == "" {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "enter city", timeout: time, completeText: "Done", style: .success)
        }else {
            
            
            if let cid = UserDefaults.standard.value(forKey: "coun_Id") as? String {
                self.country_TextField.text = cid
            }
            if let sid = UserDefaults.standard.value(forKey: "stat_Id") as? String {
                self.state_TextField.text = sid
            }
            
            if let img = self.proImage{
                self.updateProfile(img, user_Name: self.userNameTextField.text!, county_ID: self.country_TextField.text!, State_ID: self.state_TextField.text!)
                // self.updateProfile(img, user_Name: self.userNameTextField.text!)
            }
        }
    }
    
    func fetchUser(){
        let find = GetInfoUser()
        print("find",find)
        if GLOBAL_USER_ID != nil {
            find.getResponseUser(String(describing: GLOBAL_USER_ID.stringValue)) {(isResponse) -> Void in
                print("profileDetails",isResponse)
                
                
                guard let uemail = isResponse.value(forKey: "email") as! String? else {return}
                
                self.userEmailLabel.text = uemail
                if let uname = isResponse.value(forKey: "username") as! String? {
                    if uname == ""{
                        self.userNameTextField.attributedPlaceholder = NSAttributedString(string:"update username",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    }else {
                        self.userNameTextField.text = uname
                    }
                }
                
                if let umob = isResponse.value(forKey: "phone_number") as! String? {
                    if umob == ""{
                        self.mobileNumberTextField.attributedPlaceholder = NSAttributedString(string:"update mobile number",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    }else {
                        self.mobileNumberTextField.text = umob
                    }
                }
               
                
                if let ucountry = isResponse.value(forKey: "country_id") as! String? {
                    if ucountry == "0"{
                        self.country_TextField.attributedPlaceholder = NSAttributedString(string:"update country",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    }else {
                        self.cId = ucountry
                    }
                }
                
                if let ustate = isResponse.value(forKey: "state_id") as! String? {
                    if ustate == "0"{
                        self.state_TextField.attributedPlaceholder = NSAttributedString(string:"update state",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    }else {
                        self.sId = ustate
                    }
                    
                    
                }
                
                if let ucity = isResponse.value(forKey: "city") as! String? {
                    if ucity == ""{
                        self.cityTextField.attributedPlaceholder = NSAttributedString(string:"update city",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
                    }else {
                        self.cityTextField.text = ucity
                    }
                }
               guard let imageUrl = isResponse.value(forKey: "profile_photo") as? String else {return}
                self.proImage = imageUrl
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,USER_PROFILE,imageUrl)
                let url = URL(string: imgeFile)
                
                DispatchQueue.main.async(execute: {
                    if let _ = self.profileImgeView {
                        self.profileImgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }else {
                        self.profileImgeView.image = UIImage(named: "music")
                    }
                })
                
                self.getAllCountry()
                self.getAllStateByCountryId(self.cId ?? "")
            }
           
        }
        
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
         self.country_TextField.text = ""
        let result = JSON.value(forKey: "resultObject") as! [[String:AnyObject]]
        if result.count > 0 {
            self.countryArray = result
        }
        for obj in result {
            if let id = obj ["id"] as? String {
                if id == self.cId {
                    self.country_TextField.text = obj ["name"] as? String
                }
            }
        }
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
            guard let _ = self else { return }
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
                // print("data::::\(data)")
                if let result = data["resultObject"] as? [[String:AnyObject]] {
                    self?.state_TextField.text = ""
                    if result.count > 0 {
                        self?.stateArray = result
                    }
                    for obj in result {
                        if let id = obj ["id"] as? String {
                            if id == self?.sId {
                                self?.state_TextField.text = obj ["name"] as? String
                            }
                        }
                    }
                    
                    
                }
            })
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigationt
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProfileViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
             if isCountry {
                return countryArray.count
            }else  {
               return stateArray.count
            }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
            if isCountry {
                return countryArray[row] ["name"] as? String
            } else  {
              return stateArray[row]["name"] as? String
            }
        // dropdown item
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if isCountry {
                country_TextField.text = countryArray[row]["name"] as? String
                self.cId = countryArray[row] ["id"] as! String
                getAllStateByCountryId(self.cId)
                
            } else  {
            self.sId = stateArray[row] ["id"] as! String
            state_TextField.text = stateArray[row] ["name"] as? String
            }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
                    if textField == country_TextField {
                        country_TextField.inputView = pickerView
                        country_TextField.inputAccessoryView = toolbar
                        isCountry = true
                        isState = false
                        if country_TextField.text == "" {
                            state_TextField.isUserInteractionEnabled = false
                        }else {
                          state_TextField.isUserInteractionEnabled = true
                        }
                        createPickerView()
                    }else if textField == state_TextField {
                        state_TextField.inputView = pickerView
                        state_TextField.inputAccessoryView = toolbar
                       isCountry = false
                        isState = true
                        createPickerView()
                    }
                
            }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == country_TextField {
         if country_TextField.text == "" {
            state_TextField.isUserInteractionEnabled = false
            }else {
            state_TextField.isUserInteractionEnabled = true
            }
            }
    }
}
