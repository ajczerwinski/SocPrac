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
            
            if isValidEmail(testStr: email) == false {
                handleInvalidEmailAddress()
                return
            }
            
            if (pwdField.text?.characters.count)! < 6 {
                handlePasswordTooShort()
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                    if error != nil {
                    self.handleSomethingWentWrong()
                    print("AllenError: Unable to authenticate with Firebase using email")
                } else {
                    print("AllenData: Successfully authenticated with Firebase")
                    if let user = user {
                        
                        let userData = [
                            "provider": user.providerID,
                            "email": email
                        ]
                        
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
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 50
        let currentString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength
    }
    
    func isValidEmail(testStr: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func handleSomethingWentWrong() {
        let alert = UIAlertController(title: "Action unsuccessful", message: "Something went wrong. Please try again", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    
    private func handleInvalidEmailAddress() {
        let alert = UIAlertController(title: "Invalid email address", message: "Please use a valid email address", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    
    private func handlePasswordTooShort() {
        let alert = UIAlertController(title: "Password too short", message: "Password must be at least 6 characters", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    

}


