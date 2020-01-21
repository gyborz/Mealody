//
//  RecipeViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
    
    var meal: Meal?
    var hashableMeal: HashableMeal!
    var image: UIImage?
    var calledWithHashableMeal: Bool!
    var isHashableMealFromPersistence: Bool!
    private let persistenceManager = PersistenceManager.shared
    private let restManager = RestManager.shared
    
    @IBOutlet var recipeView: RecipeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeView.setupUI()
        if calledWithHashableMeal && isHashableMealFromPersistence {
            recipeView.setupView(withHashableMeal: hashableMeal)
        } else if calledWithHashableMeal && !isHashableMealFromPersistence {
            recipeView.imageActivityIndicator.startAnimating()
            recipeView.contentActivityIndicator.startAnimating()
            guard let url = URL(string: hashableMeal.strMealThumb!) else { return }
            ImageService.getImage(withURL: url) { [weak self] (image, _, error) in
                guard let self = self else { return }
                if error != nil || image == nil {
                    self.image = UIImage(named: "error")
                    self.recipeView.setupView(withImage: self.image!)
                } else if image != nil {
                    self.image = image
                    self.recipeView.setupView(withImage: self.image!)
                    if let meal = self.meal {
                        self.setupSaveButton(withMeal: meal)
                    }
                }
                self.recipeView.imageActivityIndicator.stopAnimating()
            }
            guard let id = hashableMeal.idMeal else { return }
            restManager.getMeal(byId: id) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meal):
                        self.recipeView.contentActivityIndicator.stopAnimating()
                        self.meal = meal
                        self.recipeView.setupView(withMeal: meal)
                        if self.image != nil {
                            self.setupSaveButton(withMeal: meal)
                        }
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        } else {    // when called from RandomVC
            guard let image = image, let meal = meal else { return }
            recipeView.setupView(withImage: image)
            recipeView.setupView(withMeal: meal)
            setupSaveButton(withMeal: meal)
        }
    }
    
    private func setupSaveButton(withMeal meal: Meal) {
        do {
            if (try persistenceManager.fetchMeal(MealData.self, idMeal: meal.idMeal!)) != nil {
                recipeView.setupSaveButton(isMealSaved: true)
            } else {
                recipeView.setupSaveButton(isMealSaved: false)
            }
        } catch {
            let popup = PopupService.persistenceError(withMessage: "Something went wrong!") {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(popup, animated: true)
        }
    }
    
    private func showPopupFor(_ error: RestManagerError) {
        switch error {
        case .emptyStateError:
            let popup = PopupService.emptyStateError(withMessage: "Something went wrong.\nPlease try again!") {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(popup, animated: true)
        case .parseError:
            let popup = PopupService.parseError(withMessage: "Couldn't get the data.\nPlease try again!") {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(popup, animated: true)
        case .networkError:
            let popup = PopupService.networkError(withMessage: "Please check your connection!") {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(popup, animated: true)
        case .requestError:
            let popup = PopupService.requestError(withMessage: "Something went wrong.\nPlease try again!") {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(popup, animated: true)
        case .cancelledError:
            // this can not happen in this VC
            return
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        recipeView.changeSaveButton()
        
        guard let image = image, let meal = meal else { return }
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try persistenceManager.save(MealData.self, meal: meal, imageData: imageData)
                recipeView.toggleSavedLabel()
            } catch {
                persistenceManager.context.rollback()
                let popup = PopupService.persistenceError(withMessage: "Couldn't save the recipe.\nPlease try again!") {
                    self.recipeView.setupSaveButton(isMealSaved: false)
                }
                present(popup, animated: true)
            }
        } else {
            let popup = PopupService.compressingError(withMessage: "Couldn't compress the image.\nPlease try again!") {
                self.recipeView.setupSaveButton(isMealSaved: false)
            }
            present(popup, animated: true)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
