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

    private var _userId: String!
    
    private var _creationDate: String!
    
    private var _commentKey: String!
    
    private var _commentRef: DatabaseReference!
    
    var commentText: String {
        return _commentText
    }
    
    var userId: String {
        return _userId
    }
    
    var creationDate: String {
        return _creationDate
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    init(commentText: String, userId: String, creationDate: String) {
        self._commentText = commentText
        self._userId = userId
        self._creationDate = creationDate
    }
    
    init(commentKey: String, commentData: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        
        if let commentText = commentData["commentText"] as? String {
            self._commentText = commentText
        }
        
        if let userId = commentData["userId"] as? String {
            self._userId = userId
        }
        
        if let creationDate = commentData["creationDate"] as? String {
            self._creationDate = creationDate
        }
        
    }
    
}













