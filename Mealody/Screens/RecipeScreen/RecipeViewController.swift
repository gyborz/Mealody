//
//  RecipeViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let persistenceManager = PersistenceManager.shared
    private let restManager = RestManager.shared
    var meal: Meal?
    var hashableMeal: HashableMeal!
    var image: UIImage?
    var calledWithHashableMeal: Bool!
    var isHashableMealFromPersistence: Bool!
    
    // MARK: - Outlets
    
    @IBOutlet var recipeView: RecipeView!
    
    // MARK: - View Handling
    
    // we set up the UI through the recipeView's func, then prepare all the necessary data to present them
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeView.setupUI()
        
        prepareData()
    }
    
    // we present all the data depending on the values of the bool properties we have (which at this point are already set)
    // if the FIRST statement is all true, then the VC is called with one of the saved recipes, which is in a hashableMeal form
    // in this case we have everything we need, we set up the view in recipeView's function
    // if the SECOND statement is all true, then we need to get the data which takes time, so we start the activity indicators
    // we start the datatasks to get the meal's picture and the meal's other informations; these two can take different seconds
    // and both of them can fail for different reasons, so we handle all the possible error cases
    // after we got all the necessary data (and both the meal and image properties are set) we can set up the save button
    // and stop the activity indicators
    // if the THIRD STATEMENT goes through, (that can only happen if the VC is called from the Random screen) we check if
    // both the meal and image properties are set (even though it can't happen that they aren't set)
    // and set up the view and the save button
    // NOTE: the save button only appears when both the image and the meal properties are set
    private func prepareData() {
        if calledWithHashableMeal && isHashableMealFromPersistence {
            recipeView.setupView(withHashableMeal: hashableMeal)
        } else if calledWithHashableMeal && !isHashableMealFromPersistence {
            recipeView.imageActivityIndicator.startAnimating()
            recipeView.contentActivityIndicator.startAnimating()
            if let imageURL = hashableMeal.strMealThumb {
                guard let url = URL(string: imageURL) else { return }
                let _ = ImageService.getImage(withURL: url) { [weak self] (image, error) in
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
            } else {
                self.image = UIImage(named: "error")
                self.recipeView.setupView(withImage: self.image!)
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
    
    // we check if the recipe we presented is already a saved one or not
    // we set up the button's appearance according to that; if there's an error, we show a popup error message
    // NOTE: the save button only appears when both the image and the meal properties are set
    /// - Parameter meal: the meal we get from the rest manager
    private func setupSaveButton(withMeal meal: Meal) {
        do {
            if (try persistenceManager.fetchMeal(MealData.self, idMeal: meal.idMeal)) != nil {
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
    
    // MARK: - Error Handling
    
    // we present a popup according to the error, with the help of the PopupDialog framework
    /// - Parameter error: the error we get from the rest manager
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
    
    // MARK: - UI Actions
    
    // we change the save button's appearance, then check if both the meal and image properties are set
    // this is only a last safety check because the save button is visible only if both of those properties are correctly set
    // (if the image request failed and it was set with an 'error' image instead, the save button still won't be set up)
    // we compress the image with the best quality and save the meal/recipe, we show a 'Recipe saved' label too
    // any error during the compression or saving results in an error popup
    @IBAction func saveButtonTapped(_ sender: UIButton) {
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
