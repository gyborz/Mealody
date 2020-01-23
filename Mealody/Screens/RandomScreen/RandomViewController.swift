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
    
    // MARK: - Properties
    
    private let restManager = RestManager.shared
    
    // MARK: - Outlets
    
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - View Handling
    
    // we set up the activity indicator's type and color, and add a target func to the navController's pop gesture
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.type = .lineScale
        activityIndicator.color = .white
        self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture))
        
        setupButtonTitle()
    }
    
    // we set up the button's title, we want the 'random' word to be the opposit color, than the color of the rest of the text
    private func setupButtonTitle() {
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
    
    // we set the random button's corner radius, and give it a shadow
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        randomButton.layer.cornerRadius = randomButton.frame.height / 2
        randomButton.layer.masksToBounds = false
        randomButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        randomButton.layer.shadowRadius = 10
        randomButton.layer.shadowColor = UIColor.black.cgColor
        randomButton.layer.shadowOpacity = 0.5
    }
    
    // we cancel every ongoing task when the view is about to disappear
    // this prevents the RecipeVC to appear while the user dismisses the view (e.g. swiping the navController)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        restManager.cancelTasks()
        ImageService.cancelTasks()
    }
    
    // we reset the random button to it's original appearance
    private func resetView() {
        self.setupButtonTitle()
        self.randomButton.isEnabled = true
    }
    
    // we detect if the user started to dismiss the view via the swiping mechanism
    // if the pop gesture begins we cancel every ongoing task and reset the view
    @objc private func handlePopGesture(gesture: UIGestureRecognizer) -> Void {
        if gesture.state == UIGestureRecognizer.State.began {
            restManager.cancelTasks()
            ImageService.cancelTasks()
            resetView()
        }
    }
    
    // MARK: - UI Actions
    
    // we cancel every ongoing task when the user goes back to the Home screen
    // this prevents the RecipeVC to appear later on
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        restManager.cancelTasks()
        ImageService.cancelTasks()
        self.navigationController?.popViewController(animated: true)
    }
    
    // we disable the random button, remove the text from it's title and start the activity inidicator
    // we initiate a random meal request, if the request is successful, we immediately initiate an image request too
    // so we get the meal's image; if we got the image, we can present the RecipeVC
    // if there's any error while getting the meal or image, we show the proper error popup and reset the view
    // except if the user cancelled the request (by dismissing) we just return
    @IBAction func randomButtonTapped(_ sender: UIButton) {
        randomButton.isEnabled = false
        randomButton.setAttributedTitle(NSMutableAttributedString(string: ""), for: .normal)
        activityIndicator.startAnimating()
        
        restManager.getRandomMeal { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let meal):
                    guard let url = URL(string: meal.strMealThumb!) else { return }
                    let _ = ImageService.getImage(withURL: url) { image, error in
                        self.activityIndicator.stopAnimating()
                        
                        let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
                        recipeVC.modalPresentationStyle = .automatic
                        recipeVC.meal = meal
                        
                        if error != nil {
                            if error!._code == NSURLErrorCancelled {
                                return
                            } else {
                                recipeVC.image = UIImage(named: "error")
                                recipeVC.calledWithHashableMeal = false
                                recipeVC.isHashableMealFromPersistence = false
                                self.present(recipeVC, animated: true) {
                                    self.resetView()
                                }
                            }
                        } else {
                            recipeVC.image = image
                            recipeVC.calledWithHashableMeal = false
                            recipeVC.isHashableMealFromPersistence = false
                            self.present(recipeVC, animated: true) {
                                self.resetView()
                            }
                        }
                    }
                case .failure(let error):
                    self.activityIndicator.stopAnimating()
                    self.showPopupFor(error)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    // we present a popup according to the error, with the help of the PopupDialog framework
    private func showPopupFor(_ error: RestManagerError) {
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
        case .cancelledError:
            return
        }
    }
    
}
