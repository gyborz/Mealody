//
//  RecipeListViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 31..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeListViewController: UITableViewController {
    
    private enum Section {
        case main
    }
    private var hashableMeals = [HashableMeal]()
    private typealias HashableMealDataSource = UITableViewDiffableDataSource<Section, HashableMeal>
    private typealias HashableMealSnapshot = NSDiffableDataSourceSnapshot<Section, HashableMeal>
    private var dataSource: HashableMealDataSource!
    private let persistenceManager = PersistenceManager.shared
    private var isDeleting = false
    private let restManager = RestManager()
    var isSavedRecipesList: Bool = true
    var isCategoryList = true
    var category = String()
    var country = String()
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        tableView.rowHeight = 390
        tableView.separatorStyle = .none
        
        if isSavedRecipesList {
            var savedMeals = persistenceManager.load(MealData.self)
            savedMeals.reverse()
            for mealData in savedMeals {
                hashableMeals.append(HashableMeal(mealData: mealData))
            }
            configureDataSource()
        } else {
            getData()
            self.navigationItem.rightBarButtonItem = nil
            configureDataSource()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    private func getData() {
        if isCategoryList {
            restManager.getMeals(fromCategory: category) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.updateSnapshot()
                    case .failure(let error):
                        // TODO: - error handling
                        print(error)
                    }
                }
            }
        }
    }
    
    private func updateSnapshot() {
        var snapshot = HashableMealSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(hashableMeals)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureDataSource() {
        dataSource = HashableMealDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, hashableMeal) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
            
            if self.isSavedRecipesList {
                cell.setUpSavedRecipeCell(withMeal: hashableMeal)
                cell.onDelete = { [weak self] cell in
                    guard let self = self else { return }
                    guard let hashableMeal = self.dataSource.itemIdentifier(for: tableView.indexPath(for: cell)!) else { return }
                    guard let fetchedMeal = self.persistenceManager.fetchMeal(MealData.self, idMeal: hashableMeal.idMeal!) else { return }
                    self.persistenceManager.delete(fetchedMeal)
                    self.hashableMeals.removeAll() { $0 == hashableMeal }
                    self.updateSnapshot()
                    self.persistenceManager.saveContext()
                }
            } else {
                cell.setUpRecipeCell(withMeal: hashableMeal)
            }
            
            if self.isDeleting {
                UIView.animate(withDuration: 0.3) {
                    cell.deleteButton.alpha = 1
                }
            } else {
                cell.deleteButton.alpha = 0
            }
            
            return cell
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let hashableMeal = dataSource.itemIdentifier(for: indexPath) else { return }
        let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
        recipeVC.modalPresentationStyle = .automatic
        recipeVC.hashableMeal = hashableMeal
        recipeVC.calledWithHashableMeal = true
        self.present(recipeVC, animated: true) { [weak self] in
            self?.tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {
        isDeleting.toggle()
        tableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

