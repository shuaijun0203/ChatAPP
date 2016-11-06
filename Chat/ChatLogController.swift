//
//  ChatLogController.swift
//  Chat
//
//  Created by guest on H28/10/27.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    let cellId = "cellId"
    var messages = [Message]()
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            
            obeserveMessage()
        } 
    }
    
    func obeserveMessage(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else{
            return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if message.getPartnerUserId() == self.user?.id {
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                            
                            // scroll to the end of collectionView
                            
                            let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                            
                            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
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
        
        setupInputComponents()
        
        setKeyboardShowAndHideObsever()
//        collectionView?.keyboardDismissMode = .interactive
        
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.lightGray
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "imgupload")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
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
            
            return nil
//            return self.inputContainerView
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
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
    
    func handleKeyboardDidShow(){
        
        if(messages.count > 0 ){
            
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCollectionViewCell
        
        cell.chatLogController = self

        let message = messages[indexPath.row]
        
        cell.message = message
        
        cell.textView.text = message.message
        
        setupCell(cell: cell, message: message)
        
        if let message = message.message{
            
            cell.bubbleViewWidthAnchor?.constant = self.estimateTextSize(text: message).width + 32
            
            cell.textView.isHidden = false
            
        }else if message.imageUrl != nil {
            
            cell.bubbleViewWidthAnchor?.constant = 200
            
            cell.textView.isHidden = true

        }
        
        cell.videoPlayButton.isHidden = message.videoUrl == nil
        
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
        
        if let imageUrl = message.imageUrl {
            cell.imageMessageView.downloadUIImageWithURLString(urlString: imageUrl)
            cell.imageMessageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.imageMessageView.isHidden = true
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 70
        
        let message = messages[indexPath.row]
        
        if let message = message.message {
            height = estimateTextSize(text: message).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
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
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "imgupload")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImg)))
        containerView.addSubview(uploadImageView)

        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
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
        
        inputText.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
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
    
    func handleUploadImg(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            handleSelectedVideoURL(url: videoUrl)
            
        }else {
            
            handleSelectedImageInfo(info: info)

        }
    }
    
    
    private func handleSelectedVideoURL(url:NSURL){
        let uploadFileName = NSUUID().uuidString + ".mp4"
        
        let videoUploadTask = FIRStorage.storage().reference().child("video-messages").child(uploadFileName).putFile(url as URL , metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.getThumbnailFromVideoURL(url: url){
                    
                    self.uploadToFirebaseWithImages(image: thumbnailImage, completion: { (imageUrl) in
                        
                        let properties = ["imageUrl":imageUrl,"imageWidth":thumbnailImage.size.width,"imageHeight":thumbnailImage.size.width,"videoUrl":videoUrl] as [String : Any]
                        self.sendMessageWithProperties(properties: properties as [String : AnyObject])

                    })
                }
            }
            
            self.dismiss(animated: true, completion: nil)
            
        })
        
        videoUploadTask.observe(.progress) { (snapshot) in
            
            self.navigationItem.title = String(describing: snapshot.progress?.completedUnitCount)
        }
        
        videoUploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func getThumbnailFromVideoURL(url:NSURL) -> UIImage? {
        
        let asset = AVAsset(url: url as URL)
        
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailIamge = try assetImageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailIamge)


        } catch let error {
            print(error)
        }
        return nil
    }
    private func handleSelectedImageInfo(info:[String:Any]){
        var imageFromPicker:UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            imageFromPicker = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageFromPicker = originalImage
        }
        if let selectedImage = imageFromPicker {
            uploadToFirebaseWithImages(image: selectedImage, completion: { (imageURL) in
                
                self.saveImageWithURLToFB(imageURL: imageURL,image:selectedImage)

            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseWithImages(image: UIImage, completion:@escaping (_ imageUrl:String)->()){
        let imageName = NSUUID().uuidString
        let uploadImageRef = FIRStorage.storage().reference().child("image-messages").child(imageName)
        
        if let uploadImage = UIImageJPEGRepresentation(image, 0.2) {
            
            uploadImageRef.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("unable to upload to the firebase ")
                    return
                }
                
                if let imageURL = metadata?.downloadURLs?[0].absoluteString{
                    
                    completion(imageURL)
                }
                
            })

        }
        
        dismiss(animated: true, completion: nil)

    }
    
    private func saveImageWithURLToFB(imageURL : String,image :UIImage){
        
        let properties = ["imageUrl":imageURL,"imageWidth":image.size.width,"imageHeight":image.size.width] as [String : Any]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
    }
    
    func sendHandle(){
        let properties = ["message":inputText.text!] as [String : Any]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
        
    }
    
    private func sendMessageWithProperties(properties :[String:AnyObject]){
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let toId = user!.id!
        let timeStamp:NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        var values: [String : AnyObject] = ["fromId":fromId as AnyObject,"toId":toId as AnyObject,"timeStamp":timeStamp]
        
        properties.forEach { (values[$0] = $1) }
        
        childRef.updateChildValues(values) { (error, ref) in
            
            self.inputText.text = nil
            let userMessageRef = FIRDatabase.database().reference().child("user-messages")
            let userMessageChildRef = userMessageRef.child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageChildRef.updateChildValues([messageId:self.inputText.text!])
            
            let recipienMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipienMessageRef.updateChildValues([messageId:self.inputText.text!])
        }

        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendHandle()
        
        return true
    }
    
    var startingImageFrame : CGRect?
    var backgroundView : UIView?
    var startingZoomInImageView: UIImageView?
    
    func handleStaringZoomInImageView(image:UIImageView){
        
        self.startingZoomInImageView = image
        self.startingZoomInImageView?.isHidden = true
        startingImageFrame = image.superview?.convert(image.frame, to: nil)
        
        let zoomInImageView  = UIImageView(frame: startingImageFrame!)
        zoomInImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapZoomOut)))
        zoomInImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow{
            self.backgroundView = UIView(frame: keyWindow.frame)
            self.backgroundView?.backgroundColor = UIColor.black
            self.backgroundView?.alpha = 0
            
            keyWindow.addSubview(self.backgroundView!)
            keyWindow.addSubview(zoomInImageView)
            
            if let tapZoomImage = image.image {
                
                zoomInImageView.image = tapZoomImage
                
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                
                self.backgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                if let width = self.startingImageFrame?.width, let height = self.startingImageFrame?.height {
                    
                    let height = width / height * keyWindow.frame.width

                    zoomInImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)

                }
                
                zoomInImageView.center = keyWindow.center
                
            }, completion: nil)
        }

    }
    
    func handleTapZoomOut(tapGesture:UITapGestureRecognizer){
        
        if let tapZoomOutImageView = tapGesture.view {
            
            
            
            UIView.animate(withDuration: 0.4 , delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                tapZoomOutImageView.frame = self.startingImageFrame!
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                
                tapZoomOutImageView.removeFromSuperview()
                self.startingZoomInImageView?.isHidden = false

            })
        }
        
    }
}
