//
//  BaseViewController.swift
//  spotimusic
//
//  Created by Mac on 10/04/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
import SVProgressHUD
import SCLAlertView
import GoogleMobileAds
import Stripe
import IOSurface
class BaseViewController: UIViewController{

   // var interstitial: GADInterstitial!
    //var rewardedAd: GADRewardedAd?
    //let kAPPKEY = "8545d445"
    let kAPPKEY = "a4fd26cd"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //interstitial = GADInterstitial(adUnitID: TEST_FULL_ADD_UNIT_ID)
        //title = "Subscribe"
        /*
       // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "8e768890300546c1c860cc14080c247509d38d9d" ]// 8e768890300546c1c860cc14080c247509d38d9d
        //["826f102a450b1638eb9a0a5b86242cbf98911860"]
        //[ "5e50c0916cb170e49b503115b12655e2decf7747" ]
        interstitial = createAndLoadInterstitial()
        let request = GADRequest()
        interstitial.load(request)
        //rewarde ads
        rewardedAd = GADRewardedAd(adUnitID: TEST_REWARD_ADD_UNIT_ID)
         rewardedAd?.load(GADRequest()) { error in
             if let error = error {
               // Handle ad failed to load case.
             } else {
               // Ad successfully loaded.
             }
           }*/

        //IS
        setupIronSourceSdk()
    }
    override func viewWillAppear(_ animated: Bool) {
        //IronSource.loadInterstitial()
    }
    func alert(_ title : String, subTitle: String) {
           let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
           }
           let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
           
           SCLAlertView().showTitle(title , subTitle: subTitle, timeout: time, completeText: "Done", style:  .success)
       }
    
