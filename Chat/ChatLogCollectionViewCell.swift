//
//  ChatLogCollectionViewCell.swift
//  Chat
//
//  Created by guest on H28/10/30.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit

class ChatLogCollectionViewCell: UICollectionViewCell {
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.lightGray
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 139, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let chatPartnerProfileImageView : UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "jesus")
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        return profileImageView
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bubbleView)
        self.addSubview(textView)
        self.addSubview(chatPartnerProfileImageView)
        
        chatPartnerProfileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4).isActive = true
        chatPartnerProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        chatPartnerProfileImageView.widthAnchor.constraint(equalToConstant:32).isActive = true
        chatPartnerProfileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor)
        bubbleViewRightAnchor!.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: chatPartnerProfileImageView.rightAnchor, constant: 4)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant:200)
        bubbleViewWidthAnchor!.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
