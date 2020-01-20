//
//  ImageService.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 27..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    
    private static let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        return URLSession(configuration: sessionConfig)
    }()
    
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?, _ url: URL, _ error: Error?)->()) {
        let dataTask = session.dataTask(with: url) { data, responseURL, error in
            var downloadedImage: UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(downloadedImage, url, nil)
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, url, error!)
                }
            }
        }
        
        dataTask.resume()
    }
    
    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?, _ url: URL, _ error: Error?)->()) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(image, url, nil)
        } else {
            downloadImage(withURL: url, completion: completion)
        }
    }
    
    static func cancelTasks() {
        session.getAllTasks { tasks in
            tasks.forEach() { $0.cancel() }
        }
    }
}
