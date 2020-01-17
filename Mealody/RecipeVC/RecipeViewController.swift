//
//  RecipeViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
    
    var meal: Meal!
    var hashableMeal: HashableMeal!
    var image: UIImage!
    var calledWithHashableMeal: Bool!
    var isHashableMealFromPersistence: Bool!
    private let persistenceManager = PersistenceManager.shared
    private let restManager = RestManager()
    
    @IBOutlet var recipeView: RecipeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if calledWithHashableMeal && isHashableMealFromPersistence {
            recipeView.setUpView(withHashableMeal: hashableMeal)
        } else if calledWithHashableMeal && !isHashableMealFromPersistence {
            recipeView.setUpView(withImage: image)
            guard let id = hashableMeal.idMeal else { return }
            restManager.getMeal(byId: id) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meal):
                        self.meal = meal
                        self.recipeView.setUpView(withMeal: meal)
                    case .failure(let error):
                        // TODO: - error handling
                        print(error)
                    }
                }
            }
        } else {    // when called from RandomVC
            recipeView.setUpView(withImage: image)
            recipeView.setUpView(withMeal: meal)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        recipeView.changeSaveButton()
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            guard let idMeal = meal.idMeal else { return }
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
                //TODO: - error
                persistenceManager.context.rollback()
            }
        } else {
            // TODO: - error handling
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
