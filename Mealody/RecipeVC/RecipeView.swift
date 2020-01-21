//
//  RecipeView.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeView: UIView {
    
    var savedLabel: SavedLabel!
    var savedLabelTopAnchor: NSLayoutConstraint! // we have to keep track of this anchor so we can animate the label up and down
    
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
    func setupView(withMeal meal: Meal) {
        mealLabel.text = meal.strMeal
        
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        ingredientsTextView.text = returnIngredientsString(from: ingredients, from: measures)
        
        instructionsTextView.text = meal.strInstructions
    }
    
    func setupView(withImage image: UIImage) {
        mealImageView.image = image
    }
    
    func setupView(withHashableMeal hashableMeal: HashableMeal) {
        saveButton.isHidden = true
        
        mealImageView.image = UIImage(data: hashableMeal.mealImage!)
        mealLabel.text = hashableMeal.strMeal!
        ingredientsTextView.text = returnIngredientsString(from: hashableMeal.strIngredients!, from: hashableMeal.strMeasures!)
        instructionsTextView.text = hashableMeal.strInstructions!
    }
    
    func setupUI() {
        self.bringSubviewToFront(blurView)
        
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
        
        ingredientsTextView.isScrollEnabled = false
        ingredientsTextView.isUserInteractionEnabled = false
        
        instructionsTextView.isScrollEnabled = false
        instructionsTextView.isUserInteractionEnabled = false
        
        savedLabel = SavedLabel()
        self.addSubview(savedLabel)
        savedLabel.translatesAutoresizingMaskIntoConstraints = false
        savedLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        savedLabelTopAnchor = savedLabel.topAnchor.constraint(equalTo: self.bottomAnchor)
        savedLabelTopAnchor.isActive = true
        savedLabel.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        savedLabel.widthAnchor.constraint(equalToConstant: savedLabel.label.bounds.width + 30).isActive = true
    }
    
    func setupSaveButton(isMealSaved: Bool) {
        if isMealSaved {
            saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)), for: .normal)
            saveButton.layer.cornerRadius = saveButton.frame.height / 2
            saveButton.backgroundColor = .systemGreen
            saveButton.layer.shadowOffset = CGSize(width: 1.5, height: 3)
            saveButton.layer.shadowRadius = 0.7
            saveButton.layer.shadowColor = UIColor.black.cgColor
            saveButton.layer.shadowOpacity = 0.2
            saveButton.isUserInteractionEnabled = false
        } else {
            saveButton.setImage(UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)), for: .normal)
            saveButton.layer.cornerRadius = saveButton.frame.height / 2
            saveButton.backgroundColor = .systemOrange
            saveButton.layer.shadowOffset = CGSize(width: 1.5, height: 3)
            saveButton.layer.shadowRadius = 0.7
            saveButton.layer.shadowColor = UIColor.black.cgColor
            saveButton.layer.shadowOpacity = 0.2
            saveButton.isEnabled = true
        }
    }
    
    func changeSaveButton() {
        saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)), for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.isUserInteractionEnabled = false
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
    
    func toggleSavedLabel() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.savedLabelTopAnchor.constant = -65.0
            self.layoutIfNeeded()
        }) { completed in
            UIView.animate(withDuration: 0.5, delay: 1.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.savedLabelTopAnchor.constant = 65.0
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
