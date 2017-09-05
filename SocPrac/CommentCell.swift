//
//  CommentCell.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 9/2/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit

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
    
    func configureCell(comment: Comment) {
        
        self.comment = comment
        print("HI I am the comment: \(comment.commentText)")
        self.commentText.text = ("\(comment.commentText) by \(comment.userId)")
        
        print("hi")
    }

}
