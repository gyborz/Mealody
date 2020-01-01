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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        tableView.rowHeight = 390
        tableView.separatorStyle = .none
        
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = HashableMealSnapshot()
        let savedMeals = persistenceManager.load(MealData.self)
        for mealData in savedMeals {
            meals.append(HashableMeal(mealData: mealData))
        }
        snapshot.appendSections([.main])
        snapshot.appendItems(meals)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = HashableMealDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, hashableMeal) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
            cell.mealImageView.image = UIImage(data: hashableMeal.mealImage!)
            cell.recipeTitleLabel.text = hashableMeal.strMeal
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
        self.present(recipeVC, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension RecipeListViewController: UIGestureRecognizerDelegate {
}
