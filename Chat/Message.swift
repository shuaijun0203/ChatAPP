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
    
    var imageUrl:String?
    var videoUrl:String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    func getPartnerUserId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        videoUrl = dictionary["videoUrl"] as? String
        message = dictionary["message"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    
    }
}
