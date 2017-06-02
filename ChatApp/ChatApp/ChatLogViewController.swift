//
//  ChatLogViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/31/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController {

    @IBOutlet var inputContainerView: UIView!
    @IBOutlet var inputMessageTextView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var inputContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var inputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        sendMessage()
    }
    
    var messages = [Message]()
    var receptorUser: LocalUser? {
        didSet{
            if let user = receptorUser {
                setupNavBarWithUser(user: user)
                observeMessages()
            }
            
        }
    }
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(DataEventType.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observe(DataEventType.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if message.fromId == self.receptorUser?.id || message.toId == self.receptorUser?.id {
                    self.messages.append(message)
                    self.tableView.reloadData()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inputMessageTextView.layer.cornerRadius = 10
        inputMessageTextView.layer.masksToBounds = true
        inputMessageTextView.delegate = self
        
        inputMessageTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputMessageTextView.layer.borderWidth = 0.5
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.resizeInputTextView()
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5)
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        inputContainerView.layer.addSublayer(topBorder)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
    }
    
    func resizeInputTextView(){
        let sizeThatFitsTextView = inputMessageTextView.sizeThatFits(CGSize(width: inputMessageTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        print(sizeThatFitsTextView)
        inputContainerHeightConstraint.constant = sizeThatFitsTextView.height + 10;
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        self.inputMessageTextView.setContentOffset(.zero, animated: false)
    }
    
    func sendMessage(){
        guard let fromId = Auth.auth().currentUser?.uid else {
            return
        }

        print(receptorUser)
        
        if let message = inputMessageTextView.text {
            let ref = Database.database().reference().child("messages")
            let timestamp: Int = (Int(NSDate().timeIntervalSince1970) as? Int)!
            let toId = receptorUser!.id!
            let values = ["text": message, "fromId": fromId, "toId": toId, "timestamp": timestamp] as [String : Any]
            let childRef = ref.childByAutoId()
            childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil{
                    print(error)
                    return
                }
                
                let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
                
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId: 1])
                
                let userMessageRecipientRef = Database.database().reference().child("user-messages").child(toId)
                userMessageRecipientRef.updateChildValues([messageId: 1])
                
            })
        }
        
        inputMessageTextView.text = ""
        inputMessageTextView.resignFirstResponder()
        self.resizeInputTextView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo{
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if(endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.inputContainerBottomConstraint?.constant = 0.0
            }else
            {
                self.inputContainerBottomConstraint.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {self.view.layoutIfNeeded()},
                           completion: nil)
            
        }
    }

    
    func setupNavBarWithUser(user :LocalUser){
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ChatLogViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let sizeThatFitsTextView = inputMessageTextView.sizeThatFits(CGSize(width: inputMessageTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        inputContainerHeightConstraint.constant = sizeThatFitsTextView.height + 10;
        
    }
    
}

extension ChatLogViewController: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return messages.count
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(80)
        
        if let text = messages[indexPath.row].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        return height;
    }
    
    func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 215, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)], context: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: message.cellIdentifier(), for: indexPath) as! MessageTableViewCell
        
        print("\(message.cellIdentifier()), texto: \(message.text)")
        cell.messageTextView.text = message.text
        
        
        if message.cellIdentifier() == "incomingMessageCell" {
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.messageTextView.textColor = UIColor.black
        }else {
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            cell.messageTextView.textColor = UIColor.white
        }
        
        return cell
    }
    
    
}
