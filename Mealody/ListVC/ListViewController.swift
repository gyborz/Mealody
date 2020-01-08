//
//  ListViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    private var listItems = ListItems()
    var isCategoryList = true
    private var restManager = RestManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListItemCell")
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCategoryList {
            return listItems.categories.count
        } else {
            return listItems.countries.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemCell", for: indexPath) as! ListTableViewCell

        if isCategoryList {
            cell.listItemLabel.text = listItems.categories[indexPath.row]
            let imageName = listItems.categories[indexPath.row].lowercased()
            cell.listItemImageView.image = UIImage(named: imageName)
        } else {
            cell.listItemLabel.text = listItems.countries[indexPath.row]
            let imageName = listItems.countries[indexPath.row].lowercased()
            cell.listItemImageView.image = UIImage(named: imageName)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCategoryList {
            let category = listItems.categories[indexPath.row]
            restManager.getMeals(fromCategory: category) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let meals):
                        let recipeListVC = self.storyboard?.instantiateViewController(identifier: "RecipeListVC") as! RecipeListViewController
                        recipeListVC.isSavedRecipesList = false
                        recipeListVC.meals = meals
                        recipeListVC.navigationItem.title = category
                        self.navigationController?.pushViewController(recipeListVC, animated: true)
                    case .failure(let error):
                        // TODO: - error handling
                        print(error)
                    }
                }
            }
        }
    }

}

