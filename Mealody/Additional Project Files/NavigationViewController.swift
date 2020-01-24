//
//  NavigationViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    // MARK: - View Handling
    
    // we set the navigation controller the pop gesture's delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self
    }
}

// MARK: - Navigation Controller Delegate

extension NavigationViewController: UINavigationControllerDelegate {
    
    // we enable the navigation controller's pop gesture only if we are not on the first VC (HomeVC)
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let enable = self.viewControllers.count > 1
        self.interactivePopGestureRecognizer?.isEnabled = enable
    }
    
}

// MARK: - Gesture Recognizer Delegate

extension NavigationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
