//
//  Ingredient.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

struct Ingredient: Decodable, Hashable {
    
    let idIngredient: String                // id of the ingredient
    let strIngredient: String               // name of the ingredient
    
    init(idIngredient: String, strIngredient: String) {
        self.idIngredient = idIngredient
        self.strIngredient = strIngredient
    }
    
}
