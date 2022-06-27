//
//  SliderImagePopUpViewController.swift
//  spotimusic
//
//  Created by BQTMACBOOK2 on 29/10/18.
//

import UIKit

class SliderImagePopUpViewController: UIViewController {

    @IBOutlet weak var sliderImageView: UIImageView!
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("imageUrl",imageUrl)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            if let url = URL(string: self.imageUrl){
                if let _ = self.sliderImageView {
                    self.sliderImageView.kf.setImage(with: url, placeholder: UIImage(named: "os_ho.jpg"))
                }
            }

        })
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
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
