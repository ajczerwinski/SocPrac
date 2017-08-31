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

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //TODO - return the let to _ when done testing
    override func viewDidAppear(_ animated: Bool) {
        if let keychainString = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            print("HERE IS THE KEYCHAIN STRING THAT IS CHECKED WHEN PAGE LOADS: \(keychainString)")
            print("AllenData: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFeed" {
            let nextScene = segue.destination as! FeedVC
            
            if let userId = KeychainWrapper.standard.string(forKey: KEY_UID) {
                let currentUserId = userId
                //nextScene.currentUserId = currentUserId
                
            }
            
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
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
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
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        //let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("AllenData: Data saved to keychain \(keychainResult)")

        if userData["username"] == nil {
//            print("Hi the username is: \(userData["username"])")
//            print("Hi the user is: \(userData)")
//            print("\(id)")
            self.performSegue(withIdentifier: "noUsername", sender: nil)
        } else {
            self.performSegue(withIdentifier: "goToFeed", sender: nil)
        }
        
    }
   
}

