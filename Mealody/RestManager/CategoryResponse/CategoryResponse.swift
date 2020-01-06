//
//  CategoryResponse.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

struct CategoryResponse: Decodable {
    
    var meals: [Category]
    
    init(meals: [Category]) {
        self.meals = meals
    }
    
}
