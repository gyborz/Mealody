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
    private let persistenceManager = PersistenceManager.shared
    
    @IBOutlet var recipeView: RecipeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calledWithHashableMeal ? recipeView.setUpView(with: hashableMeal) : recipeView.setUpView(with: meal, and: image)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        recipeView.changeSaveButton()
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            if let fetchedMeal = persistenceManager.fetchMeal(MealData.self, meal: meal) {
                print(fetchedMeal.idMeal!)
                print("Meal already exists")
            } else {
                persistenceManager.save(MealData.self, meal: meal, imageData: imageData)
            }
        } else {
            // TODO: - error handling
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
