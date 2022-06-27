//
//  GIAView.swift
//  GroupInitArchitecture
//
//  Created by Ravi Deshmukh on 24/09/17.
//  Copyright © 2017 Barquecon Technology pvt ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GIAView: UIView {
  
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

@IBDesignable class GIARingView: UIView {
    @IBInspectable var radius: CGFloat = 20 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var fillColor: UIColor = .clear {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var strokeColor: UIColor = .red {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
        
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width/2,y: frame.height/2), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        //change the fill color
        shapeLayer.fillColor = fillColor.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = strokeColor.cgColor
        //you can change the line width
        shapeLayer.lineWidth = lineWidth
        layer.addSublayer(shapeLayer)
    }
}


@IBDesignable class GIAImageView: UIImageView {
  
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
@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                            attributes: [NSAttributedString.Key.font: font!],
                                                                            context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
@IBDesignable class GIAShadowView: GIAView {
  
  override init (frame: CGRect) {
    super.init(frame : frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews () {
    super.layoutSubviews()
    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    layer.shadowOpacity = 0.1
    layer.shadowPath = shadowPath.cgPath
  }
}

@IBDesignable class GIAGradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    @IBInspectable var cornerRadius: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: frame.size.width,
                                height: frame.size.height)
        gradient.locations = [0, 1]
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        gradient.cornerRadius = cornerRadius
        layer.addSublayer(gradient)
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

@IBDesignable class GIATextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
        //return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
        //return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
        //return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
