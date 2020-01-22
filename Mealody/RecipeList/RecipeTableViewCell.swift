//
//  RecipeTableViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 01..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RecipeTableViewCell: UITableViewCell {
    
    var onDelete: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var recipeView: UIView!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

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
        
        activityIndicator.type = .lineScale
        activityIndicator.color = .systemOrange
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
        mealImageView.image = nil  // we set the image nil first so it won't 'blink' when it tries to download the correct image (while scrolling in the app)
        activityIndicator.startAnimating()
        
        // we check if the url of the image we fetched and the url of the meal we have is equal
        // this is needed so we avoid the possibility that an another image gets fetched faster (because of smaller size for example)
        // than the original one, which truly belongs to the recipe
        guard let url = URL(string: meal.strMealThumb!) else { return }
        ImageService.getImage(withURL: url) { (image, urlCheck, error) in
            if error != nil || image == nil {
                self.mealImageView.image = UIImage(named: "error")
            } else if url.absoluteString == urlCheck.absoluteString {
                self.mealImageView.image = image
            } else {
                self.mealImageView.image = UIImage(named: "error")
            }
            self.activityIndicator.stopAnimating()
        }
        recipeTitleLabel.text = meal.strMeal!
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDelete?(self)
    }
    
}
