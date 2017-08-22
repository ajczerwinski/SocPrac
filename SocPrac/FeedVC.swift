//
//  FeedVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()

    var usernameDict: [String: String] = [:]
    var imagePicker: UIImagePickerController!
    var currentUserId: String!
    var currentUserProvider: String!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUserId != nil {
            print("HERE IS THE CURRENT USER ID \(currentUserId!)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = [] // THIS IS THE NEW LINE
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        var postingUsername = ""
                        if let username = userDict["username"] as? String {
                            postingUsername = username
                        }
                        
                        self.usernameDict[key] = postingUsername
                        
                    }
                }
            }
            print("HERE IS THE FULL USERNAME DICTIONARY \(self.usernameDict)")
            self.tableView.reloadData()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToProfile" {
            
            let nextScene = segue.destination as! ProfileVC
            
            if let userId = currentUserId {
                let currentUserId = userId
                nextScene.currentUserId = currentUserId
                
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        let postingUserId = post.userId
        let username = usernameDict[postingUserId]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                if username != nil {
                    cell.configureCell(post: post, username: username!, img: img)
                }
                
        
                
            } else {
                
                cell.configureCell(post: post/*, username: username*/)
            }
            return cell
        } else {
            return PostCell()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            // TODO - Will want to add an error notification or something here if invalid data is entered
            print("AllenError: Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            print("AllenError: Must select an image")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let profileMetadata = StorageMetadata()
            profileMetadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("AllenError: Unable to upload image to Firebase storage")
                } else {
                    print("AllenData: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
            
        }
    }
    
    func postToFirebase(imgUrl: String) {
        
        if currentUserId != nil {
            let post: Dictionary<String, AnyObject> = [
                "caption": captionField.text! as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject,
                "userId": currentUserId as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
            
            captionField.text = ""
            imageSelected = false
            imageAdd.image = UIImage(named: "add-image")
            
            tableView.reloadData()
        }
        
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        //let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("AllenData: ID removed from keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    
}

