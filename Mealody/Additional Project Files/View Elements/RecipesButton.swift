//
//  RecipesButton.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 15..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipesButton: UIView {

    // MARK: - Properties
    
    var button: UIButton!           // button on the view
    var isVisible: Bool!            // is the view visible or not
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    // we set up a button on the view with constraints then add a shadow to it
    func setup() {
        isVisible = false
        
        button = UIButton()
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "arrow.right")
        let attributedTitle = NSMutableAttributedString(string: "Recipes  ", attributes: [
            NSAttributedString.Key.foregroundColor:UIColor.darkText,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium)
        ])
        attributedTitle.append(NSAttributedString(attachment: imageAttachment))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.backgroundColor = .white
        
        button.sizeToFit()
        
        button.layer.cornerRadius = 17.5
        
        addShadow()
    }
    
    // we set up a shadow
    func addShadow() {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
    }

}
