//
//  CustomIntegrationViewController.swift
//  StripeIntegrationExample
//
//  Created by Farrukh Javeid on 02/05/2019.
//  Copyright © 2019 The Right Software. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import SVProgressHUD
class CustomIntegrationViewController: BaseViewController, UITextFieldDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!

    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var planTextField: UITextField!
    var userID : Int?
    var user_Id  : String?
    var isFromMusicPlayer = false
    var planArray = ["1 Month", "6 Month", "1 Year"]
    let pickerView = UIPickerView()
    var selectedMonth  = 0
    //MARK:- Properties
    fileprivate let paymentURL: String = "http://localhost:8888/Stripe_Test/stripe_api.php/"
    
    //MARK:- UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Checkout"
        titelLabel.isHidden = false
        paymentButton.setTitle("Make Payment", for: .normal)
        print("Se3lected month",selectedMonth)
        cardNumberField.attributedPlaceholder = NSAttributedString(string: "Enter Card Number",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        expiryTextField.attributedPlaceholder = NSAttributedString(string: "Expiry (MM/YY)",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        cvvTextField.attributedPlaceholder = NSAttributedString(string: "CVV Code",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        if selectedMonth == 1 {
            titelLabel.text =  "Paying " + "$ 3.5(USD) / ₹ 300 " + "For 1 months"
        }else if selectedMonth == 6 {
            titelLabel.text = "Paying " + "$ 20(USD) / ₹ 1500" + " For 6 months"
        }else {
            titelLabel.text = "Paying " + "$ 40(USD) / ₹ 3000" + " For 12 months"
        }
    }
    //MARK:- GUI Events
    @IBAction func makePaymentButtonPressed(_ sender: Any) {
        if cardNumberField.text == ""{
            alert("ASK Bhagwan", subTitle: "Please Enter card number")
        }else if expiryTextField.text == ""{
            alert("ASK Bhagwan", subTitle: "Please Enter expiry date")
        }else if cvvTextField.text == ""{
            alert("ASK Bhagwan", subTitle: "Please Enter CVV number")
        }else {
            //card parameters
            let stripeCardParams = STPCardParams()
            stripeCardParams.number = cardNumberField.text
            let expiryParameters = expiryTextField.text?.components(separatedBy: "/")
            stripeCardParams.expMonth = UInt(expiryParameters?.first ?? "0") ?? 0
            stripeCardParams.expYear = UInt(expiryParameters?.last ?? "0") ?? 0
            stripeCardParams.cvc = cvvTextField.text

            //converting into token
            let config = STPPaymentConfiguration.shared()
            let stpApiClient = STPAPIClient.init(configuration: config)
            stpApiClient.createToken(withCard: stripeCardParams) { (token, error) in
                if error == nil {
                    //Success
                    DispatchQueue.main.async {
                            self.getAdMobSubscription(token!.tokenId)
                            //self.createPayment(token: token!.tokenId, amount: 3.5)
                            print("token!.tokenId",token!.tokenId)
                        //self.alert("ASK Bhagwan", subTitle: "Payment Success")
                    }
                } else {
                    //failed
                    if self.isFromMusicPlayer{
                        self.alert_Dismiss("Payment Failed", message: "Please try Again", isFromMusic: true)
                   }else{
                    self.alert_Dismiss("Payment Failed", message: "Please try Again", isFromMusic: false)
                   }
                    print("Failed")
                }
            }
        }
    }
    
    func getAdMobSubscription(_ tokenId:String){
        if let userId = GLOBAL_USER_ID {
            userID = userId as? Int
        }
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(RED_COLOR)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,GET_ADMOB_SUBSCRIPTION)
        print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"userId":userID!,"month":selectedMonth,"tokenId": tokenId])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    print("subscription_response",response)
                    self.getAdMobSubscriptionStatus()
                    guard let item = response.result.value as! NSDictionary? else {return}
                    if let message = item.value(forKey: "message") as? String {
                        if self.isFromMusicPlayer{
                            self.alert_Dismiss("ASK Bhagwan", message: message, isFromMusic: true)
                       }else{
                        self.alert_Dismiss("ASK Bhagwan", message: message, isFromMusic: false)
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
    func getAdMobSubscriptionStatus() {
        if let userId = GLOBAL_USER_ID {
            user_Id = userId.stringValue
        }
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ADMOB_SUBSCRIPTION_STATUS + user_Id! )
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    print("itemss",itemss)
              let  subStatus = itemss.value(forKey: "subscriptionStatus") as! Bool
                UserDefaults.standard.set(subStatus, forKey: "subscriptionStatus")
                UserDefaults.standard.synchronize()
                if subStatus == true  {
                    print("User subscribed ")
                }else {
                    print(" User Not subscribe")
                }
                print("subStatus",subStatus)
                if let idds = UserDefaults.standard.value(forKey: "id") {
                    self.getUserInfo(id: idds as! String)
                }
        }
    }
    func getUserInfo(id : String){
        print("noodataavailabel")
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_USER_INFO + id)
            print(urlResponce)
            Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
                .responseJSON { response in
                    print(response)
                    SVProgressHUD.dismiss()
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    print("itemss",itemss)
                    let st = itemss["state_id"] as! String
                    let ct = itemss["country_id"] as! String
                    let subscriptionEndDate = itemss["subscriptionEndDate"] as! String
                    UserDefaults.standard.set(subscriptionEndDate, forKey: "subscriptionEndDate")
                    UserDefaults.standard.synchronize()
                    print(st)
                    print(ct)
                    if st == "0" || st == "" || ct == "0" || ct == "" {
                        print("Show pop up")
                       // self.showAlert()
                let notify = Notification.Name(rawValue: "popUp")
                        NotificationCenter.default.post(name: notify, object: nil)
                    }
            }
    }
   /* func getDonationSuccess(_ userID:Int,email:String,tranctionID: String,amount:Int){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_DONATION_SUCCESS)
       // print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"userId":userID,"emailId":email,"platform":"iOS","transactionId":tranctionID,"amount":amount])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    //guard let itms = response.result.value else {return}
                   // print("Donation Success",itms)
                  //  let itemss = itms as! NSDictionary
                    //let success = itemss.value(forKey: "message") as! Int
                     //print("success",success)
                    
                    guard let item = response.result.value as! NSDictionary? else {return}
                    if let message = item.value(forKey: "message") as? Int {
                        if let id = UserDefaults.standard.value(forKey: "user_id") as? String {
                            let userID = Int(id)
                            if message == userID {
                                self.alert("ASK Bhagwan", subTitle: "Donation Success")
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
    }*/
    
    @IBAction func tapGestureInvoked(_ sender: Any) {
        view.endEditing(true)
    }
    
    //MARK:- UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //no dots allowed
        if string == "." {
            return false
        }
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            if textField == cardNumberField {
                if updatedText.count > 16 {
                    return false
                }
            } else if textField == cvvTextField {
                
                if updatedText.count > 3 {
                    return false
                }
            } else if textField == expiryTextField {
                
                if updatedText.count > 5 {
                    return false
                }
            }
            
        }
        return true
    }
    
    //MARK:- Helper Methods
    fileprivate func createPayment(token: String, amount: Float) {
        Alamofire.request(paymentURL, method: .post, parameters: ["stripeToken": token, "amount": amount * 100],encoding: JSONEncoding.default, headers: nil).responseString {
            response in
            switch response.result {
            case .success:
                print("Success")
                
                break
            case .failure(let error):
                
                print("Failure")
            }
        }
    }
}
/*extension CustomIntegrationViewController :  UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return planArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         let name = planArray[row]

        return name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = planArray[row]
        if name == "1 Month" {
            let title = "$ 3.5(USD) / ₹ 300"
            planTextField.text = title
            titelLabel.text = "Subscription will be for 1 Month"
            selectedMonth = 1
        }else if name == "6 Month" {
            let title = "$ 20(USD) / ₹ 1500"
            planTextField.text = title
            titelLabel.text = "Subscription will be for 6 Month"
            selectedMonth = 6
        }else {
            let title = "$ 40(USD) / ₹ 3000"
            planTextField.text = title
            titelLabel.text = "Subscription will be for 1 Year"
            selectedMonth = 12
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == planTextField {
            planTextField.inputView = pickerView
            pickerView.delegate = self
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    @objc func action() {
        view.endEditing(true)
    }
}
*/