//    func createAndLoadInterstitial() -> GADInterstitial {
//      let interstitial = GADInterstitial(adUnitID: TEST_FULL_ADD_UNIT_ID)
//      interstitial.delegate = self
//      interstitial.load(GADRequest())
//      return interstitial
//    }

    func showAdds(){
        IronSource.showRewardedVideo(with: self)
        //IronSource.showInterstitial(with: self)
//        if interstitial.isReady {
//            interstitial = createAndLoadInterstitial()
//            interstitial.present(fromRootViewController: self)
//            print("Ad ready")
//            switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
//                  case
//                  STKAudioPlayerState.playing,
//                  STKAudioPlayerState.buffering:
//                      //cell.playingTrackGIFImageView.isHidden = false
//                      print("Paused")
//                      AudioPlayer.sharedAudioPlayer.pause()
//                  default: break
//                  }
//        } else {
//            print("Ad wasn't ready")
//            interstitial = createAndLoadInterstitial()
//            switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
//             case
//             STKAudioPlayerState(),
//             STKAudioPlayerState.paused :
//                AudioPlayer.sharedAudioPlayer.resume()
//                print("Resume")
//             default: break
//            }
//        }
    }
    func addBackButton() {
        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
        btnShowMenu.setImage(UIImage(named: "back"), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onBackButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    @objc func onBackButtonPressed(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func showRewaredAds() {
//        if rewardedAd?.isReady == true {
//           rewardedAd?.present(fromRootViewController: self, delegate:self)
//        }
    }
    func alertDismiss(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        })
        let noAction = UIAlertAction(title: "No", style: .default, handler: {
            alert -> Void in
           // self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(saveAction)
        alert.addAction(noAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func alert_Dismiss(_ title: String, message: String,isFromMusic:Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
           if isFromMusic{
            self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            //self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(saveAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showPreSubscriptionPopUp(){
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "OOPS no subscribe plan for this month, Lets Make Payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubsciptionPlanViewController") as! SubsciptionPlanViewController
                vc.isFromMusicPlayer = false
                self.navigationController?.pushViewController(vc, animated: true)
               // self.present(vc, animated: true, completion: nil)
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
                  // self.navigationController?.popViewController(animated: true)
                switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                 case
                 //STKAudioPlayerState(),
                 STKAudioPlayerState.paused :
                    //AudioPlayer.sharedAudioPlayer.resume()
                    print("Resume")
                 default: break
                }
               })
               alert.addAction(saveAction)
               alert.addAction(noAction)
               DispatchQueue.main.async {
                   self.present(alert, animated: true, completion: nil)
               }
    }

    //
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*extension  BaseViewController : GADInterstitialDelegate{
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
     // print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
      
       // alertDismiss("Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment")
       /* let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomIntegrationViewController") as! CustomIntegrationViewController
                vc.isFromDonation = false
                self.navigationController?.pushViewController(vc, animated: true)
               // self.present(vc, animated: true, completion: nil)
                switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                 case
                 STKAudioPlayerState(),
                 STKAudioPlayerState.paused :
                   // AudioPlayer.sharedAudioPlayer.resume()
                    print("Resume")
                 default: break
                }
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
                  // self.navigationController?.popViewController(animated: true)
                switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                 case
                 STKAudioPlayerState(),
                 STKAudioPlayerState.paused :
                    AudioPlayer.sharedAudioPlayer.resume()
                    print("Resume")
                 default: break
                }
               })
               alert.addAction(saveAction)
               alert.addAction(noAction)
               DispatchQueue.main.async {
                   self.present(alert, animated: true, completion: nil)
               }*/
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}
extension  BaseViewController : GADRewardedAdDelegate{
    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
      print("Rewarded ad presented.")
    }
    /// Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
      print("Rewarded ad dismissed.")
    }
    /// Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
      print("Rewarded ad failed to present.")
    }
}*/
extension BaseViewController : ISRewardedVideoDelegate {
    func setupIronSourceSdk() {
        ISIntegrationHelper.validateIntegration()
        // Before initializing any of our products (Rewarded video, Offerwall or Interstitial) you must set
        // their delegates. Take a look at these classes and you will see that they each implement a product
        // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
        // we will not be able to communicate with you.
        // We're passing 'self' to our delegates because we want
        // to be able to enable/disable buttons to match ad availability.
       // IronSource.setInterstitialDelegate(self)
        //IronSource.add(self)
        IronSource.setRewardedVideoDelegate(self)
        IronSource.initWithAppKey(kAPPKEY)
        // To initialize specific ad units:
//        IronSource.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL,IS_BANNER])
    }
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        print("RV Availbel")
    }

    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        print("RV Received")
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print("Rv Failed to show")
        //Utilities.displayToastMessage("ads not present")
        //AudioPlayer.sharedAudioPlayer.resume()
        //IronSource.showRewardedVideo(with: self)
    }

    func rewardedVideoDidOpen() {
        print("RV Open")
        IronSource.showRewardedVideo(with: self)
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidClose() {
        print("RV Close")
        AudioPlayer.sharedAudioPlayer.pause()
        let alert = UIAlertController(title: "Use Ask Bhagwan without ads", message: "Are you sure,You want to make payment", preferredStyle: .alert)
              // alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               let saveAction = UIAlertAction(title: "Yes", style: .default, handler: {
                   alert -> Void in
                   //self.navigationController?.popViewController(animated: true)
                //self.presentStripPayment()
               AudioPlayer.sharedAudioPlayer.pause()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubsciptionPlanViewController") as! SubsciptionPlanViewController
                vc.isFromMusicPlayer = false
                self.navigationController?.pushViewController(vc, animated: true)
               // self.present(vc, animated: true, completion: nil)
               })
               let noAction = UIAlertAction(title: "No", style: .default, handler: {
                   alert -> Void in
                  // self.navigationController?.popViewController(animated: true)
                switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
                 case
                 STKAudioPlayerState(),
                 STKAudioPlayerState.paused :
                    AudioPlayer.sharedAudioPlayer.resume()
                    print("Resume")
                 default: break
                }
               })
               alert.addAction(saveAction)
               alert.addAction(noAction)
               DispatchQueue.main.async {
                   self.present(alert, animated: true, completion: nil)
               }
    }

    func rewardedVideoDidStart() {
        print("RV Start")
        AudioPlayer.sharedAudioPlayer.pause()
    }

    func rewardedVideoDidEnd() {
        print("RV End")
    }

    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        print("RV clicked")
        AudioPlayer.sharedAudioPlayer.pause()
    }


}
/*extension BaseViewController :ISInterstitialDelegate{
        func setupIronSourceSdk() {
            ISIntegrationHelper.validateIntegration()
            // Before initializing any of our products (Rewarded video, Offerwall or Interstitial) you must set
            // their delegates. Take a look at these classes and you will see that they each implement a product
            // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
            // we will not be able to communicate with you.
            // We're passing 'self' to our delegates because we want
            // to be able to enable/disable buttons to match ad availability.
            IronSource.setInterstitialDelegate(self)
            //IronSource.add(self)



            IronSource.initWithAppKey(kAPPKEY)
            // To initialize specific ad units:
    //        IronSource.initWithAppKey(kAPPKEY, adUnits:[IS_REWARDED_VIDEO,IS_INTERSTITIAL,IS_OFFERWALL,IS_BANNER])
        }
    func interstitialDidLoad() {
        print("IS Load")
        IronSource.showInterstitial(with: self)
    }

    func interstitialDidFailToLoadWithError(_ error: Error!) {
        print("IS Load Error")
        IronSource.showInterstitial(with: self)
    }

    func interstitialDidOpen() {
        print("IS Open")
    }

    func interstitialDidClose() {
        print("IS Close")
        IronSource.loadInterstitial()
    }

    func interstitialDidShow() {
        print("IS Show")
    }

    func interstitialDidFailToShowWithError(_ error: Error!) {
        print("IS Show With Error")
        IronSource.loadInterstitial()
    }

    func didClickInterstitial() {
        print("IS Clicked")
    }


}*/
