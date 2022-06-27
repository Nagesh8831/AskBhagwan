//
//  AudioViewController.swift
//  spotimusic
//           0ec13c
//  Created by BQ_Tech on 09/07/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import  SCLAlertView
class AudioVideoViewController: BaseViewController ,UICollectionViewDelegate,UICollectionViewDataSource,languageDelegate{

    @IBOutlet weak var languageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var languageButton: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var audioVideoCollectionView: UICollectionView!

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var langButton: UIImageView!

    @IBOutlet weak var discourseView: UIView!
    @IBOutlet weak var discourseTableView: UITableView!
    @IBOutlet weak var search: UISearchBar!
    var btn1 = UIButton(type: .custom)
    var mainCategory: String?
    var homeCategory: String?
    var fileType: String?
    var categoryArray = [[String:AnyObject]]()
    var discoursesArray = [[String:AnyObject]]()
    var categoryVideoArray = [[String:AnyObject]]()
    var discoursesVideoArray = [[String:AnyObject]]()
    var categoty : String?
    var subscriptionStatus  = false
    var album_id : String?
    var album_Name : String?
    var album_name : String?
    var media_type_id : String?
    var isDiscourses = false
    var isQA = true
    var users = [NSManagedObject]()
    var userId : UserData!
    var searchText = ""
    var searchActive = false
    var reachabilitysz: Reachability!
    var isFilterActive = false
    var filterValue = false
    var adsTimer: Timer!
    let  categoryNames = [ "Love","Spiritual","Religion","Relationship", "Motherhood","Freedom","Friendship","Education","Sex","Marriage","Politics","Mystics","Buddha","Feminism","Birth Control","Sufism","Tantra","Zen","Science","Astrology", "Nature", "God","Family", "Communism","kirtan"]

