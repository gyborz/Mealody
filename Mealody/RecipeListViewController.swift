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
            let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath)
            cell.textLabel?.text = hashableMeal.strMeal
            return cell
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension RecipeListViewController: UIGestureRecognizerDelegate {
}
