//
//  RecipeView.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeView: UIView {
    
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    
    // setting up the view with meal and image are in two separate functions because we can set the image before
    // we go and request the full meal with all the informations - this way when we present the RecipeVC we can already set the imageview
    // if we would set it in the restManager's getMeal(byId:completion:) function in RecipeVC's viewDidLoad, then the imageView would
    // get the image in the middle of presentation, which looks a bit ugly
    // since we already got the image in the RecipeListVC, we can cache it before presenting the RecipeVC
    func setUpView(withMeal meal: Meal) {
        setUpUI()
        
        mealLabel.text = meal.strMeal
        
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        ingredientsTextView.text = returnIngredientsString(from: ingredients, from: measures)
        
        instructionsTextView.text = meal.strInstructions
    }
    
    func setUpView(withImage image: UIImage) {
        mealImageView.image = image
    }
    
    func setUpView(withHashableMeal hashableMeal: HashableMeal) {
        setUpUI()
        
        saveButton.isHidden = true
        
        mealImageView.image = UIImage(data: hashableMeal.mealImage!)
        mealLabel.text = hashableMeal.strMeal!
        ingredientsTextView.text = returnIngredientsString(from: hashableMeal.strIngredients!, from: hashableMeal.strMeasures!)
        instructionsTextView.text = hashableMeal.strInstructions!
    }
    
    private func setUpUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        blurView.sendSubviewToBack(blurEffectView)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = blurView.frame.height / 2
        
        saveButton.setImage(UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)), for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.backgroundColor = .systemOrange
        saveButton.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        saveButton.layer.shadowRadius = 0.7
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.2
        
        
        ingredientsTextView.isScrollEnabled = false
        ingredientsTextView.isUserInteractionEnabled = false
        
        instructionsTextView.isScrollEnabled = false
        instructionsTextView.isUserInteractionEnabled = false
    }
    
    func changeSaveButton() {
        saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)), for: .normal)
        saveButton.backgroundColor = .systemGreen
    }
    
    private func returnIngredientsString(from ingredientArray: [String], from measureArray: [String]) -> String {
        var ingredientsString = String()
        var i = 0
        var j = 0
        while i < ingredientArray.count || j < measureArray.count {
            if i < ingredientArray.count && j < measureArray.count {
                ingredientsString += "\(ingredientArray[i]) - \(measureArray[j])\n"
            } else if i < ingredientArray.count && j >= measureArray.count {
                ingredientsString += "\(ingredientArray[i])\n"
            } else {
                ingredientsString += "\(measureArray[j])\n"
            }
            i += 1
            j += 1
        }
        return ingredientsString
    }
    
    private func getIngredients(from meal: Meal) -> [String] {
        var ingredients = [String]()
        let mealMirror = Mirror(reflecting: meal)
        for (_, attribute) in mealMirror.children.enumerated() {
            if ((attribute.label!).contains("strIngredient")), let value = attribute.value as? String, value != "", value.containsLetters() {
                ingredients.append(value)
            }
        }
        return ingredients
    }
    
    private func getMeasures(from meal: Meal) -> [String] {
        var measures = [String]()
        let mealMirror = Mirror(reflecting: meal)
        for (_, attribute) in mealMirror.children.enumerated() {
            if ((attribute.label!).contains("strMeasure")), let value = attribute.value as? String, value != "", value.containsLetters() {
                measures.append(value)
            }
        }
        return measures
    }
    
}
