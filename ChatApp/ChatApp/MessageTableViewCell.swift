//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/1/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    
    @IBOutlet var messageTextView: UITextView!
    
    @IBOutlet var bubbleView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.messageTextView.backgroundColor = UIColor.clear
        self.bubbleView.layer.cornerRadius = 5
        self.bubbleView.layer.masksToBounds = true

    }

}
