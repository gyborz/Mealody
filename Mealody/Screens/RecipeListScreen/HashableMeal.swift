//
//  HashableMeal.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 31..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

struct HashableMeal: Hashable {
    
    let idMeal: String?                 // id of the meal/recipe
    let mealImage: Data?                // data of the meal's image
    let strIngredients: [String]?       // ingredients of the recipe
    let strInstructions: String?        // instructions of the recipe
    let strMeal: String?                // name of the meal/recipe
    let strMeasures: [String]?          // measure of the ingredients
    let strMealThumb: String?           // url of the meal's/recipe's image
    
    init(mealData: MealData) {
        self.idMeal = mealData.idMeal
        self.mealImage = mealData.mealImage
        self.strIngredients = mealData.strIngredients
        self.strInstructions = mealData.strInstructions
        self.strMeal = mealData.strMeal
        self.strMeasures = mealData.strMeasures
        self.strMealThumb = String()
    }
    
    init(meal: Meal) {
        self.strMeal = meal.strMeal
        self.strMealThumb = meal.strMealThumb
        self.idMeal = meal.idMeal
        
        self.mealImage = Data()
        self.strIngredients = [String]()
        self.strInstructions = String()
        self.strMeasures = [String]()
    }
    
}
