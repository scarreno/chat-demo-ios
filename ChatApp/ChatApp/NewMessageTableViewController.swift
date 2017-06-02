//
//  NewMessageViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/30/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

    var users = [LocalUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))

        fetchUsers()
    }

    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user =  LocalUser()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                
                if Auth.auth().currentUser?.email != user.email?.lowercased() {
                    self.users.append(user)
                    self.users.sort(by: { (user1, user2) -> Bool in
                        return user1.name! < user2.name!
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ChatReceptorsTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        
        return cell
    }

    var chatsTableViewController: ChatsTableViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let user = self.users[indexPath.row]
        dismiss(animated: true)
            
        self.chatsTableViewController?.showChatLogControllerForUser(user: user)
        print("leaving")
    }
    
}
