//
//  CardViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    private var ingredients = [Ingredient]()
    var deselectionDelegate: DeselectionDelegate!
    
    // collectionView properties
    private enum Section {
        case main
    }
    private typealias IngredientsDataSource = UICollectionViewDiffableDataSource<Section, Ingredient>
    private typealias IngredientsSnapshot = NSDiffableDataSourceSnapshot<Section, Ingredient>
    private var dataSource: IngredientsDataSource!
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        handle.layer.cornerRadius = 3.5
        
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowOffset = .init(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 2.5
        
        ingredientsCollectionView.backgroundColor = .systemOrange
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.register(UINib(nibName: "IngredientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IngredientCell")
        
        let parentVC = parent as! IngredientsViewController
        parentVC.updateDelegate = self
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = IngredientsDataSource(collectionView: ingredientsCollectionView, cellProvider: { (collectionView, indexPath, ingredient) -> UICollectionViewCell? in
            let cell = self.ingredientsCollectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCell", for: indexPath) as! IngredientCollectionViewCell
            cell.ingredientLabel.text = ingredient.strIngredient
            cell.deletionDelegate = self
            return cell
        })
    }

    private func updateSnapshot(from ingredients: [Ingredient]) {
        var snapshot = IngredientsSnapshot()

        snapshot.appendSections([.main])
        snapshot.appendItems(ingredients)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

extension CardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (dataSource.itemIdentifier(for: indexPath)?.strIngredient.size(withAttributes: nil).width)!
        return CGSize(width: width + 100, height: 30)
    }
    
}

extension CardViewController: UpdateChosenIngredientsDelegate {
    
    func updateIngredients(chosenIngredients: [Ingredient]) {
        ingredients = chosenIngredients
        updateSnapshot(from: ingredients)
    }
    
}

extension CardViewController: CellDeletionDelegate {
    
    func deleteCell(_ cell: IngredientCollectionViewCell) {
        ingredients.removeAll() { $0.strIngredient == cell.ingredientLabel.text }
        updateSnapshot(from: ingredients)
        deselectionDelegate.deselectIngredient(ingredient: cell.ingredientLabel.text!)
    }
    
}

extension CardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        } else {
            return true
        }
    }
    
}
