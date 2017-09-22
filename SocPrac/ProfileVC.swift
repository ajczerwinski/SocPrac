//
//  ProfileVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MessageUI

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profileUsernameText: UITextField!
    @IBOutlet weak var profileImageAdd: CircleView!
    @IBOutlet weak var backBtnLbl: UIButton!
    @IBOutlet weak var noUsernameBackBtnLbl: UIButton!
    
    var imagePicker: UIImagePickerController!
 
    var imageSelected = false
    var currentUserId: String!
    var currentUserUsername: String?
    var currentUserImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get signed-in userId, display/hide UI accordingly
        currentUserId = Auth.auth().currentUser?.uid
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if currentUserUsername == nil {
            backBtnLbl.isHidden = true
            noUsernameBackBtnLbl.isHidden = false
        } else {
            profileUsernameText.text = currentUserUsername!
            backBtnLbl.isHidden = false
            noUsernameBackBtnLbl.isHidden = true
        }
        
        if currentUserImage != nil {
            profileImageAdd.image = currentUserImage
        }
        
        profileUsernameText.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageAdd.image = image
            imageSelected = true
        } else {
            handleAlert(issueType: "actionFailed")
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFeed", sender: nil)
    
    }
    
    // Mechanism for user to contact support
    @IBAction func supportBtnPressed(_ sender: Any) {
        
        self.sendEmail()
        
    }
    
    @IBAction func noUsernameBackBtn(_ sender: Any) {
        handleAlert(issueType: "missingFields")
        print("AllenError: Need to enter a username and profile photo")
    }
    
    
    @IBAction func profileSaveBtnPressed(_ sender: Any) {
        
        // Check to make sure profile username is between 4 and 15 characters
        guard let profileUsernameCount = profileUsernameText.text?.characters.count, profileUsernameCount > 3, profileUsernameCount <= 15 else {
            handleAlert(issueType: "wrongLength")
            print("AllenError: Username incorrect length")
            return
        }
        
        // Check the entered caption text for profanity
        guard let profileWords = profileUsernameText.text?.lowercased(), SwearWords.containsSwearWord(text: profileWords, swearWords: SwearWords.hashedSwearWords) == false else {
            print("Looks like there are swear words")
            self.handleAlert(issueType: "swearWords")
            return
        }
        
        if imageSelected == true {
            guard let profileUsername = profileUsernameText.text, profileUsername != "" else {
                handleAlert(issueType: "missingFields")
                print("AllenError: Profile username must be entered")
                return
            }
            
            guard let profileImg = profileImageAdd.image else {
                handleAlert(issueType: "missingFields")
                print("AllenError: Must select an image")
                return
            }
            
            if let imgData = UIImageJPEGRepresentation(profileImg, 0.2) {
                
                let imgUid = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let profileMetadata = StorageMetadata()
                profileMetadata.contentType = "image/jpeg"
                
                DataService.ds.REF_USER_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("AllenError: Unable to upload image to Firebase storage")
                    } else {
                        print("AllenData: Successfully uploaded image to Firebase storage")
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        
                        if let url = downloadURL {
                            self.postUsernameAndProfileImgToFirebase(imgUrl: url)
                        }
                        self.performSegue(withIdentifier: "backToFeed", sender: nil)
                    }
                }
                
            }
            
        } else if currentUserImage != nil {
            guard let profileUsername = profileUsernameText.text, profileUsername != "" else {
                handleAlert(issueType: "missingFields")
                print("AllenError: Profile username must be entered")
                return
            }
            
            self.postUsernameToFirebase()
            self.performSegue(withIdentifier: "backToFeed", sender: nil)
            
        } else {
            handleAlert(issueType: "missingFields")
            print("AllenError: Must select an image")
        }
        
        
    }
    
    // Helper function that allows user to only update username (without changing profile pic)
    // and save to Firebase
    func postUsernameToFirebase() {
        
        let user: Dictionary<String, AnyObject> = [

            "username": profileUsernameText.text! as AnyObject

        ]
        
        if currentUserId != nil {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
            _ = KeychainWrapper.standard.set(user["username"] as! String, forKey: "username")
            
            
            firebasePost.updateChildValues(user)
        } else {
            handleAlert(issueType: "actionFailed")
        }
        
    }
    
    // Helper function that updates username and profile image and saves to Firebsae
    func postUsernameAndProfileImgToFirebase(imgUrl: String) {
        let user: Dictionary<String, AnyObject> = [
            "username": profileUsernameText.text! as AnyObject,
            "profileImg": imgUrl as AnyObject
        ]

        if currentUserId != nil {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
            _ = KeychainWrapper.standard.set(user["username"] as! String, forKey: "username")

            firebasePost.updateChildValues(user)
        } else {
            handleAlert(issueType: "actionFailed")
        }
        
       imageSelected = false

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToFeed" {
            
            _ = segue.destination as! FeedVC
            
            if let userId = currentUserId {
                _ = userId
                
            }
        }
    }
    
    @IBAction func addProfileImageTapped(_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // Only allow alphanumeric characters in Username field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let set = CharacterSet(charactersIn: "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789").inverted
        return string.rangeOfCharacter(from: set) == nil
        
    }
    
    // TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["socpracios@gmail.com"])
            mail.setSubject("Reporting issue in SocPrac App")
            mail.setMessageBody("<p>Please enter details about the issue here</p>", isHTML: true)
            
            present(mail, animated: true)
            
        } else {
            handleAlert(issueType: "actionFailed")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // Handle alerts for various user and non-user errors
    private func handleAlert(issueType: String) {
        var alert = UIAlertController()
        switch issueType {
        case "actionFailed":
            alert = UIAlertController(title: "Action unsuccessful", message: "Something went wrong. Please try again", preferredStyle: .alert)
        case "missingFields":
            alert = UIAlertController(title: "Must have username and profile image", message: "Please enter a username and add profile image", preferredStyle: .alert)
        case "wrongLength":
            alert = UIAlertController(title: "Username incorrect length", message: "Username must be between 4 and 15 characters in length", preferredStyle: .alert)
        case "swearWords":
            alert = UIAlertController(title: "Inappropriate language", message: "Username must not include inappropriate language", preferredStyle: .alert)
        default:
            return
        }
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    
}
