//
//  LoginController.swift
//  Chat
//
//  Created by guest on H28/10/18.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {
    
    let inputsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(r: 100, g: 81, b: 81)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(registerHandle), for: .touchUpInside)
        
        return button
    }()

    func registerHandle(){
        
        guard let email = inputEmailTextField.text, let password = inputPasswordTextField.text,let username = inputNameTextField.text
            else{
                print("please insert the right email ")
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
            
            let ref = FIRDatabase.database().reference(fromURL: "https://chat-a9541.firebaseio.com/")
            
            let userRefs = ref.child("users").child(uid)

            let values = ["name": username,"email": email]
            
            userRefs.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err)
                    return
                }
                
                print(" saved the user successfuly! ")
            })
            

//            userRefs.updateChildValues(userInfo)
        })
    }
    
    let inputNameTextField:UITextField = {
        
        let textField = UITextField()
        textField.placeholder = " Name "
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let nameSeperater: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let inputEmailTextField:UITextField = {
        
        let textField = UITextField()
        textField.placeholder = " Email "
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let emailSeperater: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let inputPasswordTextField:UITextField = {
        
        let textField = UITextField()
        textField.placeholder = " Password "
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        
        return textField
    }()

    let profileImageView :UIImageView = {
        let imageView  = UIImageView()
        imageView.image = UIImage(named: "jesus")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    lazy var registerSegmentedController :UISegmentedControl = {
        let segmentController = UISegmentedControl(items: [ " Login "," Register "])
        segmentController.translatesAutoresizingMaskIntoConstraints = false
        segmentController.tintColor = UIColor.white
        segmentController.selectedSegmentIndex = 1
        segmentController.addTarget(self, action: #selector(loginRegisterHeightContrlloer), for: .valueChanged)
        return segmentController
    }()
    
    func loginRegisterHeightContrlloer(){
        let loginRegisterTitle = registerSegmentedController.titleForSegment(at: registerSegmentedController.selectedSegmentIndex)
        loginRegisterButton.setTitle(loginRegisterTitle, for: .normal)
        
        inputContainerHeightAnchor?.constant = registerSegmentedController.selectedSegmentIndex == 0 ? 100 : 150
        
        
//        nameInputTextHeightAnchor?.isActive  = false
//        
//        nameInputTextHeightAnchor? = inputNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: registerSegmentedController.selectedSegmentIndex == 0 ? 0 : 1/3)
//        
//        nameInputTextHeightAnchor?.isActive  = true
    }
    
    
    var inputContainerHeightAnchor : NSLayoutConstraint?
    var nameInputTextHeightAnchor : NSLayoutConstraint?
    var emailInputTextHeightAnchor : NSLayoutConstraint?
    var passwordInputTextHeightAnchor : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(r: 181, g: 181, b: 181)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(registerSegmentedController)
        
        
        setInputsContainerView()
        setLoginRegisterButton()
        setProfileImageView()
        setupRegisterSegmentedController()

        //need x , y , width , height contraints
        inputNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        inputNameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        inputNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameInputTextHeightAnchor = inputNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameInputTextHeightAnchor?.isActive = true
    
        
        //need x , y , width , height contraints
        nameSeperater.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperater.topAnchor.constraint(equalTo: inputNameTextField.bottomAnchor).isActive = true
        nameSeperater.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperater.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x , y , width , height contraints
        inputEmailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        inputEmailTextField.topAnchor.constraint(equalTo: inputNameTextField.bottomAnchor).isActive = true
        inputEmailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        inputEmailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //need x , y , width , height contraints
        emailSeperater.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperater.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor).isActive = true
        emailSeperater.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperater.heightAnchor.constraint(equalToConstant: 1).isActive = true

        //need x , y , width , height contraints
        inputPasswordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        inputPasswordTextField.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor).isActive = true
        inputPasswordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        inputPasswordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true

        
    }
    
    func setupRegisterSegmentedController(){
        //need x , y , width , height contraints
        registerSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerSegmentedController.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        registerSegmentedController.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 0.5).isActive = true
        registerSegmentedController.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    func setProfileImageView(){
        //need x , y , width , height contraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor ).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: registerSegmentedController.topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }


    func setInputsContainerView(){
        
        //need x , y , width , height contraints
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(inputNameTextField)
        inputsContainerView.addSubview(nameSeperater)
        inputsContainerView.addSubview(inputEmailTextField)
        inputsContainerView.addSubview(emailSeperater)
        inputsContainerView.addSubview(inputPasswordTextField)

    }
    
    func setLoginRegisterButton(){
        //need x , y , width , height contraints
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat,b: CGFloat){
        
        self.init(red: r/255,green: g/255,blue: b/255,alpha:1);
        
    }
}
