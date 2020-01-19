//
//  Extensions.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

extension String {
    func containsLetters() -> Bool {
        let filtered = self.trimmingCharacters(in: .whitespaces)
        return filtered.count > 0
    }
}

extension Error {
    var isConnectivityError: Bool {
        guard _domain == NSURLErrorDomain else { return false }

        let connectivityErrors = [NSURLErrorTimedOut,
                                  NSURLErrorNotConnectedToInternet,
                                  NSURLErrorNetworkConnectionLost,
                                  NSURLErrorCannotConnectToHost]

        return connectivityErrors.contains(_code)
    }
}
