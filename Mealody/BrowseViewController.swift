//
//  BrowseViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 05..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    @IBOutlet weak var browseStackView: UIStackView!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    @IBOutlet weak var ingredientsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for case let view in browseStackView.subviews {
            view.clipsToBounds = true
            view.layer.cornerRadius = view.frame.height / 2
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            view.layer.masksToBounds = false
            view.layer.shadowOffset = CGSize(width: 0, height: 3)
            view.layer.shadowRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.75
            if let button = view.subviews.first as? UIButton {
                button.layer.cornerRadius = button.frame.height / 2
                button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                button.layer.masksToBounds = true
                button.subviews.first?.contentMode = .scaleAspectFill
                button.titleLabel?.minimumScaleFactor = 0.5
                button.titleLabel?.numberOfLines = 1
                button.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategories" {
            let listVC = segue.destination as! ListViewController
            listVC.navigationItem.title = "Categories"
            listVC.isCategoryList = true
        }
    }
    
}

