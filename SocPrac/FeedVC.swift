//
//  FeedVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var greetingLbl: UILabel!
    @IBOutlet weak var profileBtnLbl: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    
    var posts = [Post]()
    var user: User!
    var selectedPost: Post?
    var currentUsername: String!
    var currentUserEmail: String!
    var currentUserImage: UIImage?
    
    var facebookProfileImgUrl: String?
    var facebookUsername: String?

    var usernameDict: [String: String] = [:]
    var profileImgDict: [String: String] = [:]
    var imagePicker: UIImagePickerController!
    var currentUserProvider: String!
    
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let timestamp = Date().inMilliseconds()
//        print("HERE IS THE TIMESTAMP IN MILLISECONDS:\(timestamp ?? 0))")
        if let currentUserId = Auth.auth().currentUser?.uid {
            
            DataService.ds.REF_USERS.child(currentUserId).observe(.value, with: { (snapshot) in
                
                
                let value = snapshot.value as? NSDictionary
                let userProvider = value?["provider"] as? String ?? ""

                if userProvider == "Firebase" {
                    let username = value?["username"] as? String ?? ""
                    self.currentUsername = username

                    let emailAddress = value?["email"] as? String ?? ""
                    self.currentUserEmail = emailAddress

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
                                        self.profileImg.image = profileImg
                                    }
                                }
                            }
                        })
                    }
                } else if userProvider == "facebook.com" {
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                            
                            if (error == nil) {
                                let fbDetails = result as! NSDictionary
                                if let fbUserId = fbDetails["id"] {
                                    print("This is the FB User ID: \(fbUserId)")
                                    let fbUserProfileImgUrl = "https://graph.facebook.com/" + "\(fbUserId)" + "/picture?type=large&redirect=true&width=500&height=500"
                                        print(fbUserProfileImgUrl)
                                    
                                    if let checkedUrl = URL(string: fbUserProfileImgUrl) {
                                        self.profileImg.contentMode = .scaleAspectFit
                                        self.downloadImage(url: checkedUrl)
                                    }

                                    if let fbUsername = fbDetails["first_name"] {
                                        self.currentUsername = fbUsername as! String
                                        self.greetingLbl.text = "Hello, " + (fbUsername as! String)
                                    }
                                    if let fbEmail = fbDetails["email"] {
                                        self.currentUserEmail = fbEmail as! String
                                    }
                                    }
                                } else {
                                print("Found some kind of error in Facebook: \(String(describing: error?.localizedDescription))")
                                }
                        })
                        
                }
            }
        })
        
        DispatchQueue.global(qos: .userInitiated).async {
            
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
        }
        
        captionField.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToProfile" {
            
            if let profileImg = self.profileImg.image {
                currentUserImage = profileImg
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
                        }
                    }
                }
            }
            let nextScene = segue.destination as! ProfileVC
            nextScene.currentUserUsername = currentUsername
            nextScene.currentUserImage = currentUserImage

        } else if segue.identifier == "goToPostDetailVC" {
            
            if let profileImg = self.profileImg.image {
                currentUserImage = profileImg
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
                        }
                    }
                }
                
            }
            
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
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                                   
                                }
                            }
                        }
                    })
                }
                
            }
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                if postingUserProfileImgUrl != nil {
                    if let postingUserUserProfileImg = FeedVC.imageCache.object(forKey: postingUserProfileImgUrl! as NSString) {
                        
                        cell.configureCell(post: post, username: username!, img: img, userProfileImg: postingUserUserProfileImg)
                        
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
        self.selectedPost = post
        self.performSegue(withIdentifier: "goToPostDetailVC", sender: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            handleAlert(issueType: "actionFailed")
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        
        if let profileImg = self.profileImg.image {
            currentUserImage = profileImg
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
                    }
                }
            }
            
        }
        
        // Check the entered caption text for profanity
        guard let captionWords = captionField.text?.lowercased(), SwearWords.containsSwearWord(text: captionWords, swearWords: SwearWords.hashedSwearWords) == false else {
            print("Looks like there are swear words")
            self.handleAlert(issueType: "swearWords")
            return
        }
        
        guard let caption = captionField.text, caption != "" else {
            handleAlert(issueType: "postFailed")
            print("AllenError: Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            handleAlert(issueType: "postFailed")
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
            let creationDate = String(Date().inMilliseconds())
            let post: Dictionary<String, AnyObject> = [
                "caption": captionField.text! as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject,
                "userId": currentUserId as AnyObject,
                "creationDate": creationDate as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
            
            captionField.text = ""
            imageSelected = false
            imageAdd.image = UIImage(named: "add-image")
            
            tableView.reloadData()
        }
        
    }
    
    func postUsernameAndProfileImgToFirebase(imgUrl: String) {
        
        let user: Dictionary<String, AnyObject> = [
        
            "username": self.currentUsername! as AnyObject,
            "email": self.currentUserEmail! as AnyObject,
            "profileImg": imgUrl as AnyObject
        
        ]
        
        if let currentUserId = Auth.auth().currentUser?.uid {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
            firebasePost.updateChildValues(user)
        } else {
            handleAlert(issueType: "actionFailed")
            print("Somehow couldn't get currentUserId")
        }
        
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        KeychainWrapper.standard.removeObject(forKey: "username")
        print("AllenData: ID removed from keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    func postImageToFirebase(imgUrl: String) {
        
        let user: Dictionary<String, AnyObject> = [
        
            "profileImg": imgUrl as AnyObject
            
        ]
        if let currentUserId = Auth.auth().currentUser?.uid {
            let firebasePost = DataService.ds.REF_USERS.child(currentUserId)
            firebasePost.updateChildValues(user)
        } else {
            handleAlert(issueType: "actionFailed")
            print("Somehow couldn't get currentUserId")
        }
        
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { () -> Void in
                self.profileImg.image = UIImage(data: data)
            }
        }
    }
    
    // TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Handle alerts for various user and non-user errors
    private func handleAlert(issueType: String) {
        var alert = UIAlertController()
        switch issueType {
        case "actionFailed":
            alert = UIAlertController(title: "Action unsuccessful", message: "Something went wrong. Please try again", preferredStyle: .alert)
        case "postFailed":
            alert = UIAlertController(title: "Post unsuccessful", message: "A caption and image is required", preferredStyle: .alert)
        case "swearWords":
            alert = UIAlertController(title: "Inappropriate language", message: "Post caption must not include inappropriate language", preferredStyle: .alert)
        default:
            return
        }
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }
    
}

// Extend Date to return timestamp in milliseconds
extension Date {
    func inMilliseconds() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
