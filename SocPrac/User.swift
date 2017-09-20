//
//  User.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import Foundation
import Firebase

class User {

    private var _username: String!
    private var _userKey: String!
    private var _profileImg: String!
    private var _creationDate: String!
    private var _userRef: DatabaseReference!
    
    
    var username: String {
        return _username
    }
    
    var profileImg: String! {
        return _profileImg
    }
    
    var userKey: String {
        return _userKey
    }
    
    var creationDate: String {
        return _creationDate
    }
    
    init(username: String, profileImg: String, creationDate: String) {
        self._username = username
        self._profileImg = profileImg
        self._creationDate = creationDate
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let profileImg = userData["profileImg"] as? String {
            self._profileImg = profileImg
        }
        
        if let creationDate = userData["creationDate"] as? String {
            self._creationDate = creationDate
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
}
