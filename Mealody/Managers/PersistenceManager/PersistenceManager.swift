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
    
    // MARK: - Properties
    
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
    
    // MARK: - Core Data Handling Methods
    
    // we save the given meal with the given image's data
    /// - Parameters:
    ///   - objectType: any nsmanagedobject
    ///   - meal: given meal we intend to save
    ///   - imageData: given meal's image's data
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
    
    // we fetch and return all the persisted objects
    /// - Parameter objectType: any nsmanagedobject
    func load<T: NSManagedObject>(_ objectType: T.Type) throws -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let fetchedObjects = try context.fetch(fetchRequest) as? [T]
        return fetchedObjects ?? [T]()
    }
    
    // we delete the given object from persistence
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    // we fetch and return the object which has the given id
    /// - Parameters:
    ///   - objectType: any nsmanagedobject (in this case MealData)
    ///   - idMeal: id of the meal
    func fetchMeal<T: NSManagedObject>(_ objectType: T.Type, idMeal: String) throws -> T? {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "idMeal = %@", idMeal)
        fetchRequest.predicate = predicate
        
        let fetchedMeal = try context.fetch(fetchRequest)
        return fetchedMeal.first as? T
    }
    
    // MARK: - Supporting Methods
    
    // the API response we get has each ingredient and it's corresponding measure separated
    // we get the given meal response and go through each 'label' that has "strIngredient" in it
    // we get it's value and append it to a string array which is returned at the end
    /// - Parameter meal: meal we intend to save
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
    
    // the API response we get has each ingredient and it's corresponding measure separated
    // we get the given meal response and go through each 'label' that has "strMeasure" in it
    // we get it's value and append it to a string array which is returned at the end
    /// - Parameter meal: meal we intend to save
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
