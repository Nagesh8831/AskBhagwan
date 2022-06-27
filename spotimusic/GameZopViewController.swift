//
//  GameZopViewController.swift
//  spotimusic
//
//  Created by Mac on 22/09/20.
//  Copyright © 2020 Appteve. All rights reserved.
//

import UIKit

class GameZopViewController: UIViewController {

    @IBOutlet weak var gameZopView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gamezop"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .landscape
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let url = NSURL(string: "https://www.gamezop.com/?id=5Uf4Y-z3L") {
            let request = NSURLRequest(url: url as URL)
            gameZopView.loadRequest(request as URLRequest)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
    }
    override func viewDidDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .portrait
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
