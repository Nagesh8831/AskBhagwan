//
//  DonationViewController.swift
//  spotimusic
//
//  Created by BQTMAC003 on 13/02/20.
//  Copyright © 2020 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import CZPicker
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AVKit
import AVFoundation
import SCLAlertView
import StoreKit
class DonationViewController: BaseViewController {
     
      var environment:String = PayPalEnvironmentNoNetwork {
         willSet(newEnvironment) {
           if (newEnvironment != environment) {
             PayPalMobile.preconnect(withEnvironment: newEnvironment)
           }
         }
       }
    var resultText = ""
     @IBOutlet weak var donationAmtTextField: UITextField!
       @IBOutlet weak var successView: UIView!
       var payPalConfig = PayPalConfiguration()
@IBOutlet weak var menuBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

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
              self.title = "Donation"
        
        //Pay pal integration
       /*     //self.environment = PayPalEnvironmentSandbox
            self.environment = PayPalEnvironmentProduction
            //successView.isHidden = true
                // Set up payPalConfig
               payPalConfig.acceptCreditCards = false
               payPalConfig.merchantName = "Awesome Shirts, Inc."
               payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
               payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")*/
        // Do any additional setup after loading the view.
    }
    @IBAction func payPalButtonAction(_ sender: UIButton) {
        if let url = URL(string: "https://www.askbhagwan.org/paynow/") {
            UIApplication.shared.open(url)
        }
    }
        @IBAction func setupCardButtonPressed(_ sender: Any) {
    //        let config = STPPaymentConfiguration.shared()
    //        //config.requiredBillingAddressFields = .full
    //        let viewController = STPAddCardViewController(configuration: config, theme: STPTheme.default())
    //        viewController.delegate = self
    //        let navigationController = UINavigationController(rootViewController: viewController)
    //        present(navigationController, animated: true, completion: nil)

            //{
               let VC = self.storyboard?.instantiateViewController(withIdentifier: "StripeDonationViewController") as! StripeDonationViewController
                //VC.isFromDonation = true
                self.navigationController?.pushViewController(VC, animated: true)
          // }
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   
}
extension DonationViewController {
    func getDonationSuccess(_ userID:Int,email:String,tranctionID: String,amount:Int){
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
    }
}
/*extension DonationViewController : PayPalPaymentDelegate, PayPalFuturePaymentDelegate {
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
           print("PayPal Payment Cancelled")
          // resultText = ""
           //successView.isHidden = true
           paymentViewController.dismiss(animated: true, completion: nil)
       }
       
       func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
           print("PayPal Payment Success !")
           let paymentResultDic = completedPayment.confirmation as NSDictionary
           let dicResponse: AnyObject? = paymentResultDic.object(forKey: "response") as AnyObject?
           print("dicResponse",dicResponse as Any)
           if  let transactionId = dicResponse?.object(forKey: "id") {
             print("transactionId",transactionId)
               if let id = UserDefaults.standard.value(forKey: "user_id") as? String ,let emailID = UserDefaults.standard.value(forKey: "email") as? String {
                   let userId = Int(id)
                   let donationAmount = Int(donationAmtTextField.text!)
                   getDonationSuccess(userId!, email: emailID, tranctionID: transactionId as! String, amount: donationAmount!)
           }
               
           }
         paymentViewController.dismiss(animated: true, completion: { () -> Void in
           // send completed confirmaion to your server
           print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
           self.resultText = completedPayment.description
         })
       }
       func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
       }
       
       func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable : Any]) {
       }
}*/
