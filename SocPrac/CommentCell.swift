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
    
//    @IBOutlet weak var commentText: UILabel!
//
//    @IBOutlet weak var commentingUserProfileImg: UIImageView!
    
    @IBOutlet weak var commentText: UILabel!
    
    
    @IBOutlet weak var commentingUserProfileImg: UIImageView!
    var comment: Comment?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(comment: Comment, commenterUsername: String, commenterUserProfileImgUrl: String) {
        
        //self.comment = comment
        print("HI I am the comment: \(comment.commentText)")
        self.commentText.text = ("\(comment.commentText) by \(commenterUsername)")
        
        let commenterImageRef = Storage.storage().reference(forURL: commenterUserProfileImgUrl)
        commenterImageRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("AllenError: Unable to download userProfileImage from Firebase storage")
            } else {
                print("AllenData: commenterProfileImage successfully downloaded from Firebase storage")
                if let commenterImageData = data {
                    if let commenterImage = UIImage(data: commenterImageData) {
                        self.commentingUserProfileImg.image = commenterImage
                    }
                }
            }
        })
        
        
        print("HI I AM THE POST IMAGE URL: \(commenterUserProfileImgUrl)")
        
        print("hi")
    }

}
