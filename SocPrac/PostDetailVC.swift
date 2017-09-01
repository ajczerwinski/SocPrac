//
//  PostDetailVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 8/24/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase

class PostDetailVC: UIViewController {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var deleteBtnLbl: UIButton!
    
    var post: Post?
    var username: String?
    var postImgUrl: String?
    var postingUserImgUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        caption.text = post?.caption
        usernameLbl.text = username
        if let numberOfLikes = post?.likes {
            likesLbl.text = "\(numberOfLikes)"
        }
        
        
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
        
//        if let userProfileUrl = postingUserImgUrl {
//            print("HI I AM THE USER PROFILE URL: \(userProfileUrl)")
//        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToFeed" {
            let nextScene = segue.destination as! FeedVC
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
