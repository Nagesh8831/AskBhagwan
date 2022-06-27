//
//  RegistrationTableViewController.swift
//  spotimusic
//
//  Created by appteve on 16/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import CoreData
import SCLAlertView
import SWRevealViewController
import SVProgressHUD

class RegistrationTableViewController: UITableViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var sanyasNametextField: UITextField!
    
    @IBOutlet weak var citytextField: UITextField!
    let effect = UIBlurEffect(style: .extraLight)
    var albumPhoto = UIImagePickerController()
    var photoimage: UIImage!
    var regImage: String!
    var isFromImageUpload = Bool()
    var successMessage = ""
    @IBOutlet weak var pickedProfileImgeView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.attributedPlaceholder = NSAttributedString(string:"Name",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        userPassword.attributedPlaceholder = NSAttributedString(string:"Your password",
                                                                attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        userMail.attributedPlaceholder = NSAttributedString(string:"Your email",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        sanyasNametextField.attributedPlaceholder = NSAttributedString(string:"Sanyas Name (Optional)",
                                                                       attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])

        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string:"Contact number (Optional)",
                                                                        attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
//        //countryTextField.attributedPlaceholder = NSAttributedString(string:"Country",
//                                                                 attributes:[NSForegroundColorAttributeName: UIColor.white])
//        //stateTextField.attributedPlaceholder = NSAttributedString(string:"State",
//                                                                 attributes:[NSForegroundColorAttributeName: UIColor.white])
        citytextField.attributedPlaceholder = NSAttributedString(string:"City (Optional)",
                                                                 attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        if let name = UserDefaults.standard.value(forKey: "stateName") as? String {
            stateTextField.attributedPlaceholder = NSAttributedString(string:"State (Optional)",
                                                                      attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
            UserDefaults.standard.removeObject(forKey: "stateName")
        } else {
            stateTextField.attributedPlaceholder = NSAttributedString(string:"State (Optional)",
                                                                      attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        }

        if let name = UserDefaults.standard.value(forKey: "countryName") as? String {
            countryTextField.attributedPlaceholder = NSAttributedString(string:"Country (Optional)",
                                                                        attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
            UserDefaults.standard.removeObject(forKey: "countryName")
        }
        else {
            countryTextField.attributedPlaceholder = NSAttributedString(string:"Country (Optional)",
                                                                        attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        self.userName.delegate = self
        self.userPassword.delegate = self
        self.userMail.delegate = self
        self.sanyasNametextField.delegate = self
        self.phoneNumberTextField.delegate = self
        self.citytextField.delegate = self
        tableView.backgroundView = UIImageView(image: UIImage(named: "the_black.jpg"))
        imageAvatar.layer.cornerRadius = self.imageAvatar.frame.size.width/2
        imageAvatar.clipsToBounds = true
        imageAvatar.layer.borderColor = UIColor.gray.cgColor
        imageAvatar.layer.borderWidth = 1.0
        self.phoneNumberTextField.delegate = self
        self.countryTextField.delegate = self
        self.stateTextField.delegate = self
    
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if  self.isFromImageUpload {
            self.isFromImageUpload = false
            self.changez()
        }
        
        if #available(iOS 10.0, *) {
            phoneNumberTextField.keyboardType = .asciiCapableNumberPad
        } else {
            phoneNumberTextField.keyboardType = .numberPad
        }
        userName.keyboardType = .asciiCapable
        userMail.keyboardType = .asciiCapable
    }
    override func viewDidAppear(_ animated: Bool) {
        if let name = UserDefaults.standard.value(forKey: "countryName") as? String {
            
            self.countryTextField.text = name
        }
        if let name = UserDefaults.standard.value(forKey: "stateName") as? String {
            self.stateTextField.text = name
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == stateTextField {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryStateViewController") as! CountryStateViewController
            vc.isSignUp = true
            if let id = UserDefaults.standard.value(forKey: "countryId") as? String {
            vc.countryId = id
            }
            vc.isSignUpCountry = false
            self.present(vc, animated: true, completion: nil)
            
        } else if textField == countryTextField  {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryStateViewController") as! CountryStateViewController
            vc.isSignUp = true
            vc.isSignUpCountry = true
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        selectedCell = tableView.cellForRow(at: indexPath)
   
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var selectedCell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        
        selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if (segue.identifier == "termAndCondition"){
            UserDefaults.standard.set("termAndCondition", forKey: "category")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    @IBAction func termConditionButtonAction(_ sender: UIButton) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
//        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func termCondtionButtonAction(_ sender: Any) {
//        let vc = TermsAndConditionsViewController(nibName: "TermsAndConditionsViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addPhoto(){
        chooseAlbum()
    }
    
    func chooseAlbum(){
        
        let alert = UIAlertController(title: "select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes    =   [kUTTypeImage as String]
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
            
            self.imageAvatar.image = pickedImage
            //print("self.communityImageView.image",self.communityImageView.image)
        }
        dismiss(animated: true, completion: {
            self.changez()
            
        })
    }
    
    func changez(){
        // self.communityImageView.image = self.photoimage
        
        let url = URL(string:String(format: "%@%@", BASE_URL_BACKEND,ENDPOINT_USER_UPLOAD))
        //  print("Updateurl",url)
        let goupload = ImageWebUpload()
        let cropping = ImageResizer()
        
        //let cropimg = cropping.RBResizeImage(photoimage ,targetSize: CGSize(width: 100,height: 100) )
        
        goupload.imageUploadRequest(image: self.imageAvatar.image!, uploadUrl: url! as NSURL, param: ["X-API-KEY":API_GENERAL_KEY]) { (success) in
            
            //  print("success",success)
            if(success){
                
                let thisImage = goupload.urlimage
                self.regImage = thisImage
                
            }
        }
    }
    

    func isValidEmail(emaild:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emaild)
    }
    
    func isValidMobilNo(mobileNo:String) -> Bool {
        return mobileNo.count  == 10
    }
    
    func alert(_ title : String, subTitle: String) {
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
        }
        let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
    
        SCLAlertView().showTitle(title , subTitle: subTitle, timeout: time, completeText: "Done", style:  .success)
    }
    
    @IBAction func createAccount(){
            
             //let trimmed = str?.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimeName = userName.text
            let trimeMail = userMail.text
            let trimepass = userName.text
            let trimeCoutry = countryTextField.text
            let trimState = stateTextField.text
            let trimeCity = citytextField.text
            
            let uName = trimeName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let uMail = trimeMail?.trimmingCharacters(in: .whitespacesAndNewlines)
            let uPassword = trimepass?.trimmingCharacters(in: .whitespacesAndNewlines)
            //let uCountry = //trimeCoutry?.trimmingCharacters(in: .whitespacesAndNewlines)
            //let uState = trimState?.trimmingCharacters(in: .whitespacesAndNewlines)
            //let uCity = trimeCity?.trimmingCharacters(in: .whitespacesAndNewlines)
            
    //        if let img = self.signUpImage{
    //
    //        }
           // print("SDSD - ",userMail.text ?? "")
            
            if (userName.text == "" || uName == ""){
                self.alert("Empty Name", subTitle: "Please Enter Name")
            }else if (userMail.text == "" || uMail == "" || !isValidEmail(emaild: userMail.text!)) {
                self.alert("Valid Email", subTitle: "Please Enter Valid Email")
            } else if (userPassword.text == "" || uPassword == "" ){
                self.alert("Empty Password", subTitle: "Please Enter Password")
            }else if (phoneNumberTextField.text != "" && !isValidMobilNo(mobileNo: phoneNumberTextField.text!) ){
                self.alert("Empty phone number", subTitle: "Please Enter Valid phone number")
            }else {
            
                let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_USER_REGISTER)
                
                var parameters:[String: String] = ["X-API-KEY": API_GENERAL_KEY]
                if let name = userName.text {
                    parameters ["username"] =  name
                }
                if let email = userMail.text {
                    parameters["email"] = email
                }
                if let password = userPassword.text {
                    parameters["password"] = password
                }
                
                if self.countryTextField.text == ""{
                    parameters["country_id"] = self.countryTextField.text
                }else {
                    if let cid = UserDefaults.standard.value(forKey: "countryId") as? String {
                        parameters["country_id"] = cid
                        // UserDefaults.standard.removeObject(forKey: "country_Name")
                    }
                }
                if self.stateTextField.text == ""{
                    parameters["state_id"] = self.stateTextField.text
                }else {
                    if let sid = UserDefaults.standard.value(forKey: "stateId") as? String {
                        parameters["state_id"] = sid
                        // UserDefaults.standard.removeObject(forKey: "country_Name")
                    }
                }
    //            if let countyId = self.countryTextField.text {
    //                if let cid = UserDefaults.standard.value(forKey: "countryId") as? String {
    //                    parameters["country_id"] = cid
    //                    // UserDefaults.standard.removeObject(forKey: "country_Name")
    //                }
    //            }
    //            if let stateId = self.stateTextField.text {
    //                if let sid = UserDefaults.standard.value(forKey: "stateId") as? String {
    //                    parameters["state_id"] = sid
    //                    // UserDefaults.standard.removeObject(forKey: "country_Name")
    //                }
    //            }

                 //parameters["country_id"] = "0"
                // parameters["state_id"] = "0"
                
    //            if let countyId = UserDefaults.standard.value(forKey: "countryId") as? String {
    //                parameters["country_id"] = countyId
    //            }
    ////
    //            if let stateId = UserDefaults.standard.value(forKey: "stateId") as? String {
    //                parameters["state_id"] = stateId
    //            }
    //
    //            if let country = self.countryTextField.text {
    //                parameters["country_id"] = country
    //            }
    //            if let state = self.stateTextField.text {
    //                parameters["state_id"] = state
    //            }
                if let city = citytextField.text {
                    parameters["city"] = city
                }
                
                if let sanyas_name = sanyasNametextField.text{
                    parameters["sanyas_name"] = sanyas_name
                }
                if let phone_number = phoneNumberTextField.text {
                    parameters["phone_number"] = phone_number
                }
                if let image = self.regImage {
                    parameters["profile_photo"] = image
                }
                parameters ["device"] = "iOS"
                
                print(parameters)
                
                Alamofire.request( urlRequest,method: .post, parameters: parameters)
                    //self.imageAvatar.image ?? ""
                    .responseJSON { response in
                        
                        UserDefaults.standard.removeObject(forKey: "stateId")
                        UserDefaults.standard.removeObject(forKey: "countryId")
                        //UserDefaults.standard.removeObject(forKey: "stat_Id")
                        //UserDefaults.standard.removeObject(forKey: "count_Id")
                        guard  let item = response.result.value as! NSDictionary? else {return}
                        
                    print("****** response data = \(response)")
                        
    //                    var num : NSNumber = 1
    //                    if let item2 = item.object(forKey: "message") {
    //                        num =  item2 as! NSNumber
    //                    }g
                         guard let status = item.object(forKey: "status")  else {return}
                        let message = status as! String
                        self.successMessage = message
                        print(message)
                        guard let itm = item.object(forKey: "message")  else {return}
                        
                        let item2 = itm as! NSNumber

                        if item2 == 0 {
                            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                            }
                            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                            SCLAlertView().showTitle("ops...", subTitle: self.successMessage, timeout: time, completeText: "Done", style:  .success)
                            self.userName.text = ""
                            self.userMail.text = ""
                            self.userPassword.text = ""
                            self.sanyasNametextField.text = ""
                            self.phoneNumberTextField.text =  ""
                            self.countryTextField.text = ""
                            self.stateTextField.text  = ""
                            self.citytextField.text = ""
                            self.imageAvatar.image = UIImage(named: "osho")
                        } else {
                            
                            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context: NSManagedObjectContext = appDel.managedObjectContext
                            let newFav = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
                            GLOBAL_USER_ID = item2
                            newFav.setValue(item2 , forKey: "user_id")
                            newFav.setValue(self.userName.text , forKey: "user_name")
                            newFav.setValue(self.userMail.text , forKey: "user_mail")
                            newFav.setValue(self.userPassword.text, forKey: "user_password")
                            newFav.setValue(self.citytextField.text, forKey: "user_city")
                            newFav.setValue(self.regImage, forKey: "user_pic")
                            print(newFav)
                            do {
                                try context.save()
                                
                            } catch {
                                
                            }
                            self.alerUser()
                            
                        }
                        
                }
            }
            
            
        }
    func alerUser() {
        
        let alertController = UIAlertController(title: "Ask Bhagwan", message: successMessage, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginTableViewController
            loginVC.modalPresentationStyle = .fullScreen
            //loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
        })
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension RegistrationTableViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 10
        }
        return true
    }
}
