//
//  AppDelegate.swift
//  spotimusic
//
//  Created by appteve on 27/05/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer
import CoreData
import CZPicker
import KVNProgress
import Kingfisher
import SVProgressHUD
import MarqueeLabel
import SCLAlertView
import Reachability
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import StoreKit
import SWRevealViewController
import Firebase
import FirebaseMessaging
import UserNotificationsUI
import FirebaseInstanceID
import GoogleMobileAds
import Stripe
enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
let gcmMessageIDKey = "gcm.message_id"
    var myOrientation: UIInterfaceOrientationMask = .portrait
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //stripe keys
        
        //Stripe.setDefaultPublishableKey("pk_test_MfMrI8PzpuCBA69CLezBqjP5") // test key
        Stripe.setDefaultPublishableKey("pk_live_HWbArqG6EA1pyMEkrRsmF15e") // live

        IQKeyboardManager.shared.enable = true
         UIApplication.shared.beginReceivingRemoteControlEvents()
        // test git
        UserDefaults.standard.set("1", forKey: "defaultLanguageId")
        UserDefaults.standard.set("English", forKey: "defaultLanguageName")
        UserDefaults.standard.set(false, forKey: "isAddClose")
        UserDefaults.standard.set(false, forKey: "isTrackInList")
        UserDefaults.standard.synchronize()
        SKPaymentQueue.default().add(self)
        if #available(iOS 13.0, *) {
                   // In iOS 13 setup is done in SceneDelegate
                   window?.overrideUserInterfaceStyle = .light
               }
        makeRootViewController()
        self.getiOSVesion()
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "ARswuW9o6ywVQyEu1PeAtkRbjDmNeZ2MxBVVaugHNrKs6T6z5vIiOdCdjnQdFllEkDWGiXJazdGlDm_T", PayPalEnvironmentSandbox: "AaB62DObyNRAYyCQEDs7SNOHkdau-0FfAM931AmN6syG_yRPGFQJC_GBsSeKkDbc8dtBci_jDCE3scqz"])
       // checkUserLogin()
        //userNotification
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerForPushNotifications()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
            
        }
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                
            }
        }
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //let notificationType = userInfo["gcm.notification.type"] as? String
        //print("notificationType",notificationType)
        application.registerForRemoteNotifications()
        self.musicpalyerOnNotificationBar()
        return true
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return myOrientation
    }
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /*-------------------------upgrade version alert---------------------------*/
    func checkUpdate() {
        DispatchQueue.global().async {
            do {
                let update = try self.isUpdateAvailable()
                if update {
                    DispatchQueue.main.async {
                        self.alert()
                    }
                }
            } catch {
                print(error)
            }
        }

    }
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    func alert(){
        // 1. Call to update to check if feature is enabled for updating the app
        //if (FeaturesIsEnabled) {
        //  then only show the popup
        //} else
        //{
        //  if not, don't execute the code
        //}
        

            let alertMessage = "A new version of Ask Bhagwan is availabel.Please update to latest version now."
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if let url = URL(string: "https://itunes.apple.com/us/app/ask-o-s-h-o/id1434058636?ls=1&mt=8"),
                    UIApplication.shared.canOpenURL(url){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
//            let noBtn = UIAlertAction(title:"Skip" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
//            })
            alert.addAction(okBtn)
            //alert.addAction(noBtn)
            SVProgressHUD.dismiss()
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    func makeRootViewController() {
        if UserDefaults.standard.value(forKey: "id") != nil {
          // let saveValue = UserDefaults.standard.bool(forKey: "isLogin")
          // if saveValue {
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let tabbarVC = storyboard.instantiateViewController(withIdentifier: "reval") as! SWRevealViewController
               let navigationController = UINavigationController()
               
               navigationController.navigationBar.isTranslucent = false
               navigationController.navigationBar.isHidden = true
               navigationController.pushViewController(tabbarVC, animated: true)
               self.window?.rootViewController = navigationController
               self.window?.makeKeyAndVisible()
            if let idds = UserDefaults.standard.value(forKey: "id") {
                getUserInfo(id: idds as! String)
            }
           }else {
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let tabbarVC = storyboard.instantiateViewController(withIdentifier: "login") as! LoginTableViewController
               let navigationController = UINavigationController()
               navigationController.navigationBar.isTranslucent = false
               navigationController.navigationBar.isHidden = true
               navigationController.pushViewController(tabbarVC, animated: true)
               self.window?.rootViewController = navigationController
               self.window?.makeKeyAndVisible()
           }
       }
    
    func getiOSVesion() {
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,iOS_VERSION )
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    print("itemss",itemss)
                let dic :[String : AnyObject]
                    
                dic = itemss.value(forKey: "resultObject") as! [String : AnyObject]
                let version : String?
                version = dic["version"] as! String
               // print("version",version)
                let AppVersion : String?
                AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
                if AppVersion! < version! {
                    self.checkUpdate()
                }else {
                    print("no update")
                }
        }
    }
    
    func checkUserLogin(){
        var users = [NSManagedObject]()
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            users = results as! [NSManagedObject]
            if results.count == 0 {
                
            } else {
                if let idds = users[0].value(forKey: "user_id") {
                    GLOBAL_USER_ID = idds  as? NSNumber
                    let idss = GLOBAL_USER_ID.stringValue
                    getUserInfo(id: idss)
                }
            }
        } catch {
            print("Fetch Failed")
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
    func musicpalyerOnNotificationBar () {
        let mpic = MPNowPlayingInfoCenter.default()
        
        func setInfoCenterCredentials(_ postion: NSNumber, _ duration: NSNumber, _ playbackState: Int) {
            
            mpic.nowPlayingInfo = [ MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                                    MPMediaItemPropertyPlaybackDuration: duration,
                                    MPNowPlayingInfoPropertyPlaybackRate: playbackState]
        }
    }
    
    func userInAppSubscriptionSaveUser(){
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_iOS_ADD_INAPP_SUBSCRIPTION)
        print("urlResponce",urlResponce)
        if let  userId = GLOBAL_USER_ID {
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"userId":userId.stringValue,"materId": 1,"orderId": "","productId": "","purchaseState": "","developerPayload": "","purchaseToken": ""])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success :
                        print("subscription_response",response)
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        DispatchQueue.main.async {
                            //self.present(alert, animated: true, completion: nil)
                        }
                    }
            }

        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print ("APP BACKGRD-OFF")
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
        print ("APP BACKGRD")
        APP_BACKGROUND = true
    }

    @objc func callBack(){
      //  self.logout()
    }
    func logout(){
        UserDAO.clearDefaultUser()
        UserDefaults.standard.removeObject(forKey: "UserLoggedIn")
        UserDefaults.standard.removeObject(forKey: "stateName")
        UserDefaults.standard.removeObject(forKey: "countryName")
        UserDefaults.standard.removeObject(forKey: "isPurchased")
        UserDefaults.standard.removeObject(forKey: "isCountryPopUpShown")
        // self._stk_audioPlayer.stop()
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        GLOBAL_USER_ID = nil
        //print(GLOBAL_USER_ID)
        do {
            
            let results = try context.fetch(request)
            let user = results as! [NSManagedObject]
            
            if results.count == 0 {
                
            } else {
            }
            
        } catch {
            print("Fetch Failed")
        }
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print ("APP BACKGRD-OF1F")
        APP_BACKGROUND = false
        //Siren.shared.checkVersion(checkType: .immediately)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print ("APP BACKGRD-OF2F")
        self.getiOSVesion()
        APP_BACKGROUND = false
        
        //Siren.shared.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appteve.spotimusic" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "spotimusic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if (isPlayings){
            
        } else {
            
            if event!.type == .remoteControl {
                switch event!.subtype {
                case .remoteControlPlay:
                    AudioPlayer.sharedAudioPlayer.resume()
                case .remoteControlPause:
                    AudioPlayer.sharedAudioPlayer.pause()
                case .remoteControlTogglePlayPause:
                    //AudioPlayer.sharedAudioPlayer.togglePlayPause()
                    self.set()
                case .remoteControlPreviousTrack:
                    AudioPlayer.sharedAudioPlayer.previousTrack(true)
                case .remoteControlNextTrack:
                    AudioPlayer.sharedAudioPlayer.nextTrack(true)
                default: break
                }
            }
        }
    }

    func set(){
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
        case
        STKAudioPlayerState.playing:
            AudioPlayer.sharedAudioPlayer.pause()
            case
            STKAudioPlayerState.paused :
            AudioPlayer.sharedAudioPlayer.resume()
        default: break
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print("userInfo",userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            
            //            let notify = Notification.Name(rawValue: "popUp")
            //            NotificationCenter.default.post(name: notify, object: nil)
            //            Notification.ob
        }
        
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    UserDefaults.standard.synchronize()
                        self.userInAppSubscriptionSaveUser()
                    if UserDefaults.standard.bool(forKey: IN_APP_FROM_HOME) {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_HOME_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }else {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_CATEGORY_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                    print("Product Purchased")
                    //Do unlocking etc stuff here in case of new purchase
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .failed:
                    print("Purchased Failed");
                    if UserDefaults.standard.bool(forKey: IN_APP_FROM_HOME) {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_HOME_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }else {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_CATEGORY_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    UserDefaults.standard.synchronize()
                    if UserDefaults.standard.bool(forKey: IN_APP_FROM_HOME) {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_HOME_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }else {
                        let notificationName = Notification.Name(IN_APP_PURCHASE_SUCCESS_CATEGORY_NOTIFICATION)
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                    break;
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {        
    }
}
//@available(iOS 10.0, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
        // Enable or disable features based on authorization.
        }
       // let center = UNUserNotificationCenter.current()
       let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        print("User Info = ",notification.request.content.userInfo)
        // print("Notification data: \(response.notification.request.content.userInfo)")
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
           // print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
       // print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
    }
}
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token:123 \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
