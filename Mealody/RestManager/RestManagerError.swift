//
//  RestManagerError.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 18..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

enum RestManagerError: Error {
    case requestError                   // something went wrong during the request process
    case emptyStateError                // response we've got back is nil
    case parseError                     // couldn't decode the json
    case networkError                   // network related problem occured
    case cancelledError                 // when the request got cancelled
}
