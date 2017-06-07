//
//  CreateUserViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/6/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit

class CreateUserViewController: BaseViewController {

    @IBOutlet var TitleLabel: UILabel!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var nameTextField: UITextField!
    
    
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var addUserButton: UIButton!
    
    @IBOutlet var resultLabel: UILabel!
    @IBAction func addUserButtonPressed(_ sender: Any) {
        
        if self.userId == nil {
            handleAddUser()
        }else{
            handleUpdateUser()
        }
    
    }
    
    let apiRestManager = ApiRestManager()
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stylizeForm()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nameTextField.delegate = self
        emailTextField.delegate = self

        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select User", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSelectUser))
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSelectUser(){
        if let usersController = storyboard?.instantiateViewController(withIdentifier: "UsersTableViewController") as? UsersTableViewController{
            usersController.delegate = self
            let navController = UINavigationController(rootViewController: usersController)
            present(navController, animated: true, completion: nil)
            
        }
        
    }

    
    func stylizeForm(){
        nameTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        TitleLabel.setRegularLagashFont()
        emailLabel.setRegularLagashFont()
        nameLabel.setRegularLagashFont()
        addUserButton.setFontPrimaryButton()
        addUserButton.roundCorners()
    }
    
    func handleAddUser(){
        
        guard let name = nameTextField.text, let email = emailTextField.text else{
            return
        }
        
        
        if email == "" || name == "" {
            self.showMessage(text: "Complete the information", title: "Error")
            return
        }

        
        self.showSpinner()
        
        apiRestManager.addUser(name: name, email: email) { (userId, error) in
            
             if error != nil{
                self.showMessage(text: "There has been an error!", title: "Error")
                return
            }
            
            if let userId = userId {
                DispatchQueue.main.async {
                    self.resultLabel.text = "User Added!, with string \(userId)"
                    self.cleanForm()
                    self.hideSpinner()
                }
            }
        }
    }

    func handleUpdateUser(){
        
        guard let name = nameTextField.text, let email = emailTextField.text else{
            return
        }
        
        
        if email == "" || name == "" {
            self.showMessage(text: "Complete the information", title: "Error")
            return
        }
        
        
        self.showSpinner()
        
        let user = UserForm()
        user.userId = self.userId
        user.name = name
        user.email = email
        
            apiRestManager.updateUser(user: user, completionHandler: { (userId, error) in
                if error != nil{
                    self.showMessage(text: "There has been an error!", title: "Error")
                    return
                }
            
                if let userId = userId {
                    DispatchQueue.main.async {
                        self.resultLabel.text = "User Updated!"
                        self.cleanForm()
                        self.hideSpinner()
                    }
                }
            })
    }

    
    func cleanForm(){
        nameTextField.text = ""
        emailTextField.text = ""
        TitleLabel.text = "Create User"
        addUserButton.setTitle("Add User", for: UIControlState.normal)
    }
    
    
    
   
}

extension CreateUserViewController: UITextFieldDelegate, EditUserDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
            return true
        }
        else {
            textField.resignFirstResponder()
            self.handleAddUser()
            return true
        }        
    }
    
    func didSelectUser(user: UserForm) {
        self.userId = user.userId
        self.nameTextField.text = user.name
        self.emailTextField.text = user.email
        
        TitleLabel.text = "Edit User"
        addUserButton.setTitle("Edit User", for: UIControlState.normal)
    }

}
