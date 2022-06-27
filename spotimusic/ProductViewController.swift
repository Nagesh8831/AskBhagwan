//
//  ProductViewController.swift
//  spotimusic
//
//  Created by Mac on 16/05/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import  SVProgressHUD
import SCLAlertView
import Agrume
import GoogleMobileAds
class ProductViewController: BaseViewController {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var producttableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    var reachabilitysz: Reachability!
    var productArray = [[String : AnyObject]]()
    var refreshControl :UIRefreshControl!
    var rewardedAd1: GADRewardedAd?
    var subscriptionStatus  = false
    var adsTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "ProductTableViewCell", bundle: nil)
        self.producttableView.register(nib, forCellReuseIdentifier: "ProductTableViewCell")
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
       // reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{
            //self.checkUserLogin()
            
        } else {
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_w.png"), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(ProductViewController.pullToRefreshHandler), for: .valueChanged)
        self.producttableView.addSubview(self.refreshControl)
        // Do any additional setup after loading the view.
    }
    @objc func callBack(){
          subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
              if subscriptionStatus == true {
                  print("User subscribed")
              }else {
                showAdds()
                //IronSource.showRewardedVideo(with: self)
              }
//        //rewarde ads
//        rewardedAd1 = GADRewardedAd(adUnitID: TEST_REWARD_ADD_UNIT_ID)
//         rewardedAd1?.load(GADRequest()) { error in
//             if let error = error {
//               // Handle ad failed to load case.
//             } else {
//               // Ad successfully loaded.
//             }
//           }
//        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
//            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
//        }
//       // self.showRewaredAds()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Classifieds"
        self.getAllProducts()
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if touches = producttableView {
//            producttableView.isUserInteractionEnabled = true
//
//        }
//    }
    @objc func pullToRefreshHandler() {
        self.getAllProducts()
        self.producttableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    func adjustContentSize(text: UITextView){
        text.contentInset = UIEdgeInsets(top: 0, left: text.contentInset.left, bottom: 0,right: text.contentInset.right)
    }
    func getAllProducts(){
    SVProgressHUD.show()
    SVProgressHUD.setForegroundColor(UIColor.white)
    SVProgressHUD.setBackgroundColor(UIColor.clear)
    let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_PRODUCT_SEARCH)
   // print("urlResponce",urlResponce)
    Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm":"","limit":10000,"offset":0])

    .responseJSON { response in
    SVProgressHUD.dismiss()
    switch response.result {
    case .success :
   // print("Product_response",response)
    guard let itms = response.result.value else {return}
    let itemss = itms as! NSDictionary
    self.productArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
    if self.productArray.count > 0 {
    DispatchQueue.main.async() {
    self.producttableView!.reloadData()
    self.noDataLabel.isHidden = true
    self.producttableView!.isHidden = false
    }
    } else {
        self.view.bringSubviewToFront(self.noDataLabel)
    self.noDataLabel.isHidden = false
    // self.noDataLabel.text = "No Jokes file found"
    self.producttableView!.isHidden = true
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProductViewController :UITableViewDelegate,UITableViewDataSource,UITextViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return productArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.descriptionTextView.isScrollEnabled = true
        cell.descriptionTextView.isEditable = false
        //self.adjustContentSize(text: cell.descriptionTextView)
        cell.descriptionTextView.contentInset = UIEdgeInsets(top: 0,left: -5,bottom: 0,right: 0);
        cell.contactDetailsTextView.contentInset = UIEdgeInsets(top: 0,left: -5,bottom: 0,right: 0);
        cell.contactDetailsTextView.isScrollEnabled = true
        cell.contactDetailsTextView.isEditable = false
         cell.imageDataArray.removeAll()
        self.configureCellForImageVideoPreview(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 490.0
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        producttableView.isUserInteractionEnabled = false
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        producttableView.isUserInteractionEnabled = true
    }
}

extension ProductViewController :  UserWallDelegate{
func configureCellForImageVideoPreview(cell: ProductTableViewCell , indexPath: IndexPath) {

    cell.delegate = self
    let mainDta = self.productArray[indexPath.row] as NSDictionary
    if let product = mainDta.value(forKey: "title") as? String{
        cell.productNameLabel.text = product
    }
    if let owner = mainDta.value(forKey: "owner_india") as? String{
        cell.contactDetailsTextView.text = owner
    }
    if let des = mainDta.value(forKey: "description") as? String{
        cell.descriptionTextView.text = des
    }
    if let imagArray1 = mainDta.value(forKey: "images") as? [[String:AnyObject]]{
       cell.imageDataArray = imagArray1
        if cell.imageDataArray.count == 1{
                            cell.singleImageView.isHidden = false
                            cell.secondImagesView.isHidden = true
                            cell.threeImagesView.isHidden = true
                            cell.fourImagesView.isHidden = true
                            cell.moreImagesButton.isHidden = true
                            let urls = cell.imageDataArray[0]["url"] as! String
                            let imgeFile1 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,urls)
                            let url1 = URL(string: imgeFile1)
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.singaleImage {
                                    cell.singaleImage.kf.setImage(with: url1, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.singaleImage.tag = indexPath.row
                            let tapGestureRecognizer1 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction1(_:)))
                            cell.singaleImage.isUserInteractionEnabled = true
                            cell.singaleImage.addGestureRecognizer(tapGestureRecognizer1)
            
        }else if cell.imageDataArray.count == 2 {
                            cell.singleImageView.isHidden = true
                            cell.secondImagesView.isHidden = false
                            cell.threeImagesView.isHidden = true
                            cell.fourImagesView.isHidden = true
                            cell.moreImagesButton.isHidden = true
                            let urlss = cell.imageDataArray[0]["url"] as! String
                            let imgeFile1 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,urlss)
                            let url1 = URL(string: imgeFile1)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.secondOneImageView {
                                    cell.secondOneImageView.kf.setImage(with: url1, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.secondOneImageView.tag = indexPath.row
                            let tapGestureRecognizer1 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction1(_:)))
                            cell.secondOneImageView.isUserInteractionEnabled = true
                            cell.secondOneImageView.addGestureRecognizer(tapGestureRecognizer1)
                            let urlsss = cell.imageDataArray[1]["url"] as! String
                            let imgeFile2 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,urlsss)
                            let url2 = URL(string: imgeFile2)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.secondTwoImageView {
                                    cell.secondTwoImageView.kf.setImage(with: url2, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
            
                            cell.secondTwoImageView.tag = indexPath.row
                            let tapGestureRecognizer2 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction2(_:)))
                            cell.secondTwoImageView.isUserInteractionEnabled = true
                        cell.secondTwoImageView.addGestureRecognizer(tapGestureRecognizer2)
        }else if cell.imageDataArray.count == 3 {
                            cell.singleImageView.isHidden = true
                            cell.secondImagesView.isHidden = true
                            cell.threeImagesView.isHidden = false
                            cell.fourImagesView.isHidden = true
                            cell.moreImagesButton.isHidden = true
                             let url35 = cell.imageDataArray[0]["url"] as! String
                            let imgeFile1 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url35)
                            let url1 = URL(string: imgeFile1)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.thirdOneFImageView {
                                    cell.thirdOneFImageView.kf.setImage(with: url1, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.thirdOneFImageView.tag = indexPath.row
                            let tapGestureRecognizer1 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction1(_:)))
                            cell.thirdOneFImageView.isUserInteractionEnabled = true
                            cell.thirdOneFImageView.addGestureRecognizer(tapGestureRecognizer1)
                           let url31 = cell.imageDataArray[1]["url"] as! String
                            let imgeFile2 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url31)
                            let url2 = URL(string: imgeFile2)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.thirdTwoView {
                                    cell.thirdTwoView.kf.setImage(with: url2, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.thirdTwoView.tag = indexPath.row
                            let tapGestureRecognizer2 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction2(_:)))
                            cell.thirdTwoView.isUserInteractionEnabled = true
                            cell.thirdTwoView.addGestureRecognizer(tapGestureRecognizer2)
                             let url32 = cell.imageDataArray[2]["url"] as! String
                            let imgeFile3 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url32)
                            let url33 = URL(string: imgeFile3)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.thirdThreeView {
                                    cell.thirdThreeView.kf.setImage(with: url33, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                                cell.thirdThreeView.tag = indexPath.row
                                let tapGestureRecognizer3 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction3(_:)))
                                cell.thirdThreeView.isUserInteractionEnabled = true
                                cell.thirdThreeView.addGestureRecognizer(tapGestureRecognizer3)
        }else if cell.imageDataArray.count == 4 {
                            cell.singleImageView.isHidden = true
                            cell.secondImagesView.isHidden = true
                            cell.threeImagesView.isHidden = true
                            cell.fourImagesView.isHidden = false
                            cell.moreImagesButton.isHidden = true
                            let url41 = cell.imageDataArray[0]["url"] as! String
                            let imgeFile1 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url41)
                            let url_41 = URL(string: imgeFile1)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.fourthOneImageView {
                                    cell.fourthOneImageView.kf.setImage(with: url_41, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.fourthOneImageView.tag = indexPath.row
                            let tapGestureRecognizer1 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction1(_:)))
                            cell.fourthOneImageView.isUserInteractionEnabled = true
                            cell.fourthOneImageView.addGestureRecognizer(tapGestureRecognizer1)
                             let url42 = cell.imageDataArray[1]["url"] as! String
                            let imgeFile2 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url42)
                            let url_42 = URL(string: imgeFile2)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.fourthTwoImageView {
                                    cell.fourthTwoImageView.kf.setImage(with: url_42, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.fourthTwoImageView.tag = indexPath.row
                            let tapGestureRecognizer2 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction2(_:)))
                            cell.fourthTwoImageView.isUserInteractionEnabled = true
                            cell.fourthTwoImageView.addGestureRecognizer(tapGestureRecognizer2)
                            let url3 = cell.imageDataArray[2]["url"] as! String
                            let imgeFile3 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url3)
                            let url33 = URL(string: imgeFile3)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.fourthThreeImageView {
                                    cell.fourthThreeImageView.kf.setImage(with: url33, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                                cell.fourthThreeImageView.tag = indexPath.row
                                let tapGestureRecognizer3 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction3(_:)))
                                cell.fourthThreeImageView.isUserInteractionEnabled = true
                                cell.fourthThreeImageView.addGestureRecognizer(tapGestureRecognizer3)
                            let url4 = cell.imageDataArray[3]["url"] as! String
                            let imgeFile44 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url4)
                            let url44 = URL(string: imgeFile44)
            
                            DispatchQueue.main.async(execute: {
                                if let _ = cell.fourthFourImageView {
                                    cell.fourthFourImageView.kf.setImage(with: url44, placeholder: UIImage(named: "os_ho.jpg"))
                                }
                            })
                            cell.fourthFourImageView.tag = indexPath.row
                            let tapGestureRecognizer4 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction4(_:)))
                            cell.fourthFourImageView.isUserInteractionEnabled = true
                            cell.fourthFourImageView.addGestureRecognizer(tapGestureRecognizer3)
        }else {
            cell.singleImageView.isHidden = true
            cell.secondImagesView.isHidden = true
            cell.threeImagesView.isHidden = true
            cell.fourImagesView.isHidden = false
            cell.moreImagesButton.isHidden = false
            let url41 = cell.imageDataArray[0]["url"] as! String
            let imgeFile1 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url41)
            let url_41 = URL(string: imgeFile1)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.fourthOneImageView {
                    cell.fourthOneImageView.kf.setImage(with: url_41, placeholder: UIImage(named: "os_ho.jpg"))
                }
            })
            cell.fourthOneImageView.tag = indexPath.row
            let tapGestureRecognizer1 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction1(_:)))
            cell.fourthOneImageView.isUserInteractionEnabled = true
            cell.fourthOneImageView.addGestureRecognizer(tapGestureRecognizer1)
            
            let url42 = cell.imageDataArray[1]["url"] as! String
            let imgeFile2 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url42)
            let url_42 = URL(string: imgeFile2)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.fourthTwoImageView {
                    cell.fourthTwoImageView.kf.setImage(with: url_42, placeholder: UIImage(named: "os_ho.jpg"))
                }
            })
            cell.fourthTwoImageView.tag = indexPath.row
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction2(_:)))
            cell.fourthTwoImageView.isUserInteractionEnabled = true
            cell.fourthTwoImageView.addGestureRecognizer(tapGestureRecognizer2)
            
            let url3 = cell.imageDataArray[2]["url"] as! String
            let imgeFile3 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url3)
            let url33 = URL(string: imgeFile3)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.fourthThreeImageView {
                    cell.fourthThreeImageView.kf.setImage(with: url33, placeholder: UIImage(named: "os_ho.jpg"))
                }
            })
            cell.fourthThreeImageView.tag = indexPath.row
            let tapGestureRecognizer3 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction3(_:)))
            cell.fourthThreeImageView.isUserInteractionEnabled = true
            cell.fourthThreeImageView.addGestureRecognizer(tapGestureRecognizer3)
            let url4 = cell.imageDataArray[3]["url"] as! String
            let imgeFile44 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,url4)
            let url44 = URL(string: imgeFile44)
            
            DispatchQueue.main.async(execute: {
                if let _ = cell.fourthFourImageView {
                    cell.fourthFourImageView.kf.setImage(with: url44, placeholder: UIImage(named: "os_ho.jpg"))
                }
            })
            cell.fourthFourImageView.tag = indexPath.row
            let tapGestureRecognizer4 = UITapGestureRecognizer(target: cell, action: #selector(cell.oneImageButtonAction4(_:)))
            cell.fourthFourImageView.isUserInteractionEnabled = true
            cell.fourthFourImageView.addGestureRecognizer(tapGestureRecognizer4)
            cell.moreImagesButton.tag = indexPath.row
            cell.moreImagesButton.addTarget(cell, action: #selector(cell.showMoreImages), for:.touchUpInside)
        }
        
        
    }
        
    }
    func previewImages(images: [[String : String]], startIndexURl: String) {
        var urlArray = Array<String>()
        for i in 0 ..< images.count {
           // self.isNotfromPreview = false
            if let img = images[i]["url"] {
                let imgeFile3 = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,PRODUCT,img)
                //let url33 = URL(string: imgeFile3)
                urlArray.append(imgeFile3)
            }
        }
        var startindex = 0
        var urls = Array<URL>()
        for i in 0 ..< urlArray.count {
            if urlArray[i] == startIndexURl {
                startindex = i
            }
            if let url = URL(string: urlArray[i]) {
                urls.append(url)
            }
        }
        let agrume = Agrume.init(urls: urls, startIndex: startindex, background: .blurred(.regular), dismissal: .withPhysics)
            
            
           // Agrume.init(imageUrls: urls, startIndex: startindex, backgroundBlurStyle: .none, backgroundColor: UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 0.8))
       // let agrume = Agrume.init(imageUrl: urls)
        agrume.statusBarStyle = .lightContent
        agrume.show(from: self)
    }
}

//extension  ProductViewController : GADRewardedAdDelegate {
//    /// Tells the delegate that the user earned a reward.
//    override func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
//      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
//    }
//    /// Tells the delegate that the rewarded ad was presented.
//    override func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
//      print("Rewarded ad presented.")
//    }
//    /// Tells the delegate that the rewarded ad was dismissed.
//    override func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
//      print("Rewarded ad dismissed.")
//    }
//    /// Tells the delegate that the rewarded ad failed to present.
//    override func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
//      print("Rewarded ad failed to present.")
//    }
//}
