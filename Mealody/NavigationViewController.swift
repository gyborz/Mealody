//
//  NavigationViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self
    }
}

extension NavigationViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let enable = self.viewControllers.count > 1
        self.interactivePopGestureRecognizer?.isEnabled = enable
    }
    
}

extension NavigationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
