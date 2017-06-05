//
//  ChatReceptorsTableViewCell.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/1/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class ChatReceptorsTableViewCell: UITableViewCell {

    
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var timeLabel: UILabel!
    
    var message: Message? {
        didSet{
            
            setupNameAndAvatar()
            
            if let seconds = self.message?.timestamp?.doubleValue{
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                self.timeLabel.setSmallLagashFont()
            }

        }
    }
    
    var user: LocalUser?{
        didSet{
            self.titleLabel.text = user?.name
            self.subTitleLabel.text = user?.email
            
            self.titleLabel.setTitleLagashFont()
            self.subTitleLabel.setMediumLagashFont()
            
            if let profileImageUrl = user?.profileImageUrl {
                self.userImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                self.userImageView.layer.borderWidth = 0.5
                self.userImageView.layer.borderColor = UIColor.black.cgColor
            }

        }
    }
    
    private func setupNameAndAvatar(){
               
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = LocalUser()
                    user.setValuesForKeys(dictionary)
                    
                    self.titleLabel.text = user.name
                    
                    if let text = self.message?.text {
                        if self.message?.fromId == Auth.auth().currentUser?.uid {
                            self.subTitleLabel.text = "You: \(text)"
                        }else{
                            self.subTitleLabel.text = text
                        }
                        
                    }else{
                        if self.message?.fromId == Auth.auth().currentUser?.uid {
                            self.subTitleLabel.text = "You: Sent an Image..."
                        }else{
                            self.subTitleLabel.text = "Sent an image..."
                        }
                    }
                    
                    self.titleLabel.setTitleLagashFont()
                    self.subTitleLabel.setMediumLagashFont()
                    
                    if let profileImageUrl = user.profileImageUrl {
                        self.userImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        self.userImageView.layer.borderWidth = 0.5
                        self.userImageView.layer.borderColor = UIColor.black.cgColor

                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
