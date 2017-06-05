//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class LoginTableViewController: UITableViewController {

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var loginRegisterButton: UIButton!
    
    @IBOutlet var createAccountButton: UIButton!
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        handleSignup()
    }
    
    @IBAction func btnRegisterPressed(_ sender: Any) {
            handleLogin()
    }
    
    var isProfilePictureLoaded: Bool = false
    var chatController: ChatsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        StylizeForm()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loginRegisterButton.layer.cornerRadius = 5
        loginRegisterButton.layer.masksToBounds  = true
        
        
        
    }
    
    func StylizeForm(){
        passwordTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        
        loginRegisterButton.setFontPrimaryButton()
        createAccountButton.setFontSecondaryButton()
        
        emailTextField.setRegularLagashFont()
        passwordTextField.setRegularLagashFont()
    }

    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
   
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                return
        }
        
        if email == "" || password == "" {
            showMessage(text: "Enter user/password", title: "Oops!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user: User?, error) in
            if error != nil {
                self.showMessage(text: "There has been an error trying to signin", title: "Error!")
                /*
                if let errorMessage = error {
                    print(errorMessage)
                }
                */
                return
            }
            
            self.chatController?.fetchUserAndSetupNavBar()
            //let chatsController = self.storyboard?.instantiateViewController(withIdentifier: "ChatsNavigationController")
            //self.present(chatsController!, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            
            print("Login success!")
        }
    }
    
    func handleSignup(){
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension LoginTableViewController: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        else{
            textField.resignFirstResponder()
            return true
        }
    }
    
    
    
}


extension UITableViewController {
    func showMessage(text: String, title: String){
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

