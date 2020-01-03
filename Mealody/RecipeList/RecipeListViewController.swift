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
    private var meals = [HashableMeal]()
    private typealias HashableMealDataSource = UITableViewDiffableDataSource<Section, HashableMeal>
    private typealias HashableMealSnapshot = NSDiffableDataSourceSnapshot<Section, HashableMeal>
    private var dataSource: HashableMealDataSource!
    private let persistenceManager = PersistenceManager.shared
    let isSavedRecipesList: Bool = true
    private var isDeleting = false
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        tableView.rowHeight = 390
        tableView.separatorStyle = .none
        
        if isSavedRecipesList {
            var savedMeals = persistenceManager.load(MealData.self)
            savedMeals.reverse()
            for mealData in savedMeals {
                meals.append(HashableMeal(mealData: mealData))
            }
            configureDataSource()
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = HashableMealSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(meals)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureDataSource() {
        dataSource = HashableMealDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, hashableMeal) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
            cell.mealImageView.image = UIImage(data: hashableMeal.mealImage!)
            cell.recipeTitleLabel.text = hashableMeal.strMeal
            
            if self.isDeleting {
                UIView.animate(withDuration: 0.3) {
                    cell.deleteButton.alpha = 1
                }
            } else {
                cell.deleteButton.alpha = 0
            }
            
            cell.onDelete = { [weak self] cell in
                guard let self = self else { return }
                guard let hashableMeal = self.dataSource.itemIdentifier(for: tableView.indexPath(for: cell)!) else { return }
                guard let fetchedMeal = self.persistenceManager.fetchMeal(MealData.self, idMeal: hashableMeal.idMeal!) else { return }
                self.persistenceManager.delete(fetchedMeal)
                self.meals.removeAll() { $0 == hashableMeal }
                self.updateSnapshot()
                self.persistenceManager.saveContext()
            }
            return cell
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let hashableMeal = dataSource.itemIdentifier(for: indexPath) else { return }
        let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
        recipeVC.modalPresentationStyle = .automatic
        recipeVC.hashableMeal = hashableMeal
        recipeVC.calledWithHashableMeal = true
        self.present(recipeVC, animated: true) { [weak self] in
            self?.tableView.deselectRow(at: indexPath, animated: true)
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

extension RecipeListViewController: UIGestureRecognizerDelegate {
}
