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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /* TODO: -
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save<T: NSManagedObject>(_ objectType: T.Type, meal: Meal, imageData: Data) {
        let ingredients = getIngredients(from: meal)
        let measures = getMeasures(from: meal)
        
        let newMeal = T(context: self.context)
        newMeal.setValue(meal.idMeal, forKey: "idMeal")
        newMeal.setValue(imageData, forKey: "mealImage")
        newMeal.setValue(ingredients, forKey: "strIngredients")
        newMeal.setValue(meal.strInstructions, forKey: "strInstructions")
        newMeal.setValue(meal.strMeal, forKey: "strMeal")
        newMeal.setValue(measures, forKey: "strMeasures")
        
        do {
            try context.save()
        } catch (let error) {
            // TODO: - error
            print("\(error)\nCouldn't save data")
        }
    }
    
    func load<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch (let error) {
            // TODO: - error
            print("\(error)\nCouldn't fetch data")
            return [T]()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func fetchMeal<T: NSManagedObject>(_ objectType: T.Type, idMeal: String) -> T? {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "idMeal = %@", idMeal)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedMeal = try context.fetch(fetchRequest)
            return fetchedMeal.first as? T
        } catch (let error) {
            // TODO: - error
            print("\(error)\nCouldn't fetch data")
            return nil
        }
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
