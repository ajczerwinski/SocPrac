//
//  Post.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _userId: String!
    private var _creationDate: String!
    private var _lastUpdated: String!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var userId: String {
        return _userId
    }
    
    var creationDate: String {
        return _creationDate
    }
    
    var lastUpdated: String {
        return _lastUpdated
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imageUrl: String, likes: Int, userId: String, creationDate: String, lastUpdated: String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._userId = userId
        self._creationDate = creationDate
        self._lastUpdated = lastUpdated
        
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userId = postData["userId"] as? String {
            self._userId = userId
        }
        
        if let creationDate = postData["creationDate"] as? String {
            self._creationDate = creationDate
        }
        
        if let lastUpdated = postData["lastUpdated"] as? String {
            self._lastUpdated = lastUpdated
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
    
    
    
}
