//
//  RecipeTableViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 01..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    var onDelete: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var recipeView: UIView!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .default
        self.backgroundColor = .clear
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
        
        recipeView.layer.cornerRadius = 15
        recipeView.clipsToBounds = true
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .init(width: 0, height: 3)
        layer.shadowRadius = 5
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        blurView.sendSubviewToBack(blurEffectView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            mealImageView.alpha = 0.8
        } else {
            mealImageView.alpha = 1
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDelete?(self)
    }
    
}
