//
//  RandomViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 21..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RandomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension RandomViewController: UIGestureRecognizerDelegate {
}
