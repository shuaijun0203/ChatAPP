//
//  ViewController.swift
//  Chat
//
//  Created by guest on H28/10/18.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageImage = UIImage(named: "newMessage")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkUserIsLogin()
        
        obsereAddMessage()
    }
    
    var messages = [Message]()
    
    func obsereAddMessage(){
        
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        if let message = message.message {
            cell.textLabel?.text = message
        }
        
        if let fromId = message.fromId {
            cell.detailTextLabel?.text = fromId
        }
        
        return cell
    }
    
    func handleNewMessage(){
        
        let newMessageController = NewMessageController()
        
        newMessageController.messageController = self
        
        let newMessageNaviController = UINavigationController(rootViewController: newMessageController)
        
        present(newMessageNaviController, animated: true, completion: nil)

    }
    
    func checkUserIsLogin(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            //setupUserNaviBarTitle()
            fetchUserAndsetupNaviItemTitleBar()
        }
    }
    
    func fetchUserAndsetupNaviItemTitleBar(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            print("uid is nil")
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let user = User()
                user.setValuesForKeys(dictionary)
                
                self.setupUserNaviBarTitle(user: user)
                
            }
            
            }) { (error) in
                print(error)
                
        }
    }
    
    func setupUserNaviBarTitle(user:User){
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let nameLable = UILabel()
        containerView.addSubview(nameLable)
        
        nameLable.text = user.name
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        
        //need x,y,width,height anchor
        
        nameLable.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameLable.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLable.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameLable.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createChatLogController)))
        
        
    }
    
    func createChatLogControllerForUser(user:User){
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    func handleLogout(){
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        
        present(loginController, animated: true, completion: nil)
        
    }
    
    
    
}

