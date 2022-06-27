//
//  ImageFromUrl.swift
//  spotimusic
//
//  Created by appteve on 05/05/2017.
//  Copyright © 2017 Appteve. All rights reserved.
//

import UIKit

class ImageFromUrl: NSObject {
    
    public func getDataFromUrl(url: URL, completion: @escaping (_ data: UIImage?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            let image = UIImage(data:data!)
            
            completion(image, response, error)
            }.resume()
    }

}
