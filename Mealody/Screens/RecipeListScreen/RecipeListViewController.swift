//
//  RecipeListViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 31..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RecipeListViewController: UIViewController {
    
    // MARK: - Properties
    
    // properties for the tableView setup
    private enum Section {
        case main
    }
    private typealias HashableMealDataSource = UITableViewDiffableDataSource<Section, HashableMeal>
    private typealias HashableMealSnapshot = NSDiffableDataSourceSnapshot<Section, HashableMeal>
    private var hashableMeals = [HashableMeal]()
    private var dataSource: HashableMealDataSource!
    
    // singletons
    private let persistenceManager = PersistenceManager.shared
    private let restManager = RestManager.shared
    
    // properties for:
    private var isDeleting = false      // cell deletion (when the VC is showing saved recipes)
    enum ListType {
        case mealsByCategory            // recipe list which are from a given category
        case mealsByCountry             // recipe list which are from a given country
        case mealsByIngredients         // recipe list which recipes contain the given ingredients
    }
    var listType: ListType!             // what type of list the VC needs to present
    var isSavedRecipesList = true       // is the VC showing saved recipes or not
    var category = String()             // needed for REST
    var country = String()              // needed for REST
    var ingredients = [Ingredient]()    // needed for REST
    
    // MARK: - Outlets
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var recipeListTableView: UITableView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // we set the navigationBar's translucency in here, so when
    // the user stops with the view's dismiss (mid-swipe), then we have to make it visible again
    // after the view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // we update the snapshot here after we configure the data source in viewDidLoad (setupView())
    // this is necessary when we access the saved recipes, because if we do this in viewDidLoad
    // the tableView (it's superview) will may not yet be in the view hierarchy - this could cause bugs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }
    
    // we set up the tableView and the activityIndicator
    // if the VC is meant to be presented with the saved recipes, then we first load them from Core Data
    // otherwise we start requests depending on what type the list is gonna be (getData(), listType)
    // we configure the dataSource and if there's any error while fetching from Core Data we show a popup error
    private func setupView() {
        recipeListTableView.delegate = self
        recipeListTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        recipeListTableView.rowHeight = 390
        recipeListTableView.separatorStyle = .none
        
        activityIndicator.type = .lineScale
        activityIndicator.color = .systemOrange
        
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
    
    // we start the activity indicator, then request meals/recipes depending on what type of list the VC's gonna be
    // each time after we've got the meals we initialize a hashableMeal from each of them, then append those to the hashableMeals array
    // after that we stop the indicator and update the snapshot for the tableView
    // if there's any error we show a popup error
    private func getData() {
        self.activityIndicator.startAnimating()
        switch listType {
        case .mealsByCategory:
            restManager.getMeals(fromCategory: category) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.activityIndicator.stopAnimating()
                        self.updateSnapshot()
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        case .mealsByCountry:
            restManager.getMeals(fromCountry: country) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.activityIndicator.stopAnimating()
                        self.updateSnapshot()
                    case .failure(let error):
                        self.showPopupFor(error)
                    }
                }
            }
        case .mealsByIngredients:
            restManager.getMeals(withIngredients: ingredients) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        for meal in meals {
                            self.hashableMeals.append(HashableMeal(meal: meal))
                        }
                        self.activityIndicator.stopAnimating()
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
    
    // MARK: - Table View Handling
    
    // we update the snapshot and apply it to the dataSource
    private func updateSnapshot() {
        var snapshot = HashableMealSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(hashableMeals)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // we configure the dataSource of the tableView and set up the custom table view cell
    // if the VC shows the saved recipes, then we set up the cell according to that
    // whenever the user deletes a cell we get the corresponding hashableMeal and thus fetch the MealData from Core Data
    // we delete the hashableMeal from the array and delete the MealData from persistence, we save the changes and update the snapshot
    // if there's any error we show a popup error message
    // if the VC is not about saved recipes, then we set up the cell accordingly
    // we make the cell's delete button appear if the user wants to delete some recipes (trashButtonTapped(_:)
    private func configureDataSource() {
        dataSource = HashableMealDataSource(tableView: recipeListTableView, cellProvider: { (tableView, indexPath, hashableMeal) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
            if self.isSavedRecipesList {
                cell.setupSavedRecipeCell(withMeal: hashableMeal)
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
                cell.tag = indexPath.row
                cell.setupRecipeCell(withMeal: hashableMeal, forIndexPath: indexPath)
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
    
    // MARK: - Error Handling
    
    // we present a popup according to the error, with the help of the PopupDialog framework
    /// - Parameter error: the error we get from the rest manager
    private func showPopupFor(_ error: RestManagerError) {
        switch error {
        case .emptyStateError:
            switch listType {
            case .mealsByIngredients:
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
    
    // MARK: - UI Actions
    
    // we make the cell's delete button to disappear
    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {
        isDeleting.toggle()
        recipeListTableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - TableViewDelegate methods

extension RecipeListViewController: UITableViewDelegate {
    
    // when the user selects a row we set up some of it's values then present the RecipeVC modally
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let hashableMeal = dataSource.itemIdentifier(for: indexPath) else { return }
        let recipeVC = self.storyboard?.instantiateViewController(identifier: "RecipeVC") as! RecipeViewController
        recipeVC.modalPresentationStyle = .automatic
        recipeVC.hashableMeal = hashableMeal
        recipeVC.calledWithHashableMeal = true
        recipeVC.isHashableMealFromPersistence = isSavedRecipesList ? true : false
        self.present(recipeVC, animated: true) { [weak self] in
            self?.recipeListTableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
}
