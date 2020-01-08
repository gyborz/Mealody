//
//  RestManager.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 27..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

enum RestManagerError: Error {
    case unknownError
    case requestError
}

class RestManager {
    
    private let apiKey = "9973533"
    
    func getRandomMeal(completion: @escaping (Result<Meal,RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/random.php") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    guard let meal = mealResponse.meals?.first else { return }
                    
                    completion(.success(meal))
                } catch {
                    completion(.failure(.unknownError))
                }
            }
            
            if error != nil {
                completion(.failure(.requestError))
            }
        }.resume()
    }
    
    func getMeals(fromCategory category: String, completion: @escaping (Result<[Meal],RestManagerError>) -> Void) {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v2/\(apiKey)/filter.php?c=\(category)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                do {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    
                    guard let meals = mealResponse.meals else { return }
                    
                    completion(.success(meals))
                } catch {
                    completion(.failure(.unknownError))
                }
            }
            
            if error != nil {
                completion(.failure(.requestError))
            }
        }.resume()
    }
    
}
