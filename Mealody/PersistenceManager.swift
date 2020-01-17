//
//  PersistenceManager.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import CoreData

final class PersistenceManager {
    
    static let shared = PersistenceManager()
    lazy var context = persistentContainer.viewContext
    
    private init() {}
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MealData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                NSLog("Failed to load persistence store:", error.localizedDescription, error.userInfo)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    func save<T: NSManagedObject>(_ objectType: T.Type, meal: Meal, imageData: Data) throws {
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        
        let newMeal = T(context: self.context)
        newMeal.setValue(meal.idMeal, forKey: "idMeal")
        newMeal.setValue(imageData, forKey: "mealImage")
        newMeal.setValue(ingredients, forKey: "strIngredients")
        newMeal.setValue(meal.strInstructions, forKey: "strInstructions")
        newMeal.setValue(meal.strMeal, forKey: "strMeal")
        newMeal.setValue(measures, forKey: "strMeasures")
        
        try context.save()
    }
    
    func load<T: NSManagedObject>(_ objectType: T.Type) throws -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let fetchedObjects = try context.fetch(fetchRequest) as? [T]
        return fetchedObjects ?? [T]()
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func fetchMeal<T: NSManagedObject>(_ objectType: T.Type, idMeal: String) throws -> T? {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "idMeal = %@", idMeal)
        fetchRequest.predicate = predicate
        
        let fetchedMeal = try context.fetch(fetchRequest)
        return fetchedMeal.first as? T
    }
    
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
    
}
