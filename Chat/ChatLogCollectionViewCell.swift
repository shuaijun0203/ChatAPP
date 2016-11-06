//
//  ChatLogCollectionViewCell.swift
//  Chat
//
//  Created by guest on H28/10/30.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import AVFoundation

class ChatLogCollectionViewCell: UICollectionViewCell {
    
    var chatLogController : ChatLogController?
    
    var message: Message?
    
    // progressStatusIndicator
    let videoLoadingStatusIndicator : UIActivityIndicatorView  = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        
        return aiv
    }()
    
    lazy var videoPlayButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        let icon = UIImage(named: "play-button")
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(handleVideoPlay), for:.touchUpInside)
        
        return button
    }()
    
    var avPlayerLayer: AVPlayerLayer?
    var avPlayer: AVPlayer?
    
    func handleVideoPlay(){
        
        if let videoURL = message?.videoUrl,let url = NSURL(string: videoURL) {
            
            avPlayer = AVPlayer(url: url as URL)
            avPlayerLayer = AVPlayerLayer(player: avPlayer!)
            avPlayerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(avPlayerLayer!)
            
            avPlayer?.play()
            videoLoadingStatusIndicator.startAnimating()
            videoPlayButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
         
        avPlayerLayer?.removeFromSuperlayer()
        avPlayer?.pause()
        videoLoadingStatusIndicator.stopAnimating()
    }
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.lightGray
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
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
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        return profileImageView
    }()
    
    
    lazy var  imageMessageView :UIImageView = {
        let imageMessage = UIImageView()
        imageMessage.translatesAutoresizingMaskIntoConstraints = false
        imageMessage.layer.cornerRadius = 16
        imageMessage.layer.masksToBounds = true
        imageMessage.contentMode = .scaleAspectFill
        imageMessage.backgroundColor = UIColor.gray
        imageMessage.isUserInteractionEnabled = true
        imageMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomInImage)))
        
        return imageMessage
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    func handleZoomInImage(tapGesture:UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            
            chatLogController?.handleStaringZoomInImageView(image: imageView)

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bubbleView)
        self.addSubview(textView)
        self.addSubview(chatPartnerProfileImageView)
        
        bubbleView.addSubview(imageMessageView)
        bubbleView.addSubview(videoPlayButton)
        bubbleView.addSubview(videoLoadingStatusIndicator)
        
        videoPlayButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        videoPlayButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        videoPlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoPlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        videoLoadingStatusIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        videoLoadingStatusIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        videoLoadingStatusIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLoadingStatusIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        
        imageMessageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        imageMessageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        imageMessageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        imageMessageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
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
