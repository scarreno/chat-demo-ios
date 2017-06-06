//
//  UsersTableViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/6/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    var users = [UserForm]()
    var refreshControlView: UIRefreshControl?
    
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
        print("get data!")
            let url = URL(string: "http://lagash-test-api.azurewebsites.net/api/form")!
            
        
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
        
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if error != nil{
                    print(error)
                    return
                }else {
                    do {
                        
                        if let responseData = data {
                            let parsedData = try JSONSerialization.jsonObject(with: responseData, options: []) as! [AnyObject]
                            
                            
                            for object in parsedData {
                                if let name = object["Name"], let email = object["Email"], let uid = object["id"] {
                                    let user = UserForm()
                                    user.name = name as! String
                                    user.email = email as! String
                                    user.userId = uid as! String
                                    self.users.append(user)
                                }
                                
                                
                                print()
                            }
                        }
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControlView?.endRefreshing()
                }
            }
            task.resume()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)

        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }
    
    
    func doCancel(){
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        print("Selected User: \(user.userId)")

    }

}
