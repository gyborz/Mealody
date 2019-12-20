//
//  ViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 18..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var menuStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for case let view in menuStackView.subviews {
            view.clipsToBounds = true
            view.layer.cornerRadius = view.frame.height / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            view.layer.masksToBounds = false
            view.layer.shadowOffset = CGSize(width: 0, height: 5)
            view.layer.shadowRadius = 1.5
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.3
        }
    }


}

