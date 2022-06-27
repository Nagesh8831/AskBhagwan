//
//  LoginTableViewController.swift
//  spotimusic
//
//  Created by appteve on 16/06/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SCLAlertView
import SWRevealViewController
import SVProgressHUD

class LoginTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let effect = UIBlurEffect(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.attributedPlaceholder = NSAttributedString(string:"Your email",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string:"Your password",
                                                            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.username.delegate = self
        self.password.delegate = self
       // self.username.text = "nagesh@gmail.com"
       // self.password.text = "admin"
        tableView.backgroundView = UIImageView(image: UIImage(named: "the_black.jpg"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func login(){
        if username.text == "" {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("Email", subTitle: "Enter Valid email", timeout: time, completeText: "Done", style:  .success)
        } else if  password.text == "" {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("Password", subTitle: "Enter password", timeout: time, completeText: "Done", style:  .success)
        }else {
            
            let urlRequest = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_USER_LOGIN)
            SVProgressHUD.show()
            Alamofire.request( urlRequest,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"email":username.text!,"password":password.text!])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    guard let item = response.result.value as! NSDictionary? else {return}
                    
                    let item2 = item.value(forKey: "error") as! NSNumber
                    
                    if item2 == 0 {
                        let userdata = item.value(forKey: "respon") as! NSDictionary?
                        
                        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context: NSManagedObjectContext = appDel.managedObjectContext
                        let newFav = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
                        let numbr = userdata?.value(forKey: "id") as! String
                        UserDefaults.standard.set(numbr, forKey: "loginUserID")
                        UserDefaults.standard.synchronize()
                        let numbs = Int(numbr)
                        
                        let userId = NSNumber(value:numbs!)
                        let passw = userdata?.value(forKey: "password") as! String
                        
                        UserDefaults.standard.set(numbr, forKey: "user_id")
                        newFav.setValue(userId , forKey: "user_id")
                        newFav.setValue(self.username.text , forKey: "user_name")
                        newFav.setValue(self.username.text , forKey: "user_mail")
                        newFav.setValue(passw , forKey: "user_password")
                        do {
                            
                            try context.save()
                            
                        } catch {
                            
                        }
                         //let parentId = UserDAO.loadDefaultUser()?.userId
                        if let userId = userdata!["id"] as? String {
                            UserDefaults.standard.set(userId, forKey: "id")
                            print("USerID",userId)
                        }
                        
                        if let name = userdata!["username"] as? String {
                            UserDefaults.standard.set(name, forKey: "username")
                            print("Name",name)
                        }
                        if let email = userdata!["email"] as? String {
                            UserDefaults.standard.set(email, forKey: "email")
                            print("EmailId",email)
                        }
                        if let password = userdata!["password"] as? String {
                            UserDefaults.standard.set(password, forKey: "password")
                            print("password",password)
                        }
                        if let country_id = userdata!["country_id"] as? String {
                            if country_id == "0" {
                                UserDefaults.standard.set(false, forKey: "isCountryPopUpShown")
                            }
                            UserDefaults.standard.set(country_id, forKey: "country_id")
                            print("country_id",country_id)
                        }
                        
                        if let state_id = userdata!["state_id"] as? String {
                            UserDefaults.standard.set(state_id, forKey: "state_id")
                        }
                        if let city = userdata!["city"] as? String {
                            UserDefaults.standard.set(city, forKey: "city")
                        }
                        if let profile_photo = userdata!["v"] as? String {
                            UserDefaults.standard.set(profile_photo, forKey: "profile_photo")
                        }
                        let user = UserDAO(response: userdata!)
                        user?.saveAsDefaultUser()
                        
                        
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "reval") as! SWRevealViewController
                            loginVC.modalPresentationStyle = .fullScreen
                      //  loginVC.modalTransitionStyle = .crossDissolve
                        self.present(loginVC, animated: true, completion: nil)
                        
                    } else {
                       
                        if !self.isValidEmail(emaild: self.username.text!) {
                            self.alert("Email", subTitle: "Please Enter valid Email")
                        }else {
                            if let message = item.value(forKey: "respon") as? String {
                                self.alert("Email", subTitle: "Incorrect credentials")
                            }
                            
                        }
                       
                    }
                    
            }
        }
    }
    
    
    
    
    func forgotPassword(_ email : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlRequest = String (format: "%@%@%@", BASE_URL_BACKEND,ENDPOINT_FORGOT_PASS,email)
        print("urlRequest",urlRequest)
        Alamofire.request( urlRequest, method: .get, parameters: ["X-API-KEY":API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                print("forgetPassword",response)
                guard let item = response.result.value as! NSDictionary? else {return}
                if let message = item.value(forKey: "message") as? String {
                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                    }
                    let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                    SCLAlertView().showTitle("Message", subTitle: message, timeout: time, completeText: "Done", style:  .success)
              
                }
        }
    }
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Forgot Password?", message: "Please enter your registered email", preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Submit", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            print("firstName \(firstTextField.text!)")
            if !self.isValidEmail(emaild: firstTextField.text!){
                self.alert("Email", subTitle: "Please Enter valid Email")
            } else{
            self.forgotPassword(firstTextField.text ?? "")
            }
            //self.forgotPassword(firstTextField.text ?? "")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your email"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func skipToLoginButtonAction(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "reval") as! SWRevealViewController
       
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func alert(_ title : String, subTitle: String) {
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
        }
        let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
        
        SCLAlertView().showTitle(title , subTitle: subTitle, timeout: time, completeText: "Done", style:  .success)
    }
    func isValidEmail(emaild:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emaild)
    }
    
}
