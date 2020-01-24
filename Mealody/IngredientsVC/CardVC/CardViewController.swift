//
//  CardViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    // MARK: - Properties
    
    private var ingredients = [Ingredient]()                // ingredients array for the collection view
    var deselectionDelegate: DeselectionDelegate!           // for updating the ingredients view controller's table view
    
    // collectionView properties
    private enum Section {
        case main
    }
    private typealias IngredientsDataSource = UICollectionViewDiffableDataSource<Section, Ingredient>
    private typealias IngredientsSnapshot = NSDiffableDataSourceSnapshot<Section, Ingredient>
    private var dataSource: IngredientsDataSource!
    
    // MARK: - Outlets
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        configureDataSource()
    }
    
    // we set up the UI elements of the view starting with the handle
    // we add shadow to the title label, we set up the collection view with our custom cell and set this VC the parent's update delegate
    private func setupView() {
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
    }
    
    // MARK: - Collection View Handling
    
    // we configure the collection view's data source with our custom cell
    // we set each cell's label to display the ingredients and set this VC their deletion delegate
    private func configureDataSource() {
        dataSource = IngredientsDataSource(collectionView: ingredientsCollectionView, cellProvider: { (collectionView, indexPath, ingredient) -> UICollectionViewCell? in
            let cell = self.ingredientsCollectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCell", for: indexPath) as! IngredientCollectionViewCell
            cell.ingredientLabel.text = ingredient.strIngredient
            cell.deletionDelegate = self
            return cell
        })
    }
    
    // we update the snapshot and apply it to the dataSource
    /// - Parameter ingredients: ingredients array we update the snapshot with
    private func updateSnapshot(from ingredients: [Ingredient]) {
        var snapshot = IngredientsSnapshot()

        snapshot.appendSections([.main])
        snapshot.appendItems(ingredients)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

// MARK: - Collection View Delegate / Collection View Delegate Flow Layout Methods

extension CardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // we set each cell's width according to it's ingredient's string width
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (dataSource.itemIdentifier(for: indexPath)?.strIngredient.size(withAttributes: nil).width)!
        return CGSize(width: width + 110, height: 30)
    }
    
}

// MARK: - Update Chosen Ingredients Delegate

extension CardViewController: UpdateChosenIngredientsDelegate {
    
    
    // we set our ingredients array with the given array and update the collection view's snapshot
    /// - Parameter chosenIngredients: the ingredients that were selected in IngredientsViewController
    func updateIngredients(chosenIngredients: [Ingredient]) {
        ingredients = chosenIngredients
        updateSnapshot(from: ingredients)
    }
    
}

// MARK: - Cell Deletion Delegate

extension CardViewController: CellDeletionDelegate {
    
    // we remove the cell's ingredient from our ingredient array and update the collection view's snapshot
    // we deselect the ingredient in IngredientsViewController through delegation
    /// - Parameter cell: the cell that the user tapped to delete
    func deleteCell(_ cell: IngredientCollectionViewCell) {
        ingredients.removeAll() { $0.strIngredient == cell.ingredientLabel.text }
        updateSnapshot(from: ingredients)
        deselectionDelegate.deselectIngredient(ingredient: cell.ingredientLabel.text!)
    }
    
}

// MARK: - Gesture Recognizer Delegate

extension CardViewController: UIGestureRecognizerDelegate {
    
    // we differentiate between the card's pangesture and the collection view's pangesture so both of them can function at the same time
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        } else {
            return true
        }
    }
    
}
