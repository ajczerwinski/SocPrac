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

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileUsernameText: FancyField!
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
        
        currentUserId = Auth.auth().currentUser?.uid
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if currentUserId != nil {
            
            print("I'M IN THE PROFILEVC AND HERE IS THE CURRENT USER ID \(currentUserId!)")
        }
        print("HERE IS THE CURRENT USERUSERNAME: \(currentUserUsername)")
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
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageAdd.image = image
            imageSelected = true
        } else {
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFeed", sender: nil)
    
    }
    
    @IBAction func noUsernameBackBtn(_ sender: Any) {
        // TODO - make this an alert
        print("Hey, you need to enter a username and profile photo")
    }
    
    
    @IBAction func profileSaveBtnPressed(_ sender: Any) {
        
        if imageSelected == true {
            guard let profileUsername = profileUsernameText.text, profileUsername != "" else {
                // TODO - Will want to add an error notification or something here if invalid data is entered
                print("AllenError: Profile username must be entered")
                return
            }
            
            guard let profileImg = profileImageAdd.image else {
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
                // TODO - Will want to add an error notification or something here if invalid data is entered
                print("AllenError: Profile username must be entered")
                return
            }
            
            self.postUsernameToFirebase()
            self.performSegue(withIdentifier: "backToFeed", sender: nil)
            
        } else {
            print("AllenError: Must select an image")
        }
//        guard let profileUsername = profileUsernameText.text, profileUsername != "" else {
//            // TODO - Will want to add an error notification or something here if invalid data is entered
//            print("AllenError: Profile username must be entered")
//            return
//        }
//        
//        guard let profileImg = profileImageAdd.image, imageSelected == true else {
//            print("AllenError: Must select an image")
//            return
//        }
//        
//        guard let profileImgExists = currentUserImage else {
//            print("AllenError: Must select an image")
//            return
//        }
        
        
        
        
    }
    
    func postUsernameToFirebase() {
        
        let user: Dictionary<String, AnyObject> = [

            "username": profileUsernameText.text! as AnyObject

        ]
        
        if currentUserId != nil {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
            _ = KeychainWrapper.standard.set(user["username"] as! String, forKey: "username")
            
            
            firebasePost.updateChildValues(user)
        } else {
            print("OOPS, LOOKS LIKE WE COULDN'T GET THE FIREBASE POST")
        }
        
    }
    
    func postUsernameAndProfileImgToFirebase(imgUrl: String) {
        let user: Dictionary<String, AnyObject> = [
            "username": profileUsernameText.text! as AnyObject,
            "profileImg": imgUrl as AnyObject
        ]

//        print("HEY HERE SDFJPWOIEJFPOWIEJFPOWIJEFPOIJEWF)*@)(@#()(@#)(@()#()()#)(()@#)()(@()#()@#:\(user)")
        if currentUserId != nil {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
//            print("HEY HERE SDFJPWOIEJFPOWIEJFPOWIJEFPOIJEWF)*@)(@#()(@#)(@()#()()#)(()@#)()(@()#()@#:\(firebasePost)")
            _ = KeychainWrapper.standard.set(user["username"] as! String, forKey: "username")

            
            firebasePost.updateChildValues(user)
        } else {
            print("OOPS, LOOKS LIKE WE COULDN'T GET THE FIREBASE POST")
        }
        
       imageSelected = false
        
        
        
        
        
        
        
        
        
        //firebasePost.updateChildValues(user)
        
        
        
        
        //profileUsernameText.text = ""
        
        //profileImageAdd.image = UIImage(named: "profile-image")
        
        //tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToFeed" {
            
            let nextScene = segue.destination as! FeedVC
            
            if let userId = currentUserId {
                let currentUserId = userId
                //nextScene.currentUserId = currentUserId
                
            }
        }
    }
    
    @IBAction func addProfileImageTapped(_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }

}
