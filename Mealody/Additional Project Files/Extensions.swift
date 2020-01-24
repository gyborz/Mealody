//
//  Extensions.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

extension String {
    // we trim down the whitespaces from both ends and return if there's any letters left or no
    func containsLetters() -> Bool {
        let filtered = self.trimmingCharacters(in: .whitespaces)
        return filtered.count > 0
    }
}

extension Error {
    // we check if the error itself is a type of a network error
    var isConnectivityError: Bool {
        guard _domain == NSURLErrorDomain else { return false }

        let connectivityErrors = [NSURLErrorTimedOut,
                                  NSURLErrorNotConnectedToInternet,
                                  NSURLErrorNetworkConnectionLost,
                                  NSURLErrorCannotConnectToHost]

        return connectivityErrors.contains(_code)
    }
    
    // we check if the error itself is a cancel error
    var isCancelledError: Bool {
        guard _domain == NSURLErrorDomain else { return false }
        return _code == NSURLErrorCancelled
    }
}
