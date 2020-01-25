//
//  IngredientCollectionViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var deletionDelegate: CellDeletionDelegate!               // for deleting the cell from the card view controller's collection view
    
    // MARK: - Outlets
    
    @IBOutlet weak var ingredientCellView: UIView!
    @IBOutlet weak var ingredientLabel: UILabel!

    // MARK: - Cell UI setup
    
    // we add corner radius to the ingredient cell view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ingredientCellView.layer.cornerRadius = ingredientCellView.frame.height / 2
    }
    
    // MARK: - UI Actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deletionDelegate.deleteCell(self)
    }

}
