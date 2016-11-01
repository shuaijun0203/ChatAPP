//
//  ChatLogController.swift
//  Chat
//
//  Created by guest on H28/10/27.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout{
    let cellId = "cellId"
    var messages = [Message]()
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            
            obeserveMessage()
        } 
    }
    
    func obeserveMessage(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if message.getPartnerUserId() == self.user?.id {
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }
                }
            }, withCancel: { (error) in
                print(error)
                return
            })
            
        }) { (error) in
            print(error)
            return
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
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.backgroundColor = UIColor.white
        
//        setupInputComponents()
        
//        setKeyboardShowAndHideObsever()
        
        collectionView?.keyboardDismissMode = .interactive

        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.lightGray
    
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(" send ", for: .normal)
        sendButton.backgroundColor = UIColor.white
        sendButton.addTarget(self, action: #selector(sendHandle), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputText)
        
        self.inputText.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        self.inputText.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputText.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.lightGray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        return containerView
        
    }()
    
    override var inputAccessoryView: UIView? {
        get {

            return inputContainerView
            
        }
        
        
    }
    
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setKeyboardShowAndHideObsever() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = -(keyboardFrame?.height )!
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }

    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCollectionViewCell

        let message = messages[indexPath.row]
        
        cell.textView.text = message.message
        
        if let message = message.message{
            
            cell.bubbleViewWidthAnchor?.constant = self.estimateTextSize(text: message).width + 32
            
        }
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    private func setupCell(cell:ChatLogCollectionViewCell,message:Message){
        if let chatPartnerProfileImageURL = user?.profileImage {
            cell.chatPartnerProfileImageView.downloadUIImageWithURLString(urlString: chatPartnerProfileImageURL)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            cell.bubbleView.backgroundColor = ChatLogCollectionViewCell.blueColor
            cell.textView.textColor = UIColor.white
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.chatPartnerProfileImageView.isHidden = true
        }else {
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.chatPartnerProfileImageView.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 70
        
        if let message = messages[indexPath.row].message {
            height = estimateTextSize(text: message).height + 20
        }
        
        
        return CGSize(width: UIScreen.main.bounds.width , height: height)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func estimateTextSize(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents(){
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)

        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(" send ", for: .normal)
        sendButton.backgroundColor = UIColor.white
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
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func sendHandle(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let toId = user!.id!
        let timeStamp:NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let values = ["message":inputText.text!,"fromId":fromId,"toId":toId,"timeStamp":timeStamp] as [String : Any]
    
        childRef.updateChildValues(values) { (error, ref) in
            
            self.inputText.text = nil
            let userMessageRef = FIRDatabase.database().reference().child("user-messages")
            let userMessageChildRef = userMessageRef.child(fromId)
            
            let messageId = childRef.key
            userMessageChildRef.updateChildValues([messageId:self.inputText.text!])
            
            let recipienMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipienMessageRef.updateChildValues([messageId:self.inputText.text!])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendHandle()
        
        return true
    }
}
