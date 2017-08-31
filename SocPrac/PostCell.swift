//
//  PostCell.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var deleteBtnLbl: UIButton!
    
    var post: Post!
    var user: User!
    var likesRef: DatabaseReference!
    var postRef: DatabaseReference!
    var userRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
        
    }
    
    
    func configureCell(post: Post, username: String? = nil, img: UIImage? = nil, userProfileImg: UIImage? = nil) {
        self.post = post

        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)

        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        if username != nil {
            self.usernameLbl.text = "\(username!)"
        }
        
        if post.userId == Auth.auth().currentUser?.uid {
            deleteBtnLbl.isHidden = false
        } else {
            deleteBtnLbl.isHidden = true
        }
        
        if userProfileImg != nil {
            self.profileImg.image = userProfileImg
        }
        
        if img != nil {
            self.postImg.image = img
        } else {
//            print("HERE IS THE POST IMAGEURL: \(post.imageUrl)")
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("AllenError: Unable to download image from Firebase storage")
                } else {
                    print("AllenData: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
                
            })
            
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            sender.cancelsTouchesInView = false
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
        
    }
    
//    @IBAction func deleteBtnTapped(_ sender: Any) {
//        
//        let postKey = post.postKey
//        print("HI I AM THE POSTKEY: \(postKey)")
//        
//        deletePost(childToDelete: postKey)
//        
//    }
//    
//    
//    func deletePost(childToDelete: String) {
//        
//        let firebaseRef = Database.database().reference().child(childToDelete)
//        print("HELLO THERE I AM THE POSTKEY: \(firebaseRef)")
//        firebaseRef.removeValue { (error, ref) in
//            if error != nil {
//                print("Here's the error output when I tried to delete: \(error)")
//            } else {
//                print("Looks like we successfully deleted the object. Sad!")
//            }
//        }
//        
//    }
    
}
