//
//  RandomViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 21..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RandomViewController: UIViewController {
    
    private let restManager = RestManager.shared
    
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.type = .lineScale
        activityIndicator.color = .white
        
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
    
    func setUpButton() {
        randomButton.titleLabel?.lineBreakMode = .byWordWrapping
        randomButton.titleLabel?.textColor = .label
        let buttonText = "Give me a\nrandom\nrecipe"
        let coloredText = "random"
        
        let range = (buttonText as NSString).range(of: coloredText)
        
        let attributedString = NSMutableAttributedString(string: buttonText)
        attributedString.addAttribute(NSMutableAttributedString.Key.foregroundColor, value: UIColor.systemBackground, range: range)

        randomButton.setAttributedTitle(attributedString, for: .normal)
        randomButton.titleLabel?.textAlignment = .center
    }
    
    private func resetView() {
        self.setUpButton()
        self.randomButton.isEnabled = true
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func randomButtonPressed(_ sender: UIButton) {
        randomButton.isEnabled = false
        randomButton.setAttributedTitle(NSMutableAttributedString(string: ""), for: .normal)
        activityIndicator.startAnimating()
        
        restManager.getRandomMeal { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let meal):
                    guard let url = URL(string: meal.strMealThumb!) else { return }
                    ImageService.getImage(withURL: url) { image, _, error in
                        self.activityIndicator.stopAnimating()
                        
                        let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
                        recipeVC.modalPresentationStyle = .automatic
                        recipeVC.meal = meal
                        
                        if error != nil {
                            recipeVC.image = UIImage(named: "error")
                        } else {
                            recipeVC.image = image
                        }
                        
                        recipeVC.calledWithHashableMeal = false
                        recipeVC.isHashableMealFromPersistence = false
                        self.present(recipeVC, animated: true) {
                            self.resetView()
                        }
                    }
                case .failure(let error):
                    self.activityIndicator.stopAnimating()
                    switch error {
                    case .emptyStateError:
                        let popup = PopupService.emptyStateError(withMessage: "Something went wrong.\nPlease try again!") {
                            self.resetView()
                        }
                        self.present(popup, animated: true)
                    case .parseError:
                        let popup = PopupService.parseError(withMessage: "Couldn't get the data.\nPlease try again!") {
                            self.resetView()
                        }
                        self.present(popup, animated: true)
                    case .networkError:
                        let popup = PopupService.networkError(withMessage: "Please check your connection!") {
                            self.resetView()
                        }
                        self.present(popup, animated: true)
                    case .requestError:
                        let popup = PopupService.requestError(withMessage: "Something went wrong.\nPlease try again!") {
                            self.resetView()
                        }
                        self.present(popup, animated: true)
                    }
                }
            }
        }
    }
    
}
