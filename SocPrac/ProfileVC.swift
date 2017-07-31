//
//  ProfileVC.swift
//  SocPrac
//
//  Created by Allen Czerwinski on 7/25/17.
//  Copyright © 2017 Allen Czerwinski. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileUsernameText: FancyField!
    @IBOutlet weak var profileImageAdd: CircleView!
    
    var imagePicker: UIImagePickerController!
    //static var imageCache: Cache<NSString, UIImage> = Cache()
//    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageAdd.image = image
            imageSelected = true
        } else {
            print("AllenError: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFeed", sender: nil)
        
    }
    
    @IBAction func profileSaveBtnPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func addProfileImageTapped(_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    

    

}
