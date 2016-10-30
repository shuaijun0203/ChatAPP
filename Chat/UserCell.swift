//
//  UserCell.swift
//  Chat
//
//  Created by guest on H28/10/29.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase

class UserCell : UITableViewCell{
    var message:Message? {
        didSet {

            chatPartnerProfileSetup()
            
            detailTextLabel?.text = message?.message
            
            if let seconds = message?.timeStamp?.doubleValue {
                let date = NSDate(timeIntervalSince1970: seconds)
                let format = DateFormatter()
                format.dateFormat = "hh:mm:ss a"
                
                let strDate = format.string(from: date as Date)
                timeStamp.text = strDate.description
            }

        }
    }
    private func chatPartnerProfileSetup(){
        if let id = message?.getPartnerUserId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String :AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageURL = dictionary["profileImage"] as? String {
                        self.profileImageView.downloadUIImageWithURLString(urlString: profileImageURL)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        
    }
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        
        //imageView.image = UIImage(named: "default")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeStamp:UILabel = {
        let timeStamp = UILabel()
        timeStamp.font = UIFont.systemFont(ofSize: 13)
        timeStamp.textColor = UIColor.darkGray
        timeStamp.translatesAutoresizingMaskIntoConstraints = false
        
        return timeStamp
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeStamp)
        
        //profileImageView x,y,width,height
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        //timeStampLable x,y,width,height
        
        timeStamp.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeStamp.topAnchor.constraint(equalTo: self.topAnchor, constant: -8).isActive = true
        timeStamp.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeStamp.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
