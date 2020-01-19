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
        
        if calledWithHashableMeal && isHashableMealFromPersistence {
            recipeView.setUpView(withHashableMeal: hashableMeal)
        } else if calledWithHashableMeal && !isHashableMealFromPersistence {
            guard let url = URL(string: hashableMeal.strMealThumb!) else { return }
            ImageService.getImage(withURL: url) { [weak self] (image, _, error) in
                guard let self = self else { return }
                if error != nil || image == nil {
                    self.image = UIImage(named: "error")
                    self.recipeView.setUpView(withImage: self.image!)
                } else if image != nil {
                    self.image = image
                    self.recipeView.setUpView(withImage: self.image!)
                }
            }
            guard let id = hashableMeal.idMeal else { return }
            restManager.getMeal(byId: id) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meal):
                        self.meal = meal
                        self.recipeView.setUpView(withMeal: meal)
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        } else {    // when called from RandomVC
            guard let image = image, let meal = meal else { return }
            recipeView.setUpView(withImage: image)
            recipeView.setUpView(withMeal: meal)
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
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        recipeView.changeSaveButton()
        
        guard let image = image, let meal = meal else { return }
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            guard let idMeal = meal.idMeal else { return }  // later on turn idMeal to be non-optional
            do {
                if let fetchedMeal = try persistenceManager.fetchMeal(MealData.self, idMeal: idMeal) {
                    // TODO: - disable save button, turn it green
                    print(fetchedMeal.idMeal!)
                    print("Meal already exists")
                } else {
                    try persistenceManager.save(MealData.self, meal: meal, imageData: imageData)
                    recipeView.toggleSavedLabel()
                }
            } catch {
                persistenceManager.context.rollback()
                let popup = PopupService.savingError(withMessage: "Couldn't save the recipe.\nPlease try again!") {
                    // TODO: - reset save button
                }
                present(popup, animated: true)
            }
        } else {
            let popup = PopupService.compressingError(withMessage: "Couldn't compress the image.\nPlease try again!") {
                // TODO: - reset save button
            }
            present(popup, animated: true)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
