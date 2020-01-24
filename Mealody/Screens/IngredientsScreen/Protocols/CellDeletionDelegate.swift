//
//  CellDeletionDelegate.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Foundation

// protocol implemented by CardViewController
protocol CellDeletionDelegate {
    func deleteCell(_ cell: IngredientCollectionViewCell)
}
