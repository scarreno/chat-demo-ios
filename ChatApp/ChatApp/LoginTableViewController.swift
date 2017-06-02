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

    @IBOutlet var inputsContainerView: UIView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var loginRegisterButton: UIButton!
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var inputsContainerHeightContraint: NSLayoutConstraint!
    @IBOutlet var loginSegmentedControl: UISegmentedControl!
    
    @IBAction func btnRegisterPressed(_ sender: Any) {
        if loginSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else {
            registerUser()
        }
    }
    
    var isProfilePictureLoaded: Bool = false
    var chatController: ChatsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds  = true
       
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loginSegmentedControl.addTarget(self, action: #selector(handleSegmentedControlChangeValue), for: .valueChanged)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageSelection)))
        profileImageView.isUserInteractionEnabled = true
        
        
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.backgroundColor = UIColor.white
        profileImageView.layer.masksToBounds  = true
        
        loginSegmentedControl.layer.cornerRadius = 5
        loginSegmentedControl.layer.masksToBounds  = true
        
        loginRegisterButton.layer.cornerRadius = 5
        loginRegisterButton.layer.masksToBounds  = true
        
        nameTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        emailTextField.setBottomBorder()

        
    }
    

    
    func handleSegmentedControlChangeValue() {
        let selectedIndex = loginSegmentedControl.selectedSegmentIndex
        let title = loginSegmentedControl.titleForSegment(at: selectedIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        if selectedIndex == 0 {
            nameTextField.isHidden = true
            inputsContainerHeightContraint.constant = 110
            profileImageView.isHidden = true
        }
        else {
            nameTextField.isHidden = false
            inputsContainerHeightContraint.constant = 160
            profileImageView.isHidden = false
        }
        
        self.nameTextField.text = ""
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
    }
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func registerUser(){
        
        if !self.isProfilePictureLoaded {
            showMessage(text: "Select a picture!", title: "Oops!")
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                return
        }
        
        if email == "" || password == "" || name == "" {
            showMessage(text: "Fill the fields!", title: "Oops!")
            return
        }
        
        Auth.auth().createUser(withEmail: email.lowercased(), password: password,
                               completion: { (user: User?, error) in
                                if error != nil {
                                    print(error)
                                    self.showMessage(text: "There has been an error trying to register", title: "Error!")
                                    return
                                }
                                
                                guard let uid = user?.uid else {
                                    return
                                }
                                //success!
                                
                                let imageName = NSUUID().uuidString
                                let storageRef = Storage.storage().reference().child("\(imageName).jpg")
                                
                                if let profileImage = self.profileImageView.image,  let uploadData = UIImageJPEGRepresentation(profileImage, 0.2) {
                                
                                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                        if error != nil {
                                            self.showMessage(text: "There has been an error uploading the profile picture", title: "Error!")
                                            return
                                        }
                                    
                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                                            self.registerUserIntoDb(uid: uid, values: values as [String : AnyObject])
                                        }
                                    })
                                }
                })
    }
    
    func registerUserIntoDb(uid: String, values: [String: AnyObject]){
        
        let ref = Database.database().reference()
        let userReferences = ref.child("users").child(uid)
        
        userReferences.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                self.showMessage(text: "There has been an error registering the user in the BD", title: "Error!")
                return
            }
        })
        
        print("User successfully added")
        
        self.nameTextField.text = ""
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.profileImageView.image = nil
        
        //self.chatController?.navigationItem.title = values["name"] as? String
        let user = LocalUser()
        user.setValuesForKeys(values)
        self.chatController?.setupNavBarWithUser(user: user)
        
        self.dismiss(animated: true, completion: nil)
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
            self.dismiss(animated: true, completion: nil)
            
            print("Login success!")
        }
    }
    
}

extension UITextField {
    func setBottomBorder() {
        
        let width = CGFloat(0.5)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        bottomBorder.borderWidth = width
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(bottomBorder)
        self.layer.masksToBounds = true
    }
}

extension LoginTableViewController: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
            return true
        }
        else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        else{
            textField.resignFirstResponder()
            registerUser()
            return true
        }
    }
    
    func handleProfileImageSelection() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
       
        var selectedImage : UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                selectedImage = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let pickedImage = selectedImage {
            profileImageView.image = selectedImage
            self.isProfilePictureLoaded = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled Picker")
        self.isProfilePictureLoaded = false
        dismiss(animated: true, completion: nil)
    }
    
}


extension UITableViewController {
    func showMessage(text: String, title: String){
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

