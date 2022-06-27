//
//  TutorialViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 28/09/18.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import AACarousel
import SCLAlertView
class TutorialViewController: BaseViewController ,AACarouselDelegate{
     var reachabilitysz: Reachability!
    @IBOutlet weak var imageSlider: AACarousel!
    var sliderImageArray = ["login","Music_mini_player","music_player","share_and_add","audio_Q&A","audio_discourse_language","audio_Q&A_catagory_list","community1","community_search","community_chatroom","community_friendrequest_pending","drawe_playlist","events"]
    
@IBOutlet weak var menuBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callBack), userInfo: nil, repeats: false)
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

        self.title = "How to use"

        self.imageSlider.delegate = self
        self.imageSlider.setCarouselData(paths: self.sliderImageArray,  describedTitle: [""], isAutoScroll: true, timer: 50.0, defaultImage: "defaultImage")
        self.imageSlider.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        // Do any additional setup after loading the view.
    }
    @objc func callBack(){
    }
    func didSelectCarouselView(_ view: AACarousel, _ index: Int) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func downloadImages(_ url: String, _ index: Int) {
        
    }
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        imageView.kf.setImage(with: URL(string: url[index]), placeholder: UIImage.init(named: "os_ho.jpg"))
    }
    //Image slider
    func startAutoScroll() {
        imageSlider.stopScrollImageView()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
