//
//  IngredientsViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class IngredientsViewController: UIViewController {
    
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
    
    // CardViewController properties
    private enum CardState {
        case expanded
        case collapsed
    }
    private var cardViewController: CardViewController!
    private var cardHeight: CGFloat!
    private let cardHandleAreaHeight: CGFloat = 65
    
    private var cardVisible = false
    private var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    private let minimumScreenRatioToHide: CGFloat = 0.3
    private let animationDuration = 0.7
    
    @IBOutlet weak var ingredientsTableView: UITableView!

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
        setupCard()
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
        
        //cardViewController.deselectionDelegate = self
    }
    
    @objc func handleCardTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: animationDuration)
        default:
            break
        }
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self.cardViewController.view)
        switch recognizer.state {
        case .began:
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
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
            
        case .ended:
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            
            let isCardToBeHidden = (abs(translation.y) > cardViewController.view.frame.size.height * minimumScreenRatioToHide)
            if isCardToBeHidden && !cardVisible {
                print("cardVisible is false and user swiped up enough - card will be expanded")
                continueInteractiveTransition()
            } else if isCardToBeHidden && cardVisible {
                print("cardVisible is true and the user swiped down enough - card will be collapsed")
                continueInteractiveTransition()
            } else if !isCardToBeHidden && cardVisible {
                print("cardVisible is true, user started swiping but not low enough so we reverse the animations so the card expands")
                stopAnimations()
                cardVisible = false
                startInteractiveTransition(state: nextState, duration: animationDuration)
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
                continueInteractiveTransition()
            } else if !isCardToBeHidden && !cardVisible {
                print("cardVisible is false, user started swiping but not high enough so we reverse the animations so the card retracts")
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
                if !self.runningAnimations.isEmpty {    // safety check, runningAnimations can cause an error here, when the pangestures are used "intensely"
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
    
    private func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    private func stopAnimations() {
        for animator in runningAnimations {
            animator.stopAnimation(true)
        }
        runningAnimations.removeAll()
    }
    
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
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
