//
//  GIAButton.swift
//  GroupInitArchitecture
//
//  Created by Ravi Deshmukh on 24/09/17.
//  Copyright © 2017 Barquecon Technology pvt ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GIAButton: UIButton {
  
  override init (frame: CGRect) {
    super.init(frame : frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.clear {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
    
}
//@IBDesignable class UIDesignableTableViewCell: UITableViewCell {
//       @IBInspectable var selectedColor: UIColor = UIColor.clear {
//       didSet {
//         selectedBackgroundView = UIView()
//         selectedBackgroundView?.backgroundColor = selectedColor
//       }
//     }
//   }
