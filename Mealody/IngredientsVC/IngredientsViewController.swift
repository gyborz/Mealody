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
    private typealias IngredientsDataSource = UITableViewDiffableDataSource<Section, Ingredient>
    private typealias IngredientsSnapshot = NSDiffableDataSourceSnapshot<Section, Ingredient>
    private var dataSource: IngredientsDataSource!
    
    // searchController properties:
    let searchController = UISearchController(searchResultsController: nil)
    private var filteredIngredients = [Ingredient]()
    private var selectedIngredients = [Ingredient]()

    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsTableView.separatorStyle = .none
        ingredientsTableView.allowsMultipleSelection = true
        ingredientsTableView.rowHeight = 50
        ingredientsTableView.register(UINib(nibName: "IngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Ingredients"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
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
        dataSource = IngredientsDataSource(tableView: ingredientsTableView, cellProvider: { (tableView, indexPath, ingredient) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientTableViewCell
            cell.ingredientLabel.text = ingredient.strIngredient
            if self.selectedIngredients.contains(ingredient) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        })
    }
    
    private func updateSnapshot(from ingredients: [Ingredient]) {
        var snapshot = IngredientsSnapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(ingredients)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension IngredientsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ingredient = dataSource.itemIdentifier(for: indexPath) else { return }
        selectedIngredients.append(ingredient)
        //updateDelegate.updateIngredients(chosenIngredients: selectedIngredients)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let ingredient = dataSource.itemIdentifier(for: indexPath) else { return }
        selectedIngredients.removeAll() { $0 == ingredient }
        //updateDelegate.updateIngredients(chosenIngredients: selectedIngredients)
    }
    
}

extension IngredientsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredIngredients = ingredients.filter { (ingredient: Ingredient) -> Bool in
                return ingredient.strIngredient.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredIngredients = ingredients
        }
        updateSnapshot(from: filteredIngredients)
    }
    
}
