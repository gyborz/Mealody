//
//  IngredientsViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class IngredientsViewController: UIViewController {
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    private let restManager = RestManager()
    private var ingredients = [Ingredient]()
    
    // tableView properties:
    private enum Section {
        case main
    }
    private typealias IngredientDataSource = UITableViewDiffableDataSource<Section, Ingredient>
    private typealias IngredientSnapshot = NSDiffableDataSourceSnapshot<Section, Ingredient>
    private var dataSource: IngredientDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsTableView.allowsMultipleSelection = true
        
        getData()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
    }

    private func getData() {
        restManager.getIngredients { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredients):
                    self.ingredients = ingredients
                    self.updateSnapshot(from: ingredients)
                case .failure(let error):
                    // TODO: - error handling
                    print(error)
                }
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = IngredientDataSource(tableView: ingredientsTableView, cellProvider: { (tableView, indexPath, ingredient) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = ingredient.strIngredient
            let backgroundView = UIView()
            backgroundView.backgroundColor = .systemOrange
            cell.selectedBackgroundView = backgroundView
//            if self.selectedIngredients.contains(ingredient) {
//                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//                cell.isSelected = true
//            }
            cell.accessoryType = cell.isSelected ? .checkmark : .none
            return cell
        })
    }
    
    private func updateSnapshot(from ingredients: [Ingredient]) {
        var snapshot = IngredientSnapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(ingredients)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

//extension IngredientsViewController: UITableViewDelegate {
//}
