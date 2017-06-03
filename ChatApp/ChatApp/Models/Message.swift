//
//  Message.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/1/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    
    func chatPartnerId() -> String {
        return (fromId! == Auth.auth().currentUser?.uid ? toId : fromId)!

    }
    
    func cellIdentifier() -> String {
        return fromId != Auth.auth().currentUser?.uid ? "incomingMessageCell" : "outcomingMessageCell"
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
}
