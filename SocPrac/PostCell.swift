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
    
    var post: Post!
    var user: User!
    var likesRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, /*user: User, */img: UIImage? = nil, profileImg: UIImage? = nil) {
        self.post = post
        //self.user = user
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        //self.usernameLbl.text = user.username
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        if img != nil {
            self.postImg.image = img
        } else {
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
        
        /*if profileImg != nil {
            self.profileImg.image = profileImg
        } else {
            let ref = Storage.storage().reference(forURL: user.profileImg)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("AllenError: Unable to download image from Firebase storage")
                } else {
                    print("AllenData: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let profileImg = UIImage(data: imgData) {
                            self.profileImg.image = profileImg
                            FeedVC.imageCache.setObject(profileImg, forKey: self.user.profileImg as NSString)
                        }
                    }
                }
                
            })
            
        }
        */
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
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
    
}
