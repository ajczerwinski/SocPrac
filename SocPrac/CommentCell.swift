//
//  CommentCell.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 9/2/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commentText: UILabel!
    
    
    @IBOutlet weak var commentingUserProfileImg: UIImageView!
    var comment: Comment?
    
    func configureCell(comment: Comment, commenterUsername: String? = nil, commenterUserProfileImgUrl: String? = nil) {

        //print("HI I am the comment: \(comment.commentText)")
        
        self.commentText.text = comment.commentText + " @" + commenterUsername!
        
        let commenterImageRef = Storage.storage().reference(forURL: commenterUserProfileImgUrl!)
        
        commenterImageRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("AllenError: Unable to download commenterProfileImage from Firebase storage")
            } else {
                print("AllenData: commenterProfileImage successfully downloaded from Firebase storage")
                if let commenterImageData = data {
                    if let commenterImage = UIImage(data: commenterImageData) {
                        self.commentingUserProfileImg.image = commenterImage
                    }
                }
            }
        })
        
        
        //print("HI I AM THE POST IMAGE URL: \(commenterUserProfileImgUrl)")
        
    }
    
    
    func configureCellNoComment(comment: String) {
        self.commentText.text = comment
    }

}
