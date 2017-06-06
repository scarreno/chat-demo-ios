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
        handleAddUser()
        
    }
    
    
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
        
        let dictionary = ["Name": name, "Email": email] as [String: AnyObject]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted]){
            let url = URL(string: "http://lagash-test-api.azurewebsites.net/api/form")!
            
            print(jsonData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if error != nil{
                    self.hideSpinner()
                    self.showMessage(text: "There has been an error!", title: "Error")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, let responseData = data , let responseString = String(data: responseData, encoding: .utf8) {
                    if httpResponse.statusCode == 200 {
                       
                        DispatchQueue.main.async {
                            self.setResultLabel(isOk: true, id: responseString)
                        }
                        
                    }else {
                        DispatchQueue.main.async {
                            self.setResultLabel(isOk: false, id: "")
                        }
                    }

                }
                
                DispatchQueue.main.async {
                    self.cleanForm()
                    self.hideSpinner()
                }
            }
            task.resume()
        }
        
    }
    
    func cleanForm(){
        nameTextField.text = ""
        emailTextField.text = ""
    }
    
    func setResultLabel(isOk: Bool, id: String){
        
        if isOk {
            self.resultLabel.setSuccessStyle()
            self.resultLabel.text = "User Added!, with string \(id)"
        }
        else{
            self.resultLabel.setErrorStyle()
            self.resultLabel.text = "Error!"
        }
    }
    
   
}

extension CreateUserViewController: UITextFieldDelegate{
    
    
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

}
