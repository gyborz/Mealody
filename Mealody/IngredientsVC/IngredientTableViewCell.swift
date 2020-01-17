//
//  IngredientTableViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientView: UIView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var checkmarkView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
        
        ingredientView.layer.cornerRadius = ingredientView.frame.height / 2
        ingredientView.layer.shadowColor = UIColor.gray.cgColor
        ingredientView.layer.shadowOpacity = 0.5
        ingredientView.layer.shadowOffset = .init(width: 0, height: 2)
        ingredientView.layer.shadowRadius = 2.5
        
        checkmarkView.image = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if isSelected {
            checkmarkView.image = UIImage(systemName: "checkmark")
            ingredientView.backgroundColor = .systemOrange
        } else {
            checkmarkView.image = .none
            ingredientView.backgroundColor = .secondarySystemGroupedBackground
        }
    }
    
}
