//
//  Comment.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 9/4/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    private var _commentText: String!
    private var _postId: String!
    private var _userId: String!
    
    private var _commentKey: String!
    
    private var _commentRef: DatabaseReference!
    
    var commentText: String {
        return _commentText
    }
    
    var postId: String {
        return _postId
    }
    
    var userId: String {
        return _userId
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    init(commentText: String, postId: String, userId: String) {
        self._commentText = commentText
        self._postId = postId
        self._userId = userId
    }
    
    init(commentKey: String, commentData: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        
        if let commentText = commentData["commentText"] as? String {
            self._commentText = commentText
        }
        
        if let postId = commentData["postId"] as? String {
            self._postId = postId
        }
        
        if let userId = commentData["userId"] as? String {
            self._userId = userId
        }
        
        _commentRef = DataService.ds.REF_COMMENTS.child(_commentKey)
        
    }
    
    
    
}













