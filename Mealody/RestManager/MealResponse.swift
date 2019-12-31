//
//  MealResponse.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 27..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

struct MealResponse: Decodable {
    
    let meals: [Meal]?
    
    init(meals: [Meal]?) {
        self.meals = meals
    }
    
}
