//
//  PostDetailVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 8/24/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase

class PostDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var nonValidatedUserCaption: UILabel!
    @IBOutlet weak var validatedUserCaption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var deleteBtnLbl: UIButton!
    @IBOutlet weak var editImgBtnLbl: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextField: FancyField!
    
    var post: Post?
    var username: String?
    var postImgUrl: String?
    var postingUserImgUrl: String?
    
    var usernameDict: [String: String] = [:]
    var profileImgDict: [String: String] = [:]
    
    var comments = [Comment]()
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    var frameView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser?.uid == post?.userId {
            deleteBtnLbl.isHidden = false
            validatedUserCaption.isHidden = false
            nonValidatedUserCaption.isHidden = true
            editImgBtnLbl.isHidden = false
        } else {
            deleteBtnLbl.isHidden = true
            validatedUserCaption.isHidden = true
            nonValidatedUserCaption.isHidden = false
            editImgBtnLbl.isHidden = true
            
        }
        
        validatedUserCaption.text = post?.caption
        nonValidatedUserCaption.text = post?.caption
        usernameLbl.text = username
        if let numberOfLikes = post?.likes {
            likesLbl.text = "\(numberOfLikes)"
        }
        
        // Create Firebase Database reference to check if post is liked by user
        let likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child((post?.postKey)!)
        
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
        // Create Firebase Database reference to grab usernames and profileUrls
        // from users who left comments and store in dictionary
        // TODO add search query terms to limit the number of users that this 
        // reference observes (shouldn't be all users)
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshot {
                    print("HERE IS THE USER SNAPSHOT: \(snap)")
                    
                    if let commentUserDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        var commentingUsername = ""
                        var commentingUserProfileImg: String?
                        
                        if let username = commentUserDict["username"] as? String {
                            commentingUsername = username
                        }
                        
                        if let profileImg = commentUserDict["profileImg"] as? String {
                            commentingUserProfileImg = profileImg
                        }
                        
                        self.usernameDict[key] = commentingUsername
                        self.profileImgDict[key] = commentingUserProfileImg
                        
                    }
                    
                    
                }
                
            }
            
            print("HERE IS THE FULL USERNAME DICTIONARY \(self.usernameDict)")
            print("HERE IS THE FULL PROFILEIMG DICTIONARY: \(self.profileImgDict)")
            self.tableView.reloadData()
            
        })
        
        
        
        // Create Firebase Storage reference to display Post Image
        if let postImageUrl = postImgUrl {
            let postImgRef = Storage.storage().reference(forURL: postImageUrl)
            postImgRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("AllenError: Unable to download postImage from Firebase storage")
                } else {
                    print("AllenData: postImage successfully downloaded from Firebase storage")
                    if let postImgData = data {
                        if let postImage = UIImage(data: postImgData) {
                            self.postImg.image = postImage
                        }
                    }
                }
            })
            print("HI I AM THE POST IMAGE URL: \(postImageUrl)")
        }
        
        
        // Create Firebase Storage reference to display User Profile Image
        if let profileImageUrl = postingUserImgUrl {
            let profileImageRef = Storage.storage().reference(forURL: profileImageUrl)
            profileImageRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("AllenError: Unable to download userProfileImage from Firebase storage")
                } else {
                    print("AllenData: userProfileImage successfully downloaded from Firebase storage")
                    if let profileImageData = data {
                        if let profileImage = UIImage(data: profileImageData) {
                            self.profileImg.image = profileImage
                        }
                    }
                }
            })
            print("HI I AM THE POST IMAGE URL: \(profileImageUrl)")
        }
        
        // Observe snapshot of Comments Firebase object to populate comments array
    
    
        DataService.ds.REF_POSTS.child((post?.postKey)!).child("comments").observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.comments = [] // clear out comments array to avoid double posting
                for snap in snapshot {
                    print("HI I AM THE COMMENT SNAPSHOT: \(snap)")
                    if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let comment = Comment(commentKey: key, commentData: commentDict)
                        self.comments.append(comment)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //tableView.reloadData()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImg.image = image
            imageSelected = true
        } else {
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToFeed" {
            
            let nextScene = segue.destination as! FeedVC
        }
    }
    
    func postToFirebase(imgUrl: String) {
    
        let userPost: Dictionary<String, AnyObject> = [
            
            "imageUrl": imgUrl as AnyObject,
            "caption": validatedUserCaption.text! as AnyObject
            
        ]
        
        let postId = post?.postKey
        
            
        let firebasePost = DataService.ds.REF_POSTS.child(postId!)
        firebasePost.updateChildValues(userPost)
        
    }
    
    func postCommentToFirebase() {
    
        let userComment: Dictionary<String, AnyObject> = [
            
            "userId": Auth.auth().currentUser?.uid as AnyObject,
            "commentText": commentTextField.text! as AnyObject
            
        ]
        
        let firebaseCommentPost = DataService.ds.REF_POSTS.child((post?.postKey)!).child("comments").childByAutoId()
        
        firebaseCommentPost.setValue(userComment)
        
        commentTextField.text = ""
        commentTextField.resignFirstResponder()
        
        //tableView.reloadData()
    
    }
    
    @IBAction func backOrSaveBtnPressed(_ sender: Any) {
        
        if imageSelected == true {
            
            guard let img = postImg.image else {
                print("AllenError: Post image wasn't selected")
                return
            }
            
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                
                let imgUid = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                DataService.ds.REF_USER_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("AllenError: Unable to upload image to Firebase storage")
                    } else {
                        print("AllenData: Successfully uploaded image to Firebase storage")
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        
                        if let url = downloadURL {
                            self.postToFirebase(imgUrl: url)
                        }
                        self.performSegue(withIdentifier: "detailToFeed", sender: nil)
                    }
                    
                }
                
            }
            
        } else {
            
            self.postToFirebase(imgUrl: (post?.imageUrl)!)
            
            self.performSegue(withIdentifier: "detailToFeed", sender: nil)
            
        }
        
    }
    
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        
        if let postKey = post?.postKey {
            print("HI I AM THE POSTKEY: \(postKey)")
                deletePost(childToDelete: postKey)
        }

    }


    func deletePost(childToDelete: String) {

        let firebaseRef = Database.database().reference().child("posts").child(childToDelete)
        
        print("HELLO THERE I AM THE POSTKEY: \(firebaseRef)")
        firebaseRef.removeValue { (error, ref) in
            if error != nil {
                print("Here's the error output when I tried to delete: \(error)")
            } else {
                print("Looks like we successfully deleted the object: \(firebaseRef). Sad!")
            }
            
        }
        
        performSegue(withIdentifier: "detailToFeed", sender: nil)
        
    }
    
    @IBAction func editImgBtnPressed(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var commenterUsername: String?
        var commenterUserProfileImgUrl: String?
        
        if self.comments.count > 0 {
            let comment = self.comments[indexPath.row]
            let userId = comment.userId
            
            if let commentingUsername = usernameDict[userId] {
                commenterUsername = commentingUsername
            }
            if let commentingProfileImgUrl = profileImgDict[userId] {
                commenterUserProfileImgUrl = commentingProfileImgUrl
            }
            
            print("Here is the commenter's username: \(commenterUsername!)")
            print("Here is the commenter's profileImgUrl: \(commenterUserProfileImgUrl!)")
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
                
                cell.configureCell(comment: comment, commenterUsername: commenterUsername!, commenterUserProfileImgUrl: commenterUserProfileImgUrl!)
                
                return cell
                
            } else {
                return CommentCell()
            }
            
        } else {
            return CommentCell()
        }
        
    }
    @IBAction func postCommentBtnPressed(_ sender: Any) {
        
        guard let commentText = commentTextField.text, commentText != "" else {
            
            // TODO - Will want to add an error notification or something here if invalid data is entered
            print("AllenError: Comment text must be entered")
            return
        }
        
        postCommentToFirebase()
        
        
        
    }
    
    // TextField delegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        commentTextField.text = ""
        
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
        
        if commentTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification: notification) * -1
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if commentTextField.isFirstResponder {
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
