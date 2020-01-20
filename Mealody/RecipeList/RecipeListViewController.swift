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
    private let restManager = RestManager.shared
    private var isDeleting = false
    
    enum ListType {
        case category
        case country
        case ingredients
    }
    var listType: ListType!
    var isSavedRecipesList = true
    var category = String()
    var country = String()
    var ingredients = [Ingredient]()
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        tableView.rowHeight = 390
        tableView.separatorStyle = .none
        
        if isSavedRecipesList {
            do {
                var savedMeals = try persistenceManager.load(MealData.self)
                savedMeals.reverse()
                for mealData in savedMeals {
                    hashableMeals.append(HashableMeal(mealData: mealData))
                }
                configureDataSource()
            } catch {
                let popup = PopupService.persistenceError(withMessage: "Couldn't get the saved recipes") {
                    self.navigationController?.popViewController(animated: true)
                }
                present(popup, animated: true)
            }
        } else {
            getData()
            self.navigationItem.rightBarButtonItem = nil
            configureDataSource()
        }
    }
    
    // we set the navigationBar's translucency in here, so when
    // the user stops with the view's dismiss (mid-swipe), then we have to make it visible again
    // after the view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // we update the snapshot here after we configure the data source in viewDidLoad
    // this is necessary when we access the saved recipes, because if we do this in viewDidLoad
    // the tableView (it's superview) will may not yet be in the view hierarchy - this could cause bugs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    private func getData() {
        switch listType {
        case .category:
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
                        self.showPopupFor(error)
                    }
                }
            }
        case .country:
            restManager.getMeals(fromCountry: country) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.updateSnapshot()
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        case .ingredients:
            restManager.getMeals(withIngredients: ingredients) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.updateSnapshot()
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        default:
            let popup = PopupService.presentationError(withMessage: "Something went wrong!") {
                self.navigationController?.popViewController(animated: true)
            }
            present(popup, animated: true)
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
                    
                    do {
                        guard let fetchedMeal = try self.persistenceManager.fetchMeal(MealData.self, idMeal: hashableMeal.idMeal!) else { return }
                        self.persistenceManager.delete(fetchedMeal)
                        try self.persistenceManager.saveContext()
                        self.hashableMeals.removeAll() { $0 == hashableMeal }
                        self.updateSnapshot()
                    } catch {
                        self.persistenceManager.context.rollback()
                        let popup = PopupService.persistenceError(withMessage: "Something went wrong while deleting!", completion: nil)
                        self.present(popup, animated: true)
                    }
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
        if isSavedRecipesList {
            guard let hashableMeal = dataSource.itemIdentifier(for: indexPath) else { return }
            let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
            recipeVC.modalPresentationStyle = .automatic
            recipeVC.hashableMeal = hashableMeal
            recipeVC.calledWithHashableMeal = true
            recipeVC.isHashableMealFromPersistence = true
            self.present(recipeVC, animated: true) { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }
        } else {
            guard let hashableMeal = dataSource.itemIdentifier(for: indexPath) else { return }
            let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
            recipeVC.modalPresentationStyle = .automatic
            recipeVC.hashableMeal = hashableMeal
            recipeVC.calledWithHashableMeal = true
            recipeVC.isHashableMealFromPersistence = false
            self.present(recipeVC, animated: true) { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    private func showPopupFor(_ error: RestManagerError) {
        switch error {
        case .emptyStateError:
            switch listType {
            case .ingredients:
                let popup = PopupService.ingredientsError(withMessage: "Looks like there are no recipes with the selected ingredients.") {
                    self.navigationController?.popViewController(animated: true)
                }
                self.present(popup, animated: true)
            default:
                let popup = PopupService.emptyStateError(withMessage: "Something went wrong.\nPlease try again!") {
                    self.navigationController?.popViewController(animated: true)
                }
                self.present(popup, animated: true)
            }
        case .parseError:
            let popup = PopupService.parseError(withMessage: "Couldn't get the data.\nPlease try again!") {
                self.navigationController?.popViewController(animated: true)
            }
            self.present(popup, animated: true)
        case .networkError:
            let popup = PopupService.networkError(withMessage: "Please check your connection!") {
                self.navigationController?.popViewController(animated: true)
            }
            self.present(popup, animated: true)
        case .requestError:
            let popup = PopupService.requestError(withMessage: "Something went wrong.\nPlease try again!") {
                self.navigationController?.popViewController(animated: true)
            }
            self.present(popup, animated: true)
        case .cancelledError:
            // this can not happen in this VC
            return
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

