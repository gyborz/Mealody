//
//  IngredientResponse.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

struct IngredientResponse: Decodable {
    
    let meals: [Ingredient]
    
    init(meals: [Ingredient]) {
        self.meals = meals
    }
    
}
