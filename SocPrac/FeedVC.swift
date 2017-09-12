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
    @IBOutlet weak var greetingLbl: UILabel!
    
    var posts = [Post]()
    var user: User!
    var selectedPost: Post?
    var currentUsername: String!
    var currentUserImage: UIImage?

    var usernameDict: [String: String] = [:]
    var profileImgDict: [String: String] = [:]
    var imagePicker: UIImagePickerController!
    //var currentUserId: String!
    var currentUserProvider: String!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("HI I'M THE CURRENT USERNAME: \(currentUsername)")
        if let currentUserId = Auth.auth().currentUser?.uid {
            print("HERE IS THE CURRENT USER ID \(currentUserId)")
            
            DataService.ds.REF_USERS.child(currentUserId).observe(.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                //keychainUsername = username
                self.currentUsername = username
                print("HERE IS THE KEYCHAIN USERNAME: \(username)")
                self.greetingLbl.text = "Hello, " + username
                let userProfileImgUrl = value?["profileImg"] as? String ?? ""
                if userProfileImgUrl != "" {
                    let ref = Storage.storage().reference(forURL: userProfileImgUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("AllenError: Unable to download userProfileImage from Firebase storage")
                        } else {
                            print("AllenData: userProfileImage successfully downloaded from Firebase storage")
                            if let imgData = data {
                                if let profileImg = UIImage(data: imgData) {
                                    FeedVC.imageCache.setObject(profileImg, forKey: userProfileImgUrl as NSString)
                                    self.currentUserImage = profileImg
                                }
                            }
                        }
                    })
                }
            })
        }
        let delayInSeconds = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
                
                self.posts = [] // THIS IS THE NEW LINE
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        
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
                        
                        if let userDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            var postingUsername = ""
                            var postingUserProfileImg: String?
                            if let username = userDict["username"] as? String {
                                postingUsername = username
                            }
                            
                            if let profileImg = userDict["profileImg"] as? String {
                                postingUserProfileImg = profileImg
                            }
                            
                            self.usernameDict[key] = postingUsername
                            self.profileImgDict[key] = postingUserProfileImg
                            
                        }
                    }
                }
                
                self.tableView.reloadData()
            })
        }

        
        
        
        //greetingLbl.text = "Hello, " + KeychainWrapper.standard.string(forKey: "username")!

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToProfile" {
            let nextScene = segue.destination as! ProfileVC
            nextScene.currentUserUsername = currentUsername
            nextScene.currentUserImage = currentUserImage
            print("HEY WE USED THE FEED TO PROFILE SEGUE")
        } else if segue.identifier == "goToPostDetailVC" {
            let nextScene = segue.destination as! PostDetailVC
            nextScene.post = selectedPost
            
            if let username = usernameDict[(selectedPost?.userId)!] {
                nextScene.username = username
            }
            
            if let postImgUrl = selectedPost?.imageUrl {
                nextScene.postImgUrl = postImgUrl
            }
            
            if let postingUserImgUrl = profileImgDict[(selectedPost?.userId)!] {
                nextScene.postingUserImgUrl = postingUserImgUrl
            }
            
            print("HEY WE ARE PREPARING FOR POSTDETAILVC SEGUE")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var postingUserProfileImg: UIImage?
        var postingUserProfileImgUrl: String?
        
        let post = posts[indexPath.row]
        let postingUserId = post.userId
        let username = usernameDict[postingUserId]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let userProfileImgUrl = profileImgDict[postingUserId] {
                postingUserProfileImgUrl = userProfileImgUrl

                if postingUserProfileImgUrl! != "" {
                    let ref = Storage.storage().reference(forURL: postingUserProfileImgUrl!)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("AllenError: Unable to download userProfileImage from Firebase storage")
                        } else {
                            print("AllenData: userProfileImage successfully downloaded from Firebase storage")
                            if let imgData = data {
                                if let profileImg = UIImage(data: imgData) {
                                    FeedVC.imageCache.setObject(profileImg, forKey: postingUserProfileImgUrl! as NSString)
                                    postingUserProfileImg = profileImg
//                                    print("HEY I FOUND THE POSTINGUSERPROFILEIMG IT IS HERE: \(postingUserProfileImg!)")
                                }
                            }
                        }
                    })
                }
                
            }
            
            // TODO - look at postingUserProfileImgUrl section here to figure out why it was crashing after first creating a username after new user creation
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                if postingUserProfileImgUrl != nil {
                    if let postingUserUserProfileImg = FeedVC.imageCache.object(forKey: postingUserProfileImgUrl! as NSString) {
                        
                        cell.configureCell(post: post, username: username!, img: img, userProfileImg: postingUserUserProfileImg)
                        //tableView.reloadData()
                        
                    }
                }
        
                
            } else {
                if let userProfileUrl = postingUserProfileImgUrl {
                    let userProfileImgRef = Storage.storage().reference(forURL: userProfileUrl)
                    userProfileImgRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            
                            print("AllenError: Unable to download userProfileImage from Firebase storage")
                            
                        } else {
                            print("AllenData: userProfileImage successfully downloaded from Firebase storage")
                            if let userProfileImgData = data {
                                if let userProfileImg = UIImage(data: userProfileImgData) {
                                    cell.configureCell(post: post, username: username, userProfileImg: userProfileImg)
                                }
                            }
                        }
                    })
                }
                cell.configureCell(post: post, username: username)
            }
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = self.posts[indexPath.row]
        print("HI I AM THE POST: \(post)")
        self.selectedPost = post
        print(selectedPost)
        self.performSegue(withIdentifier: "goToPostDetailVC", sender: nil)
        
        
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
        if let currentUserId = Auth.auth().currentUser?.uid {
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
        KeychainWrapper.standard.removeObject(forKey: "username")
        print("AllenData: ID removed from keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    
}

