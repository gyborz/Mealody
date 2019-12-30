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
    
    
    func setUpView(with meal: Meal, and image: UIImage) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
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
        
        mealImageView.image = image
        mealLabel.text = meal.strMeal
        
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        ingredientsTextView.text = returnIngredientsString(from: ingredients, from: measures)
        
        instructionsTextView.text = meal.strInstructions
    }
    
    func changeSaveButton() {
        saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)), for: .normal)
        saveButton.backgroundColor = .systemGreen
    }
    
    private func returnIngredientsString(from ingredientArray: [String], from measureArray: [String]) -> String {
        var ingredientsString = String()
        for i in 0..<ingredientArray.count {
            ingredientsString += "\(ingredientArray[i]) - \(measureArray[i])\n"
        }
        return ingredientsString
    }
    
    private func getIngredients(from meal: Meal) -> [String] {
        var ingredients = [String]()
        let mealMirror = Mirror(reflecting: meal)
        for (_, attribute) in mealMirror.children.enumerated() {
            if ((attribute.label!).contains("strIngredient")), let value = attribute.value as? String, value != "" {
                ingredients.append(value)
            }
        }
        return ingredients
    }
    
    private func getMeasures(from meal: Meal) -> [String] {
        var measures = [String]()
        let mealMirror = Mirror(reflecting: meal)
        for (_, attribute) in mealMirror.children.enumerated() {
            if ((attribute.label!).contains("strMeasure")), let value = attribute.value as? String, value != "" {
                measures.append(value)
            }
        }
        return measures
    }
    
}
