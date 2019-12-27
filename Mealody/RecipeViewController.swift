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
    
    @IBOutlet var recipeView: RecipeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeView.setUpView(with: meal)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        recipeView.changeSaveButton()
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
