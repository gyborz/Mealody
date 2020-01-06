//
//  Category.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

struct Category: Decodable {
    
    var strCategory: String
    
    init(strCategory: String) {
        self.strCategory = strCategory
    }
    
}
