//
//  RestManagerError.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 18..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

enum RestManagerError: Error {
    case requestError
    case emptyStateError
    case parseError
    case networkError
    case cancelledError
}