    override func viewDidLoad() {
        super.viewDidLoad()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        discoursesArray.removeAll()
        categoryArray.removeAll()
        discourseView.isHidden = true
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        // reachabilitysz = Reachability()
        do {
            reachabilitysz = try Reachability()
        }catch{

        }
        if let textfield = search.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.gray
        }
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RED_COLOR as Any], for: .selected)
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

        //reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{

        } else {

        }
        self.discourseTableView.register(UINib(nibName: "DiscourseTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscourseTableViewCell")

        let nib = UINib(nibName: "CommonCollectionViewCell", bundle: nil)
        self.audioVideoCollectionView.register(nib, forCellWithReuseIdentifier: "commonCell")
        categoty = UserDefaults.standard.value(forKey: "category") as? String
        if categoty == "Audio" {
            self.title = "Audio"
            if isQA {
                segmentControl.selectedSegmentIndex = 0
                self.getAllAudioCategoryOfQA()
            } else {
                segmentControl.selectedSegmentIndex = 1
                self.getAllVideoCategoryOfQA()
            }
        }else {
            self.title = "Video"
            //self.getAllVideoCategoryOfQA()
            if isQA {
                segmentControl.selectedSegmentIndex = 0
                self.getAllVideoCategoryOfQA()
            } else {
                segmentControl.selectedSegmentIndex = 1
                self.getAllVideoCategoryOfQA()
            }
        }
    }
    @objc func callBack() {
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showAdds()
            //IronSource.showRewardedVideo(with: self)
        }
    }

    deinit {
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        discourseTableView.reloadData()
    }
    @IBAction func filterButtonAction(_ sender: UIButton) {
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        discoursesArray.removeAll()
        categoryArray.removeAll()
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            filterButton.setImage(UIImage(named:"filterOn"), for: .normal)
            self.isFilterActive = true
            self.filterLabel.textColor = RED_COLOR
            //discourseTableView.reloadData()
        } else {
            filterButton.setImage(UIImage(named:"filterOff"), for: .normal)
            self.isFilterActive = false
            self.filterLabel.textColor = UIColor.white
            //discourseTableView.reloadData()
        }
        if categoty == "Audio" {
            self.getAllAudioCategoryOfDiscourses(searchText)
        } else {
            self.getAllVideoCategoryOfDiscourses(searchText)
        }
    }
    //Audio Qution & answer
    func getAllAudioCategoryOfQA(){
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        SVProgressHUD.show()
        discoursesArray.removeAll()
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_MEDIA)
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                    // print("Dashboard_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.categoryArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]
                    if self.categoryArray.count > 0 {
                        //print("Array_response",self.audioArray)
                        DispatchQueue.main.async() {
                            self.audioVideoCollectionView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.audioVideoCollectionView!.isHidden = false
                        }
                    } else {
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No songs found for selected language"
                        self.audioVideoCollectionView!.isHidden = true
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

    //Audio Discourses
    func getAllAudioCategoryOfDiscourses(_ search_Text : String){
        SVProgressHUD.show()
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        if searchActive {
            searchText = search_Text
        }else {
            searchText = ""
        }
        if isFilterActive {
            filterValue = true
        }else {
            filterValue = false
        }
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_AUDIO_QA_DISCOURSES)
        print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : searchText,"quedisc":2,"album_id": album_id!,"limit":5000,"offset":0,"should_orderby_name": true,"timelinefilter":filterValue])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :

                   // print("Discource_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.discoursesArray = itemss.value(forKey: "respon") as! [[String:AnyObject]]

                    if self.discoursesArray.count > 0 {
                        //print("Array_response",self.audioArray)
                        DispatchQueue.main.async() {
                            self.audioVideoCollectionView!.reloadData()
                            self.discourseTableView.reloadData()
                            self.noDataLabel.isHidden = true
                            self.audioVideoCollectionView!.isHidden = true
                            self.discourseTableView.isHidden = false
                        }
                    } else {
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No songs found for selected language"
                        self.audioVideoCollectionView!.isHidden = true
                        self.discourseTableView.isHidden = true
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

    //Video Qution & answer
    func getAllVideoCategoryOfQA(){
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        SVProgressHUD.show()
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_MEDIA)
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :

                    //print("Dashboard_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.categoryVideoArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.categoryVideoArray.count > 0 {
                        //print("Array_response",self.audioArray)
                        DispatchQueue.main.async() {
                            self.audioVideoCollectionView!.reloadData()
                            self.noDataLabel.isHidden = true
                            self.audioVideoCollectionView!.isHidden = false
                        }
                    } else {
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No songs found for selected language"
                        self.audioVideoCollectionView!.isHidden = true

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
    //Video Discourses
    func getAllVideoCategoryOfDiscourses(_ search_Text : String){
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        if searchActive {
            searchText = search_Text
        }else {
            searchText = ""
        }
        if isFilterActive {
            filterValue = true
        }else {
            filterValue = false
        }
        SVProgressHUD.show()
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_VIDEO_QA_DISCOURSES)
        // print(urlResponce)
        Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"searchterm" : searchText,"quedisc":2,"album_id": album_id!,"limit":500,"offset":0,"should_orderby_name": true,"timelinefilter":filterValue])
            .responseJSON { response in
                SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                     //print("DiscourceVideo_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.discoursesVideoArray = itemss.value(forKey: "respon") as! [[String : AnyObject]]
                    if self.discoursesVideoArray.count > 0 {
                        //print("Array_response",self.audioArray)
                        DispatchQueue.main.async() {
                            self.audioVideoCollectionView!.reloadData()
                            self.discourseTableView.reloadData()
                            self.noDataLabel.isHidden = true
                            self.audioVideoCollectionView!.isHidden = true
                            self.discourseTableView.isHidden = false
                        }
                    } else {
                        self.view.bringSubviewToFront(self.noDataLabel)
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = "No songs found for selected language"
                        self.audioVideoCollectionView!.isHidden = true
                        self.discourseTableView.isHidden = true
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


    override func viewWillAppear(_ animated: Bool) {
        subscriptionStatus = UserDefaults.standard.bool(forKey: "subscriptionStatus")
        if subscriptionStatus == true {
            print("User subscribed")
        }else {
            showPreSubscriptionPopUp()
        }
        adsTimer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: true)
        categoryArray.removeAll()
        discoursesArray.removeAll()
        discoursesVideoArray.removeAll()
        categoryVideoArray.removeAll()
        audioVideoCollectionView.reloadData()
        album_id = UserDefaults.standard.string(forKey: "defaultLanguageId")
        langLabel.text = UserDefaults.standard.string(forKey: "defaultLanguageName")
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

        if  self.isQA == true {
            self.languageViewHeight.constant = 0
            self.languageView.isHidden = true
            self.languageButton.isEnabled = false
            self.languageButton.tintColor = UIColor.clear
        }else {
            //self.languageViewHeight.constant = 0
            self.languageView.isHidden = false
            self.languageButton.isEnabled = true
        }
        langLabel.textAlignment = .right


        if categoty == "Audio"  || categoty == "Video"  {
            if isQA{
                self.languageView.isHidden = true
                self.languageButton.isEnabled = false
                self.languageButton.tintColor = UIColor.clear
            }
        }
        if categoty == "Audio" {
            if !isQA {
                self.getAllAudioCategoryOfDiscourses(searchText)
            } else {
                self.getAllAudioCategoryOfQA()
            }
        } else {
            if !isQA {
                self.getAllVideoCategoryOfDiscourses(searchText)
            } else {
                self.getAllVideoCategoryOfQA()
            }
        }

        segmentControl.addTarget(self, action: #selector (tapSegment), for:.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
    }

    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        adsTimer.invalidate()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
        album_id = nil
        self.isFilterActive = false
    }

    @objc func tapSegment(sender: UISegmentedControl) {
        // Action for touchDown-Event on an already selected segment
        if categoty == "Audio" {
            if sender.selectedSegmentIndex == 0 {
                self.isQA = true
                self.languageViewHeight.constant = 0
                self.languageView.isHidden = true
                self.languageButton.isEnabled = false
                self.languageButton.tintColor = UIColor.clear
                self.getAllAudioCategoryOfQA()
                self.discourseView.isHidden = true
                self.audioVideoCollectionView.isHidden = false
                discoursesVideoArray.removeAll()
                categoryVideoArray.removeAll()
            }else {
                self.isQA = false
                self.languageViewHeight.constant = 60
                self.languageView.isHidden = false
                self.languageButton.isEnabled = true
                self.languageButton.tintColor = UIColor.white
                self.getAllAudioCategoryOfDiscourses(searchText)
                self.discourseView.isHidden = false
                self.audioVideoCollectionView.isHidden = true
            }
        }else {
            if sender.selectedSegmentIndex == 0 {
                self.isQA = true
                self.languageViewHeight.constant = 0
                self.languageView.isHidden = true
                self.languageButton.isEnabled = false
                self.languageButton.tintColor = UIColor.clear
                self.getAllVideoCategoryOfQA()
                self.discourseView.isHidden = true
                self.audioVideoCollectionView.isHidden = false
                discoursesVideoArray.removeAll()
                categoryVideoArray.removeAll()
            }else {
                self.isQA = false
                self.languageViewHeight.constant = 60
                self.languageView.isHidden = false
                self.languageButton.isEnabled = true
                self.languageButton.tintColor = UIColor.white
                self.getAllVideoCategoryOfDiscourses(searchText)
                self.discourseView.isHidden = false
                self.audioVideoCollectionView.isHidden = true
            }
        }

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if categoty == "Audio" {
            return self.categoryArray.count
            /* if self.isQA {
             if ((categoryArray) != nil)  {
             //print("self.categoryArray.count",self.categoryArray.count)
             return self.categoryArray.count
             }
             } else{
             if ((discoursesArray) != nil)  {
             //print("self.categoryArray.count",self.discoursesArray.count)
             return self.discoursesArray.count
             }
             }*/
        }else {
            return self.categoryVideoArray.count
            /*if self.isQA {
             if ((categoryVideoArray) != nil)  {
             //print("self.categoryArray.count",self.categoryArray.count)
             return self.categoryVideoArray.count
             }
             } else{
             if ((discoursesVideoArray) != nil)  {
             //print("self.categoryArray.count",self.discoursesArray.count)
             return self.discoursesVideoArray.count
             }
             }*/
        }


        // return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commonCell", for: indexPath) as! CommonCollectionViewCell
        if categoty == "Audio" {
            //if self.isQA {
            let mainDta = self.categoryArray[indexPath.row] as NSDictionary
            let name = mainDta.value(forKey: "name") as? String

            let imageUrl = mainDta.value(forKey: "image_url") as? String

            let imgeFile = String(format: "%@%@%@",BASE_URL_BACKEND,UPLOAD_MEDIA_IMAGE_QA_DISCOURSES,imageUrl!)
            //print("imgeFile",imgeFile)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = cell.categoryImageView {
                        cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
                cell.categotyNameLabel.text = name
            })
            /* } else {

             let mainDta = self.discoursesArray[indexPath.row] as NSDictionary
             let name = mainDta.value(forKey: "name") as? String

             let imageUrl = mainDta.value(forKey: "cover") as? String

             let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
             DispatchQueue.main.async(execute: {
             if let url = URL(string: imgeFile){
             if let _ = cell.categoryImageView {
             cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
             }
             }
             cell.categotyNameLabel.text = name
             })
             }*/
        } else {
            //if self.isQA {
            let mainDta = self.categoryVideoArray[indexPath.row] as! NSDictionary
            let name = mainDta.value(forKey: "name") as? String
            let imageUrl = mainDta.value(forKey: "image_url") as? String
            let imgeFile = String(format: "%@%@%@",BASE_URL_BACKEND,UPLOAD_MEDIA_IMAGE_QA_DISCOURSES,imageUrl!)
            // print("imagePath",imgeFile)
            let url = URL(string: imgeFile)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = cell.categoryImageView {
                        cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
                cell.categotyNameLabel.text = name
            })
            /* } else {
             let mainDta = self.discoursesVideoArray[indexPath.row] as! NSDictionary
             let name = mainDta.value(forKey: "name") as? String
             let imageUrl = mainDta.value(forKey: "cover") as? String
             let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
             DispatchQueue.main.async(execute: {
             if let url = URL(string: imgeFile){
             if let _ = cell.categoryImageView {
             cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
             }
             }
             cell.categotyNameLabel.text = name
             })
             }*/
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if categoty == "Audio"{
            if self.isQA {

                if subscriptionStatus == true {
                    print("User subscribed")
                }else {
                    //showAdds()
                   // IronSource.showRewardedVideo(with: self)
                }


                let mainDta = self.categoryArray[indexPath.row] as! NSDictionary
                let  mediaId = mainDta.value(forKey: "id") as? String
                let name = mainDta.value(forKey: "name") as? String
                // print("mediaId",mediaId)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategorywiseSearchVideoAudioViewController") as! CategorywiseSearchVideoAudioViewController
                vc.media_type_id = mediaId
                vc.name = name;
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
                //self.showAd()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommonDiscouresDispalyViewController") as! CommonDiscouresDispalyViewController
                let mainDta = self.discoursesArray[indexPath.row] as! NSDictionary
                let name = mainDta.value(forKey: "name") as? String
                let imageUrl = mainDta.value(forKey: "cover") as? String
                vc.discourseName = name
                vc.albumId = album_id
                vc.discourseImageName = imageUrl
                vc.isFromVideoDiscorse = false
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                DispatchQueue.main.async(execute: {
                    if let url = URL(string: imgeFile){
                        if let _ = vc.discouresIamgeView {
                            vc.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    }
                })
                self.navigationController?.pushViewController(vc, animated: true)
            }

        } else {

            if self.isQA {
                //self.showAd()
                //DispatchQueue.main.async(execute: {

                if subscriptionStatus == true {
                    print("User subscribed")
                }else {
                   // showAdds()
                    //IronSource.showRewardedVideo(with: self)
                }

                //})
                let mainDta = self.categoryVideoArray[indexPath.row] as! NSDictionary
                let  mediaId = mainDta.value(forKey: "id") as? String
                let name = mainDta.value(forKey: "name") as? String
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategorywiseSearchVideoAudioViewController") as! CategorywiseSearchVideoAudioViewController
                vc.media_type_id = mediaId
                vc.name = name
                categoryVideoArray.removeAll()
                discoursesVideoArray.removeAll()
                self.navigationController?.pushViewController(vc, animated: false)
                //self.present(vc, animated: true, completion: nil)
            } else {
                // self.showAd()
                //                DispatchQueue.main.async(execute: {

                if subscriptionStatus == true {
                    print("User subscribed")
                }else {
                    //showAdds()
                    //IronSource.showRewardedVideo(with: self)
                }

                //                })
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommonDiscouresDispalyViewController") as! CommonDiscouresDispalyViewController
                let mainDta = self.discoursesVideoArray[indexPath.row] as! NSDictionary
                let name = mainDta.value(forKey: "name") as? String
                let imageUrl = mainDta.value(forKey: "cover") as? String
                vc.discourseName = name
                vc.albumId = album_id
                vc.discourseImageName = imageUrl
                vc.isFromVideoDiscorse = true
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
                _ = URL(string: imgeFile)
                DispatchQueue.main.async(execute: {
                    if let url = URL(string: imgeFile){
                        if let _ = vc.discouresIamgeView {
                            vc.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    }
                })
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }

    func languageSelect(_ album_Id: String, album_Name: String) {
        album_id = album_Id
        album_name = album_Name
        langLabel.text = album_Name
        search.text = ""
        searchActive = false
        search.resignFirstResponder()
        if !isQA {
            self.getAllAudioCategoryOfDiscourses(searchText)
        } else {
            self.getAllAudioCategoryOfQA()
        }
        self.getAllVideoCategoryOfQA()
        self.getAllVideoCategoryOfDiscourses(searchText)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lang_to_audiovVdeo"{
            let vc = segue.destination as! LanguagePopViewController
            vc.langDelegate = self
            search.text = ""
            search.resignFirstResponder()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension AudioVideoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor = (screenWidth / 3) - 6

        return CGSize(width: scaleFactor, height: 160)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension AudioVideoViewController :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoty == "Audio" {
            return self.discoursesArray.count
        }else {
            return self.discoursesVideoArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscourseTableViewCell") as! DiscourseTableViewCell
        cell.categoryImageView.layer.cornerRadius = cell.categoryImageView.frame.size.width/2
        cell.categoryImageView.clipsToBounds = true
        cell.categoryImageView.layer.borderWidth = 1.0
        if categoty == "Audio" {
            if !self.isQA {
                let mainDta = self.discoursesArray[indexPath.row] as NSDictionary
                let name = mainDta.value(forKey: "name") as? String
                let imageUrl = mainDta.value(forKey: "cover") as? String
                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
                DispatchQueue.main.async(execute: {
                    if let url = URL(string: imgeFile){
                        if let _ = cell.categoryImageView {
                            cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    }
                    cell.categotyNameLabel.text = name
                })
                let addedDate = mainDta.value(forKey: "timeline") as? String
                if addedDate == "0000-00-00"{
                    cell.dateLabel.text = "-"
                }else {
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd"

                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "MMM d,yyyy"

                    let showDate = inputFormatter.date(from: addedDate!)
                    let resultString = outputFormatter.string(from: showDate!)
                    cell.dateLabel.text = resultString
                   // print("added dates", resultString)
                }
            }
        }else{
            if !self.isQA {
                let mainDta = self.discoursesVideoArray[indexPath.row] as! NSDictionary
                let name = mainDta.value(forKey: "name") as? String

                let imageUrl = mainDta.value(forKey: "cover") as? String

                let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
                DispatchQueue.main.async(execute: {
                    if let url = URL(string: imgeFile){
                        if let _ = cell.categoryImageView {
                            cell.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                        }
                    }
                    cell.categotyNameLabel.text = name
                })

                let addedDate = mainDta.value(forKey: "timeline") as? String
                if addedDate == "0000-00-00"{
                    cell.dateLabel.text = "-"
                }else {
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd"

                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "MMM d,yyyy"
                    let showDate = inputFormatter.date(from: addedDate!)
                    let resultString = outputFormatter.string(from: showDate!)
                    cell.dateLabel.text = resultString
                   // print("added dates", resultString)
                }

            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categoty == "Audio"{
            if subscriptionStatus == true {
                print("User subscribed")
            }else {
                //showAdds()
                //IronSource.showRewardedVideo(with: self)
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommonDiscouresDispalyViewController") as! CommonDiscouresDispalyViewController
            let mainDta = self.discoursesArray[indexPath.row] as! NSDictionary
            let name = mainDta.value(forKey: "name") as? String
            let imageUrl = mainDta.value(forKey: "cover") as? String
            vc.discourseName = name
            vc.albumId = album_id
            vc.discourseImageName = imageUrl
            vc.isFromVideoDiscorse = false
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl!)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = vc.discouresIamgeView {
                        vc.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
            self.navigationController?.pushViewController(vc, animated: true)

        } else {
            if subscriptionStatus == true {
                print("User subscribed")
            }else {
               // showAdds()
                //IronSource.showRewardedVideo(with: self)
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommonDiscouresDispalyViewController") as! CommonDiscouresDispalyViewController
            let mainDta = self.discoursesVideoArray[indexPath.row] as! NSDictionary
            let name = mainDta.value(forKey: "name") as? String
            let imageUrl = mainDta.value(forKey: "cover") as? String
            vc.discourseName = name
            vc.albumId = album_id
            vc.discourseImageName = imageUrl
            vc.isFromVideoDiscorse = true
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,VIDEO,imageUrl!)
            _ = URL(string: imgeFile)
            DispatchQueue.main.async(execute: {
                if let url = URL(string: imgeFile){
                    if let _ = vc.discouresIamgeView {
                        vc.discouresIamgeView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                    }
                }
            })
            self.navigationController?.pushViewController(vc, animated: false)

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
extension AudioVideoViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        search.text = ""
        search.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        search.text = ""
        search.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        search.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if categoty == "Audio" {
            self.getAllAudioCategoryOfDiscourses(searchText)
        } else {
            self.getAllVideoCategoryOfDiscourses(searchText)
        }
    }
}
