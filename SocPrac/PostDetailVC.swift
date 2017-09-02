//
//  PostDetailVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 8/24/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase

class PostDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    
    var post: Post?
    var username: String?
    var postImgUrl: String?
    var postingUserImgUrl: String?

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
        
        self.tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToFeed" {
            let nextScene = segue.destination as! FeedVC
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
        
        print("yay it looks like this button is active")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CommentCell()
        return cell
    }
    

}
