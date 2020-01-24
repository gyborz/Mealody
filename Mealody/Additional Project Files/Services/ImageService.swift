//
//  ImageService.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 27..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ImageService {
    
    // MARK: - Properties
    
    static let cache = NSCache<NSString, UIImage>()
    
    private static let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        return URLSession(configuration: sessionConfig)
    }()
    
    // MARK: - Task Handling
    
    // we request an image download through a dataTask via the given url
    // if we get the image we save it to the cache then give it back, otherwise we give back an error through completion
    // we return the dataTask itself
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?, _ error: Error?)->()) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: url) { data, responseURL, error in
            var downloadedImage: UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(downloadedImage, nil)
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error!)
                }
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    // we call this function whenever we want to get an image
    // if we have the image cached already then we give it back through completion and return a nil,
    // otherwise we call the private downloadImage func, and return it's dataTask
    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?, _ error: Error?)->()) -> URLSessionDataTask? {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(image, nil)
            return nil
        } else {
            return downloadImage(withURL: url, completion: completion)
        }
    }
    
    // we cancel every ongoing tasks
    static func cancelTasks() {
        session.getAllTasks { tasks in
            tasks.forEach() { $0.cancel() }
        }
    }
    
}
