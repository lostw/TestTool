//
//  AccountListViewController.swift
//  Alamofire
//
//  Created by William on 2019/11/19.
//

import UIKit

class AccountListController: UITableViewController {
    var list = [[String: String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "账号管理"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let addItem = UIBarButtonItem(title: "新增", style: .plain, target: self, action: #selector(add))
        self.navigationItem.rightBarButtonItems = [self.editButtonItem, addItem]

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.list = UserDefaults[.loginAccount, []]
        tableView.reloadData()
    }

    @objc func add() {
        self.showController(AccountFormController())
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = model["desc"]
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.list.remove(at: indexPath.row)
            UserDefaults[.loginAccount] = self.list
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let target = self.list.remove(at: fromIndexPath.row)
        self.list.insert(target, at: to.row)
        UserDefaults[.loginAccount] = self.list
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
