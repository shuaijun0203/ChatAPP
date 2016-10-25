//
//  LoginController+handlers.swift
//  Chat
//
//  Created by guest on H28/10/24.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension LoginController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func profileImageViewHandle(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var imageFromPicker:UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            imageFromPicker = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageFromPicker = originalImage
        }
        if let profileImage = imageFromPicker {
            
            profileImageView.image = profileImage

        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func loginHandle(){
        guard let email = inputEmailTextField.text, let password = inputPasswordTextField.text
            else{
                print("please insert the right email or password ")
                return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if user?.uid == nil {
                self.inputEmailTextField.text = ""
                self.inputPasswordTextField.text = ""
                print(error)
                return
            }
            
            self.dismiss(animated:true, completion: nil)
        })
        
    }
    
    func registerHandle(){
        
        guard let email = inputEmailTextField.text, let password = inputPasswordTextField.text,let username = inputNameTextField.text
            else{
                print("please insert the right form ")
                return
        }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil{
                print(error)
                return
            }
            
            guard let uid = user?.uid else{
                return
            }
            
            
            //register a user to Firebase auth and db
            
            let firebaseStorageRef = FIRStorage.storage().reference().child(uid+".png")
            
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                
                firebaseStorageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": username,"email": email,"profileImage":profileImageURL]

                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])

                    }
                    
                    
                    print(metadata)
                    
                })

            }
        })
    }
    
    func registerUserIntoDatabaseWithUID(uid:String,values:[String:AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://chat-a9541.firebaseio.com/")
        
        let userRefs = ref.child("users").child(uid)
        
        userRefs.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err)
                return
            }
            
            self.messageController?.setupUserNaviBarTitle() 
            
            self.dismiss(animated: true, completion: nil)
            
            print(" saved the user successfuly! ")
        })
    }

}
