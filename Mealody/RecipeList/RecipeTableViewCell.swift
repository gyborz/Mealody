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
    private var imageTask: URLSessionDataTask?
    
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
    
    func setupSavedRecipeCell(withMeal meal: HashableMeal) {
        recipeTitleLabel.text = meal.strMeal!
        let image = UIImage(data: meal.mealImage!)
        mealImageView.image = image
    }
    
    // we set the imageView's image nil first, so it won't 'blink' while the user scrolls through the tableView,
    // then we start the cell's activity indicator
    // if there's no imageTask (it's nil), then we initiate the download process with the given meal's url
    // we check if there was any error that was not a cancel error (prepareForReuse()) and safety check
    // if the cell's tag is the same as the indexPath.row (set in RecipeListVC's configureDataSource())
    // so the image we've got belongs to this specific cell
    // at the end we set the title label with the meal's/recipe's name
    func setupRecipeCell(withMeal meal: HashableMeal, forIndexPath indexPath: IndexPath) {
        mealImageView.image = nil
        activityIndicator.startAnimating()
        guard let url = URL(string: meal.strMealThumb!) else { return }
        if imageTask == nil {
            imageTask = ImageService.getImage(withURL: url) { (image, error) in
                if error != nil && error!._code != NSURLErrorCancelled {
                    self.activityIndicator.stopAnimating()
                    self.mealImageView.image = UIImage(named: "error")
                } else if self.tag == indexPath.row {
                    self.activityIndicator.stopAnimating()
                    self.mealImageView.image = image
                }
            }
        }
        recipeTitleLabel.text = meal.strMeal!
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTask?.cancel()
        imageTask = nil
        mealImageView.image = nil
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDelete?(self)
    }
    
}
