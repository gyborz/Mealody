//
//  MealData+CoreDataProperties.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//
//

import Foundation
import CoreData


extension MealData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealData> {
        return NSFetchRequest<MealData>(entityName: "MealData")
    }

    @NSManaged public var idMeal: String?                       // id of the meal/recipe
    @NSManaged public var mealImage: Data?                      // image of the meal/recipe (it's compressed data)
    @NSManaged public var strIngredients: [String]?             // ingredients of the meal/recipe
    @NSManaged public var strInstructions: String?              // instructions of the meal/recipe
    @NSManaged public var strMeal: String?                      // name of the meal/recipe
    @NSManaged public var strMeasures: [String]?                // measures of the ingredients

}
