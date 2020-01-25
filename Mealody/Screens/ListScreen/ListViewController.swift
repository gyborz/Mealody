//
//  ListViewController.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2020. 01. 06..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let restManager = RestManager.shared
    private var listItems = ListItems()             // ListItems struct holds the two hard coded arrays we need
    var isCategoryList = true
    
    // MARK: - View Handling

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // we register the custom cell, set the rowheight and the separator style
    private func setupTableView() {
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListItemCell")
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
    }
    
    // MARK: - Table View Data Source
    
    // we return the listItems' categories or countries arraycount depending on the value of isCategoryList
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCategoryList {
            return listItems.categories.count
        } else {
            return listItems.countries.count
        }
    }
    
    // we set up the custom cell according to if the VC is presented with categories or countries
    // we have an image already stored for each category/country, so we set up the cells with those
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
    
    // when the user selects a row we set up RecipeListVC before we present it
    // the setup depends on wether the ListVC shows categories or countries
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCategoryList {
            let category = listItems.categories[indexPath.row]
            let recipeListVC = self.storyboard?.instantiateViewController(identifier: "RecipeListVC") as! RecipeListViewController
            recipeListVC.isSavedRecipesList = false
            recipeListVC.listType = .mealsByCategory
            recipeListVC.category = category
            recipeListVC.navigationItem.title = category
            self.navigationController?.pushViewController(recipeListVC, animated: true)
        } else {
            let country = listItems.countries[indexPath.row]
            let recipeListVC = self.storyboard?.instantiateViewController(identifier: "RecipeListVC") as! RecipeListViewController
            recipeListVC.isSavedRecipesList = false
            recipeListVC.listType = .mealsByCountry
            recipeListVC.country = country
            recipeListVC.navigationItem.title = country
            self.navigationController?.pushViewController(recipeListVC, animated: true)
        }
    }
    
    // MARK: - UI Actions
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}

