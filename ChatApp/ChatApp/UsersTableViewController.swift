//
//  UsersTableViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/6/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit



protocol EditUserDelegate{
    
    func didSelectUser(user: UserForm)
}


class UsersTableViewController: UITableViewController {

    var users = [UserForm]()
    var refreshControlView: UIRefreshControl?
    let apiRestManager = ApiRestManager()
    
    var delegate: EditUserDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "User Selection"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doCancel))
        
        addRefreshControl()
        
        self.refreshControlView?.beginRefreshing()
        handleRefresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    func addRefreshControl(){
        
        refreshControlView = UIRefreshControl()
        refreshControlView?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControlView?.tintColor = UIColor(r: 30, g: 75, b: 240)
        refreshControlView?.attributedTitle = NSAttributedString(string: "Fetching Users...")
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControlView
        } else {
            tableView.addSubview(refreshControlView!)
        }
    }
    
    func handleRefresh(){
        
        users.removeAll()
        
        
        apiRestManager.getUsers { (users, error) in
            
            if error != nil {
                return
            }
            
            if let usersArray = users {
                self.users = users!
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControlView?.endRefreshing()
                }
            }
        }
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)

        let user = users[indexPath.row]
        
        cell.setBottomBorder()
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }
    
    
    func doCancel(){
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        
        print("Selected User: \(selectedUser.userId)")
        if delegate != nil {
            delegate?.didSelectUser(user: selectedUser)
            dismiss(animated: true, completion: nil)
        }
    }

}
