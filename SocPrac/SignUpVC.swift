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

class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToSignIn", sender: nil)
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text {
            
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
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        //        var keychainUsername: String? = nil
        print("Here is the id: \(id)")
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        
        print("AllenData: Data saved to keychain \(keychainResult)")
        
        self.performSegue(withIdentifier: "signUpToProfile", sender: nil)
        
        
    }
    

}
