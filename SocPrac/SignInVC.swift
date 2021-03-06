//
//  SignInVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    var frameView: UIView!
    var username = ""
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        emailField.delegate = self
        pwdField.delegate = self
        
    }
    
    // If user is already signed in, take them straight to the Feed
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("AllenData: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFeed" {
            let _ = segue.destination as! FeedVC
            
        }
        
        if segue.identifier == "noUsername" {
            
            let nextScene = segue.destination as! ProfileVC
            
            if let userId = KeychainWrapper.standard.string(forKey: KEY_UID) {
                let currentUserId = userId
                nextScene.currentUserId = currentUserId
            }
        }
    }
    
    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if error != nil {
                print("AllenError: Unable to authenticate with Facebook - \(error!)")
            } else if result?.isCancelled == true {
                self.handleAlert(issueType: "loginError")
                print("AllenError: User cancelled Facebook authentication")
            } else {
                print("AllenData: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                self.handleAlert(issueType: "loginError")
                print("AllenError: Unable to authenticate with Firebase - \(error!)")
            } else {
                print("AllenData: Successfully authenticated with Firebase")
                if let user = user {
                    let creationDate = String(Date().inMilliseconds())
                    let userData = ["provider": credential.provider, "creationDate": creationDate]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    // Authenticate returning user (already has account)
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let pwd = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("AllenData: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    self.handleAlert(issueType: "invalidCred")
                    print("Invalid username and password!")

                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let _ = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        self.performSegue(withIdentifier: "goToFeed", sender: nil)
        
        
    }
    
    // TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    
    // Turn on observers to listen for keyboard show and hide functions
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
     // Turn off observers
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if view.frame.origin.y != 0 {
            return
        } else {
            if emailField.isFirstResponder {
                view.frame.origin.y += getKeyboardHeight(notification: notification) * -1
            }
            
            if pwdField.isFirstResponder {
                view.frame.origin.y += getKeyboardHeight(notification: notification) * -1
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if emailField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        if pwdField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
        
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Handle alerts for various user and non-user errors
    private func handleAlert(issueType: String) {
        var alert = UIAlertController()
        switch issueType {
        case "loginError":
            alert = UIAlertController(title: "Failed to log in", message: "Something went wrong on login. Please try again", preferredStyle: .alert)
        case "invalidCred":
            alert = UIAlertController(title: "Failed to log in", message: "Invalid username or password", preferredStyle: .alert)
        default:
            return
        }
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    
}

