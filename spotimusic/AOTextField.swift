//
//  AOTextField.swift
//  spotimusic
//
//  Created by BQ_Tech on 16/08/18.
//

import UIKit
@IBDesignable
class AOTextField: UITextField {
 
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
         return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        // return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
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
    
    @IBInspectable var leftImage : UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding : CGFloat = 5 {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            
            // assigning image
            let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: 20, height: 20))
            imageView.image = image
            
            var width = leftPadding + 20
            
            if borderStyle == UITextField.BorderStyle.none || borderStyle == UITextField.BorderStyle.line {
                width += 5
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20)) // has 5 point higher in width in imageView
            view.addSubview(imageView)
            
            
            leftView = view
            
        } else {
            // image is nill
            leftViewMode = .never
        }
    }
}
