//
//  RestManager.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 27..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

final class RestManager {
    
    // MARK: - Properties
    
    static let shared = RestManager()
    private init() {}
    
    private let apiKey = "9973533"
    
    private let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15.0
        sessionConfig.timeoutIntervalForResource = 30.0
        return URLSession(configuration: sessionConfig)
    }()
    
    // MARK: - Request Methods
    
    // we get a random meal/recipe through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameter completion: escaping closure which gives back a meal or a rest manager error
    func getRandomMeal(completion: @escaping (Result<Meal,RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/random.php") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    if let meal = mealResponse.meals?.first {
                        completion(.success(meal))
                    } else {
                        completion(.failure(.emptyStateError))
                    }
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else if error!.isCancelledError {
                    completion(.failure(.cancelledError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we get meals/recipes from a certain category, through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameters:
    ///   - category: a category which is chosen by the user
    ///   - completion: escaping closure which gives back a meal array or a rest manager error
    func getMeals(fromCategory category: String, completion: @escaping (Result<[Meal],RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/filter.php?c=\(category)") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    if let meals = mealResponse.meals {
                        completion(.success(meals))
                    } else {
                        completion(.failure(.emptyStateError))
                    }
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we get meals/recipes from a certain country, through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameters:
    ///   - country: a country which is chosen by the user
    ///   - completion: escaping closure which gives back a meal array or a rest manager error
    func getMeals(fromCountry country: String, completion: @escaping (Result<[Meal],RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/filter.php?a=\(country)") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    if let meals = mealResponse.meals {
                        completion(.success(meals))
                    } else {
                        completion(.failure(.emptyStateError))
                    }
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we get a meal/recipe with a certain ID, through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameters:
    ///   - id: id of the meal/recipe
    ///   - completion: escaping closure which gives back a meal or a rest manager error
    func getMeal(byId id: String, completion: @escaping (Result<Meal,RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/lookup.php?i=\(id)") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    if let meal = mealResponse.meals?.first {
                        completion(.success(meal))
                    } else {
                        completion(.failure(.emptyStateError))
                    }
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we get all the ingredients, through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameter completion: escaping closure which gives back an ingredient array or a rest manager error
    func getIngredients(completion: @escaping (Result<[Ingredient],RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/list.php?i=list") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let ingredientResponse = try JSONDecoder().decode(IngredientResponse.self, from: data)
                    
                    let ingredients = ingredientResponse.meals
                    
                    completion(.success(ingredients))
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we get meals/recipes which contain the ingredients the user chose, through our public api
    // we check if we've got the data itself, then we decode it and give it back through the completion
    // if there's any error we give back a RestManagerError as a Result in the completion
    /// - Parameters:
    ///   - ingredients: ingredients array which contains ingredients chosen by the user
    ///   - completion: escaping closure which gives back a meal array or a rest manager error
    func getMeals(withIngredients ingredients: [Ingredient], completion: @escaping (Result<[Meal],RestManagerError>) -> Void) {
        let ingredientValues = prepareIngredientValues(from: ingredients)
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/filter.php?i=\(ingredientValues)") else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    if let meals = mealResponse.meals {
                        completion(.success(meals))
                    } else {
                        completion(.failure(.emptyStateError))
                    }
                } catch {
                    completion(.failure(.parseError))
                }
            }
            
            if error != nil {
                if error!.isConnectivityError {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.requestError))
                }
            }
        }.resume()
    }
    
    // we cancel all the running tasks
    func cancelTasks() {
        session.getAllTasks { tasks in
            tasks.forEach() { $0.cancel() }
        }
    }
    
    // MARK: - Supporting Methods
    
    // we prepare the given ingredients to be url ready
    // we trim each element of the array and append it to a string which we return at the end
    /// - Parameter ingredients: array of ingredients
    private func prepareIngredientValues(from ingredients: [Ingredient]) -> String {
        var values = String()
        for (idx, item) in ingredients.enumerated() {
            let trimmedString = item.strIngredient.replacingOccurrences(of: " ", with: "_").lowercased()
            if idx == ingredients.startIndex {
                values.append(trimmedString)
            } else {
                values.append(",\(trimmedString)")
            }
        }
        return values
    }
    
}
