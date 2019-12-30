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

    @NSManaged public var idMeal: String?
    @NSManaged public var mealImage: Data?
    @NSManaged public var strIngredients: [String]?
    @NSManaged public var strInstructions: String?
    @NSManaged public var strMeal: String?
    @NSManaged public var strMeasures: [String]?

}
