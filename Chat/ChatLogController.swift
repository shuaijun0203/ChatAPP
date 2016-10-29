//
//  ChatLogController.swift
//  Chat
//
//  Created by guest on H28/10/27.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate{
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
        } 
    }
    
    lazy var inputText: UITextField = {
        let messageInputTextField = UITextField()
        messageInputTextField.placeholder = " Enter the Message... "
        messageInputTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextField.delegate = self 
        return messageInputTextField
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.lightGray
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)

        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(" send ", for: .normal)
        sendButton.backgroundColor = UIColor.red
        sendButton.addTarget(self, action: #selector(sendHandle), for: .touchUpInside)

        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        
        containerView.addSubview(inputText)
        
        inputText.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        inputText.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputText.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.lightGray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func sendHandle(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let toId = user!.id!
        let timeStamp = NSDate().timeIntervalSince1970
        childRef.updateChildValues(["message":inputText.text!,"fromId":fromId,"toId":toId,"timeStamp":timeStamp])
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendHandle()
        
        return true
    }
}
