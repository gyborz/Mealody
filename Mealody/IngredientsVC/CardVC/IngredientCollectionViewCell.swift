//
//  IngredientCollectionViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    
    var deletionDelegate: CellDeletionDelegate!
    
    @IBOutlet weak var ingredientCellView: UIView!
    @IBOutlet weak var ingredientLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ingredientCellView.layer.cornerRadius = ingredientCellView.frame.height / 2
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deletionDelegate.deleteCell(self)
    }

}
