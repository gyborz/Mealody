//
//  SavedLabel.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 11..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class SavedLabel: UIView {

    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        label = UILabel()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        
        label.text = "Recipe saved"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemOrange
        
        label.sizeToFit()
        
        label.layer.cornerRadius = 16.0
        label.layer.masksToBounds = true
        
        addShadow()
    }
    
    func addShadow() {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
    }

}
