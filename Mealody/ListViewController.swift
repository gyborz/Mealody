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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = listItems.categories[indexPath.row]

        return cell
    }

}

extension ListViewController: UIGestureRecognizerDelegate {
}
