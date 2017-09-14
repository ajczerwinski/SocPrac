//
//  SignUpVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 9/10/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        pwdField.delegate = self
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToSignIn", sender: nil)
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text {
            
            Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                    if error != nil {
                    self.handleSomethingWentWrong()
                    print("AllenError: Unable to authenticate with Firebase using email")
                } else {
                    print("AllenData: Successfully authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                
                
                }
                
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)

        print("Here is the id: \(id)")
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        
        print("AllenData: Data saved to keychain \(keychainResult)")
        
        self.performSegue(withIdentifier: "signUpToProfile", sender: nil)
        
        
    }
    
    // TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
        
        return true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func handleSomethingWentWrong() {
        let alert = UIAlertController(title: "Action unsuccessful", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    

}
