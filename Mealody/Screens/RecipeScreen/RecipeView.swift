//
//  RecipeView.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RecipeView: UIView {
    
    // MARK: - Properties
    
    var savedLabel: SavedLabel!
    var savedLabelTopAnchor: NSLayoutConstraint! // we have to keep track of this anchor so we can animate the label up and down
    
    // MARK: - Outlets
    
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mealContentView: UIView!
    @IBOutlet weak var imageActivityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var contentActivityIndicator: NVActivityIndicatorView!
    
    // MARK: - View setup methods
    
    // we set up each UI element with the given meal data
    // we animate the appearance of the view which contains every label/view except for the imageView
    /// - Parameter meal: the meal we get from the RecipeViewController
    func setupView(withMeal meal: Meal) {
        mealLabel.text = meal.strMeal
        
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        ingredientsTextView.text = returnIngredientsString(from: ingredients, from: measures)
        
        instructionsTextView.text = meal.strInstructions
        
        UIView.animate(withDuration: 0.5) {
            self.mealContentView.alpha = 1
        }
    }
    
    // we set the imageView's image
    /// - Parameter image: the image we get from the RecipeViewController
    func setupView(withImage image: UIImage) {
        mealImageView.image = image
    }
    
    // we set up each UI element with the given hashableMeal data
    // this is called when we present the saved meal's/recipe's data so we hide the save button and don't animate the contentView's appearance
    /// - Parameter hashableMeal: the hashable meal we get from the RecipeViewController
    func setupView(withHashableMeal hashableMeal: HashableMeal) {
        mealContentView.alpha = 1
        saveButton.isHidden = true
        
        mealImageView.image = UIImage(data: hashableMeal.mealImage!)
        mealLabel.text = hashableMeal.strMeal!
        ingredientsTextView.text = returnIngredientsString(from: hashableMeal.strIngredients!, from: hashableMeal.strMeasures!)
        instructionsTextView.text = hashableMeal.strInstructions!
    }
    
    // we set up each UI element's appearance
    func setupUI() {
        self.bringSubviewToFront(blurView)
        
        imageActivityIndicator.type = .lineScale
        imageActivityIndicator.color = .systemOrange
        contentActivityIndicator.type = .lineScale
        contentActivityIndicator.color = .systemOrange
        
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
        
        mealContentView.alpha = 0
        saveButton.alpha = 0
    }
    
    // we set up the save button's appearance and enable/disable it according to if the meal/recipe we present is saved already or not
    /// - Parameter isMealSaved: bool value which indicates if the meal/recipe is saved or not
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
        UIView.animate(withDuration: 0.3) {
            self.saveButton.alpha = 1
        }
    }
    
    // we change the save button's appearance and disable it when we save the meal/recipe
    func changeSaveButton() {
        saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)), for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Supporting methods
    
    // the API response we get has each ingredient and it's corresponding measure separated
    // we get the given meal response and go through each 'label' that has "strIngredient" in it
    // we get it's value and append it to a string array which is returned at the end
    /// - Parameter meal: the meal we've got from the RecipeViewController
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
    
    // the API response we get has each ingredient and it's corresponding measure separated
    // we get the given meal response and go through each 'label' that has "strMeasure" in it
    // we get it's value and append it to a string array which is returned at the end
    /// - Parameter meal: the meal we've got from the RecipeViewController
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
    
    // the API response we get has each ingredient and it's corresponding measure separated
    // we get those ingredients and measures with the methods above, and turn them into a string array
    // here we take those arrays and going through them we pair the ingredients with their measures
    // and append them to a string, so it makes one whole long text we can then display in the Ingredients textView
    /// - Parameters:
    ///   - ingredientArray: ingredients array which contains each ingredient of the recipe
    ///   - measureArray: measures array which contains each ingredient's measure
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
    
    // we animate the SavedLabel to appear for a short time, then animate it's disappearance
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
