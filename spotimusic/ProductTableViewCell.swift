//
//  ProductTableViewCell.swift
//  spotimusic
//
//  Created by Mac on 16/05/19.
//  Copyright © 2019 Appteve. All rights reserved.
//

import UIKit
protocol UserWallDelegate : AnyObject {
    func previewImages(images: [[String: String]] , startIndexURl: String)
}
class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var indiaOwnerNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var contactDetailsTextView: UITextView!
    //for attachements greater than or equals to 4
    @IBOutlet weak var fourImagesView: UIView!
    @IBOutlet weak var fourthOneImageView: UIImageView!
    @IBOutlet weak var fourthTwoImageView: UIImageView!
    @IBOutlet weak var fourthThreeImageView: UIImageView!
    @IBOutlet weak var fourthFourImageView: UIImageView!
    
    @IBOutlet weak var moreImagesButton: UIButton!
    //for only 3 attachements
    @IBOutlet weak var threeImagesView: UIView!
    @IBOutlet weak var thirdOneFImageView: UIImageView!
    @IBOutlet weak var thirdTwoView: UIImageView!
    @IBOutlet weak var thirdThreeView: UIImageView!
    
    //for 2 attachements
    @IBOutlet weak var secondImagesView: UIView!
    @IBOutlet weak var secondOneImageView: UIImageView!
    @IBOutlet weak var secondTwoImageView: UIImageView!
    
    //for single attachements
    @IBOutlet weak var singleImageView: UIView!
    @IBOutlet weak var singaleImage: UIImageView!
     var imageDataArray = [[String: AnyObject]]()
    weak var delegate: UserWallDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func showMoreImages(sender : UIButton){
        delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[sender.tag]["url"] as! String)
    }
    @objc func oneImageButtonAction1(_ sender:AnyObject){
        if imageDataArray.count >= 4 {
            //print("imageDataArray",imageDataArray.count)
            ////print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[0]["url"] as! String)
        }
        if imageDataArray.count == 3 {
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[0]["url"] as! String)
        }
        
        if imageDataArray.count == 2 {
            //print("imageDataArray",imageDataArray.count)
            ////print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[0]["url"] as! String)
        }
        if imageDataArray.count == 1 {
            //print("imageDataArray",imageDataArray.count)
            ////print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[0]["url"] as! String)
        }
    }
   @objc func oneImageButtonAction2(_ sender:AnyObject){
        
        if imageDataArray.count >= 4 {
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[1]["url"] as! String)
        }
        
        if imageDataArray.count == 3 {
            
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[1]["url"] as! String)
        }
        
        if imageDataArray.count == 2 {
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[1]["url"] as! String)
        }
    }
    
   @objc  func oneImageButtonAction3(_ sender:AnyObject){
        if imageDataArray.count >= 4 {
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[2]["url"] as! String)
        }
        if imageDataArray.count == 3 {
            
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[2]["url"] as! String)
        }
        
    }
    @objc func oneImageButtonAction4(_ sender:AnyObject){
        if imageDataArray.count >= 4 {
            //print("imageDataArray",imageDataArray.count)
            //print(sender.tag)
            delegate?.previewImages(images: imageDataArray as! [[String : String]], startIndexURl: imageDataArray[3]["url"] as! String)
        }
    }
}
