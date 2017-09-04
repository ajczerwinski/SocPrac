//
//  DataService.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_COMMENTS = DB_BASE.child("comments")
    
    // Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_USER_IMAGES = STORAGE_BASE.child("profile-pics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_COMMENTS: DatabaseReference {
        return _REF_COMMENTS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        //let uid = KeychainWrapper.stringForKey(KEY_UID)
        //let uid = KeychainWrapper.set(KEY_UID)
        //let uid = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_POST_IMAGES: StorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_USER_IMAGES: StorageReference {
        return _REF_USER_IMAGES
    }
    
    func createFirbaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
