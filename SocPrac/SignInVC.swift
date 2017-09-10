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
        
        
    }
    
    
    //TODO - return the let to _ when done testing
    override func viewDidAppear(_ animated: Bool) {
        if let keychainString = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("AllenData: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFeed" {
            //let _ = KeychainWrapper.standard.set(username, forKey: "username")
            let nextScene = segue.destination as! FeedVC
//            nextScene.currentUsername = username
            
            
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
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("AllenError: Unable to authenticate with Facebook - \(error!)")
            } else if result?.isCancelled == true {
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
                print("AllenError: Unable to authenticate with Firebase - \(error!)")
            } else {
                print("AllenData: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
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
                    
                    print("Invalid username and password!")
//                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
//                        if error != nil {
//                            print("AllenError: Unable to authenticate with Firebase using email")
//                        } else {
//                            print("AllenData: Successfully authenticated with Firebase")
//                            if let user = user {
//                                let userData = ["provider": user.providerID]
//                                self.completeSignIn(id: user.uid, userData: userData)
//                            }
//                        }
//                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
//        var keychainUsername: String? = nil
        print("Here is the id: \(id)")
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        
        print("AllenData: Data saved to keychain \(keychainResult)")
        
        self.performSegue(withIdentifier: "goToFeed", sender: nil)
        
        
    }
    
//        DataService.ds.REF_USERS.child(id).observe(.value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? String ?? ""
//            keychainUsername = username
//            print("HERE IS THE KEYCHAIN USERNAME: \(keychainUsername)")
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                
//                for snap in snapshot {
//                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
//                        
//                        let key = snap.key
//                        let user = User(userKey: key, userData: userDict)
//                        print("We have a user: \(user)")
//                        keychainUsername = user.username
////                        var keychainUsernamePlaceholder = ""
////                        if let username = userDict["username"] as? String {
////                            keychainUsernamePlaceholder = username
////                        }
//                        
//                    }
//                }
//                
//                
//                
////                for snap in snapshot {
////                    print("OH SNAP: \(snap)")
////                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
////                        
////                        let key = snap.key
////                        let user = User(userKey: key, userData: userDict)
////                        print(user)
////                        if let username = snap.value(forKey: "username") {
////                            keychainUsername = username as! String
////                        }
//////                        if let username = userDict["username"] {
//////                            keychainUsername = username as! String
//////                        }
////                        
////                    }
////                    
////                }
//                
//                //keychainUsername = snapshot["username"]
//                
////            }
//        })
        
        
        
//        if keychainUsername! == nil {
//            
//            self.performSegue(withIdentifier: "noUsername", sender: nil)
//        } else {
////            print("HERE IS KEYCHAIN USERNAME: \(keychainUsername)")
////            _ = KeychainWrapper.standard.set(keychainUsername!, forKey: "username")
//            self.performSegue(withIdentifier: "goToFeed", sender: nil)
//        }
        
//    }
    
    // TextField delegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        emailField.text = ""
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    
    // Turn on observers to listen for keyboard
    // show and hide functions
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillShow:"), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillHide:"), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
     // Turn off observers
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if emailField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification: notification) * -1
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if emailField.isFirstResponder {
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
    
   
}

