//
//  Message.swift
//  Chat
//
//  Created by guest on H28/10/29.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId:String?
    var toId:String?
    var timeStamp:NSNumber?
    var message:String?
    
    func getPartnerUserId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
