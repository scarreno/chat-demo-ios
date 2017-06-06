//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class LoginTableViewController: BaseTableViewController {

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var loginRegisterButton: UIButton!
    
    @IBOutlet var createAccountButton: UIButton!
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        goToSignup()
    }
    
    @IBAction func btnRegisterPressed(_ sender: Any) {
            doLogin()
    }
    
    var isProfilePictureLoaded: Bool = false
    var chatController: ChatsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        StylizeForm()
        
        addKeyboardGesture()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
    }
    
    func addKeyboardGesture(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func StylizeForm(){
        passwordTextField.setBottomBorder()
        emailTextField.setBottomBorder()
        
        loginRegisterButton.setFontPrimaryButton()
        createAccountButton.setFontSecondaryButton()
        
        emailTextField.setRegularLagashFont()
        passwordTextField.setRegularLagashFont()
        
        loginRegisterButton.roundCorners()
    }

    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func doLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                return
        }
        
        if email == "" || password == "" {
            showMessage(text: "Enter user/password", title: "Oops!")
            return
        }
        
        self.dismissKeyboard()
        self.showSpinner()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user: User?, error) in
            if error != nil {
                self.showMessage(text: "There has been an error trying to signin", title: "Error!")
                self.hideSpinner()
                return
            }
            
            self.chatController?.fetchCurrentUser()
            self.hideSpinner()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func goToSignup(){
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
            doLogin()
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

