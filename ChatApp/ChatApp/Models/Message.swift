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
    
    
    func chatPartnerId() -> String {
        return (fromId! == Auth.auth().currentUser?.uid ? toId : fromId)!

    }
    
    func cellIdentifier() -> String {
        return fromId != Auth.auth().currentUser?.uid ? "incomingMessageCell" : "outcomingMessageCell"
    }
}
