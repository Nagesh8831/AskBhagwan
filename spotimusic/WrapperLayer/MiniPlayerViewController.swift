//
//  MiniPlayerViewController.swift
//  HalfModalPresentationController
//
//  Created by SCISPLMAC on 25/08/18.
//  Copyright © 2018 martinnormark. All rights reserved.
//

import UIKit

class MiniPlayerViewController: UIViewController {
    @IBOutlet weak var playedsongNameLabel: UILabel!
    
    @IBOutlet weak var playedSongImagesView: GIAImageView!
    var audioName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if let filename = UserDefaults.standard.value(forKey: "audioFileName"){
            self.playedsongNameLabel.text = filename  as! String
        } else {
            self.playedsongNameLabel.text = ""
        }
        if   let imageUrl = UserDefaults.standard.value(forKey: "audioFileImage")  {
            let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,AUDIO,imageUrl as! String)
            
            let url = URL(string: imgeFile)
            
            DispatchQueue.main.async(execute: {
                self.playedSongImagesView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
            })
        }
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
