//
//  MeditationTechniqueDiscriptionViewController.swift
//  spotimusic
//
//  Created by BQTMAC003 on 09/03/20.
//  Copyright © 2020 Appteve. All rights reserved.
//

import UIKit

class MeditationTechniqueDiscriptionViewController: UIViewController {

    @IBOutlet weak var webViewDes: UIWebView!
    var htmlString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        webViewDidFinishLoad(webView: webViewDes)
        webViewDes.loadHTMLString(htmlString,baseURL: nil)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        let zoom = webView.bounds.size.width / webView.scrollView.contentSize.width
        webView.scrollView.setZoomScale(zoom, animated: true)
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
extension UIWebView {
    ///Method to fit content of webview inside webview according to different screen size
    func resizeWebViewContent() {
        let contentSize = self.scrollView.contentSize
        let viewSize = self.bounds.size
        let zoomScale = viewSize.width/contentSize.width
        self.scrollView.minimumZoomScale = zoomScale
        self.scrollView.maximumZoomScale = zoomScale
        self.scrollView.zoomScale = zoomScale
    }
}
