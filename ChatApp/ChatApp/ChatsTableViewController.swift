//
//  ChatsTableViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class ChatsTableViewController: UITableViewController {

    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        
        //observeMessages()
        observeUserMessages()
    }
    
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageId)
            
            messageReference.observe(DataEventType.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() as? String {
                        
                            self.messageDictionary[chatPartnerId] = message
                        
                            self.messages = Array(self.messageDictionary.values)
                            self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                            })
                    }
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func observeMessages(){
            let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if let toId = message.toId{
                    self.messageDictionary[toId] = message
                    
                    self.messages = Array(self.messageDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
        }, withCancel: nil)
    }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleLogout()
            }
        }else {
           fetchUserAndSetupNavBar()
        }

    }
    
    func fetchUserAndSetupNavBar(){
        //if for some reason this is = nil
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid)
            .observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let user = LocalUser()
                    user.setValuesForKeys(dictionary)
                    self.setupNavBarWithUser(user: user)
                }
            })
    }
    
    func setupNavBarWithUser(user :LocalUser){
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatLogController)))
    }
    
    func showChatLogController(){
        if let chatLogController = storyboard?.instantiateViewController(withIdentifier: "ChatLogViewController") {
            navigationController?.pushViewController(chatLogController, animated: true)
        }
    }
    
    func showChatLogControllerForUser(user: LocalUser){
        if let chatLogController = storyboard?.instantiateViewController(withIdentifier: "ChatLogViewController") as? ChatLogViewController {
            chatLogController.receptorUser = user
            navigationController?.pushViewController(chatLogController, animated: true)
        }
    }

    
    
    func handleNewMessage() {
        if let newMessageView = storyboard?.instantiateViewController(withIdentifier: "NewMessageTableViewController") as? NewMessageTableViewController {
            newMessageView.chatsTableViewController = self
            let navController = UINavigationController(rootViewController: newMessageView)
            present(navController, animated: true, completion: nil)
        }
    }
    func handleLogout(){
        do{
            try Auth.auth().signOut()
            
            messages.removeAll()
            messageDictionary.removeAll()
            tableView.reloadData()
            
        }catch let logoutError {
            print(logoutError)
        }
        if let loginView = storyboard?.instantiateViewController(withIdentifier: "LoginTableViewController") as? LoginTableViewController {
            loginView.chatController = self
            present(loginView, animated: true, completion: nil)
        }
        
    }
    
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell", for: indexPath) as! ChatReceptorsTableViewCell
        let message = messages[indexPath.row]
        
        cell.message = message
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() as? String else {
            return
        }
        
       let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = LocalUser()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.showChatLogControllerForUser(user: user)
            }
            
        }, withCancel: nil)
        
        
        //showChatLogControllerForUser(user: user)
    }

}