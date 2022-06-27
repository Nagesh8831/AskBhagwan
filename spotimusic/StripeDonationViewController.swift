//
//  StripeDonationViewController.swift
//  spotimusic
//
//  Created by Mac on 30/03/21.
//  Copyright © 2021 Appteve. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import SVProgressHUD
class StripeDonationViewController: BaseViewController{

    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var donationAmtTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    var currencyArray = [
        "AED" ,
        "AFN" ,
        "ALL" ,
        "AMD" ,
        "ANG" ,
        "AOA" ,
        "ARS" ,
        "AUD" ,
        "AWG" ,
        "AZN" ,
        "BAM" ,
        "BBD" ,
        "BDT" ,
        "BGN",
        "BHD" ,
        "BIF" ,
        "BMD" ,
        "BND" ,
        "BOB" ,
        "BOV" ,
        "BRL" ,
        "BSD" ,
        "BTN" ,
        "BWP" ,
        "BYR" ,
        "BZD" ,
        "CAD" ,
        "CDF" ,
        "CHE" ,
        "CHF" ,
        "CHW" ,
        "CLF" ,
        "CLP" ,
        "CNY" ,
        "COP" ,
        "COU" ,
        "CRC" ,
        "CUP" ,
        "CVE" ,
        "CYP" ,
        "CZK" ,
        "DJF" ,
        "DKK" ,
        "DOP" ,
        "DZD" ,
        "EEK" ,
        "EGP" ,
        "ERN" ,
        "ETB" ,
        "EUR" ,
        "FJD" ,
        "FKP" ,
        "GBP" ,
        "GEL" ,
        "GHS" ,
        "GIP",
        "GMD" ,
        "GNF" ,
        "GTQ" ,
        "GYD" ,
        "HKD" ,
        "HNL" ,
        "HRK" ,
        "HTG" ,
        "HUF" ,
        "IDR" ,
        "ILS" ,
        "INR" ,
        "IQD" ,
        "IRR" ,
        "ISK" ,
        "JMD" ,
        "JOD" ,
        "JPY" ,
        "KES" ,
        "KGS" ,
        "KHR" ,
        "KMF" ,
        "KPW" ,
        "KRW" ,
        "KWD" ,
        "KYD" ,
        "KZT" ,
        "LAK" ,
        "LBP",
        "LKR" ,
        "LRD" ,
        "LSL" ,
        "LTL" ,
        "LVL" ,
        "LYD" ,
        "MAD" ,
        "MDL" ,
        "MGA" ,
        "MKD" ,
        "MMK" ,
        "MNT" ,
        "MOP" ,
        "MRO" ,
        "MTL" ,
        "MUR" ,
        "MVR" ,
        "MWK" ,
        "MXN" ,
        "MXV" ,
        "MYR" ,
        "MZN" ,
        "NAD" ,
        "NGN" ,
        "NIO" ,
        "NOK" ,
        "NPR" ,
        "NZD" ,
        "OMR" ,
        "PAB" ,
        "PEN" ,
        "PGK" ,
        "PHP" ,
        "PKR" ,
        "PLN" ,
        "PYG" ,
        "QAR" ,
        "RON" ,
        "RSD" ,
        "RUB" ,
        "RWF" ,
        "SAR" ,
        "SBD" ,
        "SCR" ,
        "SDG" ,
        "SEK" ,
        "SGD" ,
        "SHP" ,
        "SKK" ,
        "SLL" ,
        "SOS" ,
        "SRD" ,
        "STD" ,
        "SYP" ,
        "SZL" ,
        "THB" ,
        "TJS" ,
        "TMM" ,
        "TND" ,
        "TOP" ,
        "TRY" ,
        "TTD" ,
        "TWD" ,
        "TZS" ,
        "UAH" ,
        "UGX" ,
        "USD" ,
        "USN" ,
        "USS" ,
        "UYU" ,
        "UZS" ,
        "VEB" ,
        "VND" ,
        "VUV" ,
        "WST" ,
        "XAF" ,
        "XAG" ,
        "XAU" ,
        "XBA" ,
        "XBB" ,
        "XBC" ,
        "XBD" ,
        "XCD" ,
        "XDR" ,
        "XFO" ,
        "XFU" ,
        "XOF" ,
        "XPD" ,
        "XPF" ,
        "XPT" ,
        "XTS" ,
        "XXX" ,
        "YER" ,
        "ZAR" ,
        "ZMK" ,
        "ZWD" ]
    var donationAmt = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Donate"
        currencyTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //MARK:- GUI Events
    @IBAction func makePaymentButtonPressed(_ sender: Any) {
        if currencyTextField.text == "" {
            alert("ASK Bhagwan", subTitle: "Please select currency")
        }
//        else if donationAmtTextField.text == "" {
//            alert("ASK Bhagwan", subTitle: "Please enter amount")
//        }else if (self.donationAmt < 100 && currencyTextField.text == "INR"){
//            alert("ASK Bhagwan", subTitle: "Enter minimun 100 Rs amount")
//        }else if (donationAmtTextField.text! < "1" && currencyTextField.text == "USD"){
//            alert("ASK Bhagwan", subTitle: "Enter minimun 1US$ amount")
//        }else if (donationAmtTextField.text! < "1" && currencyTextField.text == "AUD"){
//            alert("ASK Bhagwan", subTitle: "Enter minimun 1A$ amount")
//        }
        else{
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
                        if let id = UserDefaults.standard.value(forKey: "user_id") as? String {
                            let userId = Int(id)
                            self.donationAmt = Int(self.donationAmtTextField.text!)!
                            self.getDonationSuccess(userId!, tokenId: token!.tokenId, currency: self.currencyTextField.text!, amount:( self.donationAmt * 100))
                            print("token!.tokenId",token!.tokenId)
                            print("userId",userId)
                           // self.alert_Dismiss("Payment Success", message: token!.tokenId)
                    }
                }
            } else {
                //failed
                self.alert_Dismiss("Payment Failed", message: "Please try Again", isFromMusic: false)
                print("Failed")
            }
        }
    }
    }
    func getDonationSuccess(_ userID:Int,tokenId: String,currency:String,amount:Int){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(RED_COLOR)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_STRIPE_DONATION_SUCCESS)
        print("urlResponce",urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"userId":userID,"tokenId": tokenId,"currency":currency,"amount":amount])

            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    print("Donation_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    let mes = itemss.value(forKey: "message") as! String
                    print("Succ",mes)
                    self.alert_Dismiss("ASK Bhagwan", message: mes, isFromMusic: false)
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
    
    @IBAction func tapGestureInvoked(_ sender: Any) {
        view.endEditing(true)
    }
    func createPickerView() {
        pickerView.delegate = self
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(action));
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
    }

    @objc func action() {
        view.endEditing(true)
    }
    //MARK:- Helper Methods
    fileprivate func createPayment(token: String, amount: Float) {
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_DONATION_SUCCESS)
        Alamofire.request(urlResponce, method: .post, parameters: ["stripeToken": token, "amount": amount * 100],encoding: JSONEncoding.default, headers: nil).responseString {
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
extension StripeDonationViewController: UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return currencyArray.count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return currencyArray[row]
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            currencyTextField.text = currencyArray[row]
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == currencyTextField {
            currencyTextField.inputView = pickerView
            currencyTextField.inputAccessoryView = toolbar
            createPickerView()
        }
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
}
