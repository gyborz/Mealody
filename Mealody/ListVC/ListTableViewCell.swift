//
//  ListTableViewCell.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var listItemImageView: UIImageView!
    @IBOutlet weak var listItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .default
        self.backgroundColor = .clear
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
        
        listItemView.clipsToBounds = true
        listItemView.layer.cornerRadius = listItemView.frame.height / 2
        listItemView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        listItemView.layer.masksToBounds = false
        listItemView.layer.shadowOffset = CGSize(width: 0, height: 5)
        listItemView.layer.shadowRadius = 1.5
        listItemView.layer.shadowColor = UIColor.black.cgColor
        listItemView.layer.shadowOpacity = 0.3
        
        listItemImageView.layer.cornerRadius = listItemView.frame.height / 2
        listItemImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if isSelected {
            listItemView.alpha = 0.8
        } else {
            listItemView.alpha = 1
        }
    }
    
}
