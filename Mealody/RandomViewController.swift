//
//  RandomViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 21..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RandomViewController: UIViewController {
    
    private let restManager = RestManager()
    
    @IBOutlet weak var randomButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setUpButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        randomButton.layer.cornerRadius = randomButton.frame.height / 2
        randomButton.layer.masksToBounds = false
        randomButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        randomButton.layer.shadowRadius = 10
        randomButton.layer.shadowColor = UIColor.black.cgColor
        randomButton.layer.shadowOpacity = 0.5
    }
    
    private func setUpButton() {
        randomButton.titleLabel?.lineBreakMode = .byWordWrapping
        let buttonText = "Give me a\nrandom\nrecipe"
        let coloredText = "random"
        
        let range = (buttonText as NSString).range(of: coloredText)
        
        let attributedString = NSMutableAttributedString(string: buttonText)
        attributedString.addAttribute(NSMutableAttributedString.Key.foregroundColor, value: UIColor.systemBackground, range: range)

        randomButton.setAttributedTitle(attributedString, for: .normal)
        randomButton.titleLabel?.textAlignment = .center
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func randomButtonPressed(_ sender: UIButton) {
        restManager.getRandomMeal { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let meal):
                    let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
                    recipeVC.modalPresentationStyle = .automatic
                    recipeVC.meal = meal
                    self.present(recipeVC, animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension RandomViewController: UIGestureRecognizerDelegate {
}
