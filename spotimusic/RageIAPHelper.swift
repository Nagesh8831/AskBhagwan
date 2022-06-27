//
//  RageIAPHelper.swift
//  iCast
//
//  Created by appteve on 20/02/2016.
//  Copyright © 2016 Appteve. All rights reserved.
//

import UIKit

import Foundation

// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
public enum RageProducts {
    
    /// TODO:  Change this to whatever you set on iTunes connect
    fileprivate static let Prefix = IN_APP_PREFIX
    
    /// MARK: - Supported Product Identifiers
    public static let removeAd                = Prefix + "." + IN_APP_PURCHASE1
    public static let unlockOffline           = Prefix + "." + IN_APP_PURCHASE2
    public static let addMorePlaylist         = Prefix + "." + IN_APP_PURCHASE3
    
    
    public static let unlockAll               = Prefix
    
    // All of the products assembled into a set of product identifiers.
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [RageProducts.removeAd, RageProducts.unlockOffline, RageProducts.addMorePlaylist, RageProducts.unlockAll]
    
    /// Static instance of IAPHelper that for rage products.
    public static let store = IAPHelper(productIdentifiers: RageProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
