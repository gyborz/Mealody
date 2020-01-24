//
//  IngredientsViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class IngredientsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let restManager = RestManager.shared
    private var ingredients = [Ingredient]()
    var updateDelegate: UpdateChosenIngredientsDelegate!            // for updating the card view controller's collection view
    
    // tableView properties:
    private enum Section {
        case main
    }
    private typealias IngredientsDataSource = UITableViewDiffableDataSource<Section, Ingredient>
    private typealias IngredientsSnapshot = NSDiffableDataSourceSnapshot<Section, Ingredient>
    private var dataSource: IngredientsDataSource!
    
    // searchController properties:
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredIngredients = [Ingredient]()                // contains the ingredients which are filtered by the searchController
    private var selectedIngredients = [Ingredient]()                // contains the ingredients which are selected by the user
    
    // cardViewController properties:
    private enum CardState {
        case expanded                                               // card is visible
        case collapsed                                              // card is hidden (only the 'handle area' is visible)
    }
    private var cardViewController: CardViewController!
    private var cardHeight: CGFloat!                                // height of the card
    private let cardHandleAreaHeight: CGFloat = 65                  // height of the 'handle area', which is visible in any CardState
    
    private var cardVisible = false                                 // card is expanded or collapsed
    private var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    private let minimumScreenRatioToHide: CGFloat = 0.3             // minimum ratio at which point the card will be triggered to expand/collapse
    private let animationDuration = 0.7
    
    // recipesButton properties:
    var recipesButton: RecipesButton!
    var recipesButtonTopAnchor: NSLayoutConstraint!                 // we have to keep track of this anchor so we can animate the button up and down
    
    // MARK: - Outlets
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        setupRecipesButton()
        
        getData()
        configureDataSource()
        setupCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // we set up the tableView, the searchController and the activity indicator
    private func setupView() {
        ingredientsTableView.separatorStyle = .none
        ingredientsTableView.allowsMultipleSelection = true
        ingredientsTableView.rowHeight = 50
        ingredientsTableView.register(UINib(nibName: "IngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ingredients"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        activityIndicator.type = .lineScale
        activityIndicator.color = .systemOrange
    }
    
    // we set up the recipes button programmatically
    private func setupRecipesButton() {
        recipesButton = RecipesButton()
        view.addSubview(recipesButton)
        recipesButton.translatesAutoresizingMaskIntoConstraints = false
        recipesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recipesButtonTopAnchor = recipesButton.topAnchor.constraint(equalTo: view.bottomAnchor)
        recipesButtonTopAnchor.isActive = true
        recipesButton.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        recipesButton.widthAnchor.constraint(equalToConstant: recipesButton.button.bounds.width + 10).isActive = true
        
        recipesButton.button.addTarget(self, action: #selector(showRecipes), for: .touchUpInside)
    }

    // we start the activity indicator and then initialize a request to get all the ingredients
    // after we've got them we stop the indicator and update the snapshot
    // if there's any error we show a popup error message
    private func getData() {
        activityIndicator.startAnimating()
        restManager.getIngredients { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredients):
                    self.activityIndicator.stopAnimating()
                    self.ingredients = ingredients
                    self.updateSnapshot(from: ingredients)
                case .failure(let error):
                    self.showPopupFor(error)
                }
            }
        }
    }
    
    // MARK: - Table View Handling
    
    // we set up the tableView's data source with our custom cell
    // we set the cell's label and we make it appear selected if the selectedIngredients array contains the given ingredient
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
    
    // we update the snapshot and apply it to the dataSource
    /// - Parameter ingredients: ingredients array we update the snapshot with
    private func updateSnapshot(from ingredients: [Ingredient]) {
        var snapshot = IngredientsSnapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(ingredients)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Card Setup Methods
    
    // we set up the CardVC as a child view controller
    // we set it's height, it's frame, add gestures for tapping and panning and make this VC it's deselection delegate
    private func setupCard() {
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardHeight = self.view.frame.height * 0.75
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        panGestureRecognizer.delegate = cardViewController
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.view.addGestureRecognizer(panGestureRecognizer)
        
        cardViewController.deselectionDelegate = self
    }
    
    // if the user taps on the handle area we initialize the transition to the next state
    /// - Parameter recognzier: the tap gesture recognizer which we're handling
    @objc private func handleCardTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: animationDuration)
        default:
            break
        }
    }
    
    // we handle the pan gesture on the card
    /// - Parameter recognizer: the pan gesture recognizer which we're handling
    @objc private func handleCardPan(recognizer: UIPanGestureRecognizer) {
        // first we get the velocity of the pan on the card
        let velocity = recognizer.velocity(in: self.cardViewController.view)
        switch recognizer.state {
        case .began:
            // when the gesture begins we check the card's current position (visible or not), if there are animations going on
            // and where the pan is going (up/down)
            // if needed we toggle the visible flag so the animations can follow up on the pan ( == change directions)
            if cardVisible && velocity.y > 0 && runningAnimations.isEmpty {
                startInteractiveTransition(state: nextState, duration: animationDuration)
            } else if cardVisible && velocity.y > 0 && !runningAnimations.isEmpty {
                cardVisible.toggle()
                startInteractiveTransition(state: nextState, duration: animationDuration)
            } else if !cardVisible && velocity.y < 0 && runningAnimations.isEmpty {
                startInteractiveTransition(state: nextState, duration: animationDuration)
            } else if !cardVisible && velocity.y < 0 && !runningAnimations.isEmpty {
                cardVisible.toggle()
                startInteractiveTransition(state: nextState, duration: animationDuration)
            }
            
        case .changed:
            // when the gesture changes we get the translation and calculate the completed fraction from it
            // we update the animations accordingly
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
            
        case .ended:
            // when the gesture ends we get the translation and calculate the completed fraction from it
            // we check if the translation was longer, than the minimum card screen ratio at which point the card
            // should be triggered to expand or collapse
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            
            let isLimitSurpassed = (abs(translation.y) > cardViewController.view.frame.size.height * minimumScreenRatioToHide)
            if isLimitSurpassed && !cardVisible {
                // if the card was collapsed originally and the user swiped up high enough, the card will be expanded
                continueInteractiveTransition()
            } else if isLimitSurpassed && cardVisible {
                // if the card was expanded originally and the user swiped down low enough, the card will be collapsed
                continueInteractiveTransition()
            } else if !isLimitSurpassed && cardVisible {
                // if the card was expanded originally and the user started swipind down, but didn't get low enough
                // we stop the ongoing animations, set the visible flag and restart, then update the animations
                stopAnimations()
                cardVisible = false
                startInteractiveTransition(state: nextState, duration: animationDuration)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
                continueInteractiveTransition()
            } else if !isLimitSurpassed && !cardVisible {
                // if the card was collapsed originally and the user started swiping up, but didn't get high enough
                // we stop the ongoing animations, set the visible flag and restart, then update the animations
                stopAnimations()
                cardVisible = true
                startInteractiveTransition(state: nextState, duration: animationDuration)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
                continueInteractiveTransition()
            }
        default:
            break
        }
    }
    
    // we set up the animations to the given state with the given duration
    // if there are no animations runnning, then we set them up starting with the frame's animation
    // we set up an animation for the corner radius too; we start them up and append them to an array of animations
    /// - Parameters:
    ///   - state: the card's state - it's collapsed / hidden or expanded / visible
    ///   - duration: the animation's duration
    private func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight + self.view.safeAreaInsets.bottom
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { _ in
                if !self.runningAnimations.isEmpty {    // safety check
                    self.cardVisible = !self.cardVisible
                    self.stopAnimations()
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration / 2, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 25
                    self.cardViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
        }
    }
    
    // if there are no animations running we create and start them (animateTransitionIfNeeded(::) above)
    // regardless of that we pause all the animations and save the completed fraction
    /// - Parameters:
    ///   - state: the card's state - it's collapsed / hidden or expanded / visible
    ///   - duration: the animation's duration
    private func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    // we stop all the animations and remove them from the animations array
    private func stopAnimations() {
        for animator in runningAnimations {
            animator.stopAnimation(true)
        }
        runningAnimations.removeAll()
    }
    
    // we update each animations' completed fraction value
    /// - Parameter fractionCompleted: the fraction which is already done by the animation
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    // we resume the animations
    private func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    // MARK: - RecipesButton methods
    
    // we animate the RecipesButton to appear/disappear depending on the given bool value
    // after the animation we toggle the button's visible flag
    /// - Parameter hidden: is the recipe button currently visible or not
    private func toggleRecipesButton(hidden: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.recipesButtonTopAnchor.constant = -115.0
                self.view.layoutIfNeeded()
            }, completion: nil)
            recipesButton.isVisible.toggle()
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.recipesButtonTopAnchor.constant = 115
                self.view.layoutIfNeeded()
            }, completion: nil)
            recipesButton.isVisible.toggle()
        }
    }
    
    // if the user selected no more than 4 ingredients we set up the RecipeListVC's values and present it
    // otherwise we show a popup error message
    @objc private func showRecipes() {
        if selectedIngredients.count <= 4 {
            let recipeListVC = self.storyboard?.instantiateViewController(identifier: "RecipeListVC") as! RecipeListViewController
            recipeListVC.isSavedRecipesList = false
            recipeListVC.listType = .mealsByIngredients
            recipeListVC.ingredients = selectedIngredients
            recipeListVC.navigationItem.title = "Recipes"
            self.navigationController?.pushViewController(recipeListVC, animated: true)
        } else {
            let popup = PopupService.ingredientsError(withMessage: "You can only choose 4 ingredients!", completion: nil)
            present(popup, animated: true)
        }
    }
    
    // MARK: - Error Handling
    
    // we present a popup according to the error, with the help of the PopupDialog framework
    /// - Parameter error: the error we get from the rest manager
    private func showPopupFor(_ error: RestManagerError) {
        switch error {
        case .emptyStateError:
            let popup = PopupService.emptyStateError(withMessage: "Something went wrong.\nPlease try again!") {
                self.navigationController?.popViewController(animated: true)
            }
            self.present(popup, animated: true)
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
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Table View Delegate Methods

extension IngredientsViewController: UITableViewDelegate {
    
    // upon cell selection we get the selected ingredient, append it to the selected ing. array,
    // we update the card view controller's collection view through delegation, then toggle the recipes button if it's not visible
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ingredient = dataSource.itemIdentifier(for: indexPath) else { return }
        selectedIngredients.append(ingredient)
        updateDelegate.updateIngredients(chosenIngredients: selectedIngredients)
        if !recipesButton.isVisible {
            toggleRecipesButton(hidden: true)
        }
    }
    
    // upon cell deselection we get the selected ingredient, remove it from the selected ing. array,
    // we update the card view controller's collection view through delegation, then toggle the recipes button if the selected ing. array is empty
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let ingredient = dataSource.itemIdentifier(for: indexPath) else { return }
        selectedIngredients.removeAll() { $0 == ingredient }
        updateDelegate.updateIngredients(chosenIngredients: selectedIngredients)
        if selectedIngredients.isEmpty {
            toggleRecipesButton(hidden: false)
        }
    }
    
}

// MARK: - Search Results Updating Methods

extension IngredientsViewController: UISearchResultsUpdating {
    
    // when the user makes changes in the searchBar we filter the ingredients accordingly
    // we update the tableView's snapshot with these filtered ingredients
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

// MARK: - Deselection Delegate Methods

extension IngredientsViewController: DeselectionDelegate {
    
    
    // we remove the given ingredient from the selected ing. array, then toggle the recipe button if the array is empty
    // we reload the table view
    /// - Parameter ingredient: the ingredient to remove
    func deselectIngredient(ingredient: String) {
        selectedIngredients.removeAll() { $0.strIngredient == ingredient }
        if selectedIngredients.isEmpty {
            toggleRecipesButton(hidden: false)
        }
        ingredientsTableView.reloadData()
    }
    
}
