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
        deleteButton.layer.shadowColor = UIColor.black.cgColor
        deleteButton.layer.shadowOpacity = 0.3
        deleteButton.layer.shadowOffset = .init(width: 0, height: 3)
        deleteButton.layer.shadowRadius = 1.5
        
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
    
    func setUpSavedRecipeCell(withMeal meal: HashableMeal) {
        recipeTitleLabel.text = meal.strMeal!
        let image = UIImage(data: meal.mealImage!)
        mealImageView.image = image
    }
    
    func setUpRecipeCell(withMeal meal: HashableMeal) {
        self.mealImageView.image = nil  // we set the image nil first so it won't 'blink' when it tries to download the correct image (while scrolling in the app)
        guard let url = URL(string: meal.strMealThumb!) else { return }
        ImageService.getImage(withURL: url) { (image) in
            self.mealImageView.image = image
        }
        recipeTitleLabel.text = meal.strMeal!
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDelete?(self)
    }
    
}
