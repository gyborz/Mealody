//
//  HashableMeal.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 31..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

struct HashableMeal: Hashable {
    
    let idMeal: String?
    let mealImage: Data?
    let strIngredients: [String]?
    let strInstructions: String?
    let strMeal: String?
    let strMeasures: [String]?
    
    init(mealData: MealData) {
        self.idMeal = meal.idMeal
        self.mealImage = meal.mealImage
        self.strIngredients = meal.strIngredients
        self.strInstructions = meal.strInstructions
        self.strMeal = meal.strMeal
        self.strMeasures = meal.strMeasures
    }
    
}
