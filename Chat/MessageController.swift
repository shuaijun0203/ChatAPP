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
        newMessageImage?.renderingMode
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkUserIsLogin()
    }
    
    func handleNewMessage(){
        
        let newMessageController = NewMessageController()
        
        let newMessageNaviController = UINavigationController(rootViewController: newMessageController)
        
        present(newMessageNaviController, animated: true, completion: nil)

    }
    
    func checkUserIsLogin(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            setupUserNaviBarTitle()
        }
    }
    
    func setupUserNaviBarTitle(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //            print(snapshot)
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                self.navigationItem.title = dictionary["name"] as? String
                //                print(dictionary["name"])
            }
            
            }, withCancel: nil)
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

