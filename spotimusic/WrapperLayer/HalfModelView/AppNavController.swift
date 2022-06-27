//
//  AppNavController.swift
//  HalfModalPresentationController
//
//  Created by Ravi Deshmukh on 25/08/18.
//  Copyright © 2018 Barquecon Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class AppNavController: UINavigationController, HalfModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isHalfModalMaximized() ? .default : .lightContent
    }
}
