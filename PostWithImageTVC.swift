
//  PostWithImageTVC.swift
//  TwitteriOSDemo
//
//  Created by Islam Gharib on 11/2/18.
//  Copyright © 2018 Gharib. All rights reserved.
//

import UIKit
import Firebase
class PostWithImageTVC: UITableViewCell {
    @IBOutlet weak var postTextTV: UITextView!
    @IBOutlet weak var postImageIV: UIImageView!
    @IBOutlet weak var personImageIV: UIImageView!
    @IBOutlet weak var personNameLB: UILabel!
    @IBOutlet weak var postDateLB: UILabel!
    // get a ref of firebase database --> Users
    var ref = DatabaseReference.init()
    
    func setText(post:Post){
        self.postTextTV.text = post.postText!
        
        // display date -> convert from string date to nsdate
        let milliseconds = CLong(post.postDate!)
        let date = NSDate(timeIntervalSince1970: TimeInterval(milliseconds! / 1000))
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy HH:mm"
        let postdate = dateFormat.string(from:date  as Date)
        postDateLB.text = postdate
        
        setPostImage(url:post.postImage!)
        // invoke loadUsers to display full name and image of users
        loadUsers(userUID: post.userUID!)
    }
    // loading image of post
    func setPostImage(url:String){
        // get a reference of the firebase storage
        let storageRef = Storage.storage().reference(forURL: "gs://myfirebaseiosapps.appspot.com")
        
        // get the postimage ref from firebase storage
        let postImageRef = storageRef.child(url)
        
        // get the image data from image ref
        // Data replaced by getData
        postImageRef.getData(maxSize: 8 * 1024 * 1024){
            (data, error) in
            // code here
            if let error = error{
                print("Can't load image")
            }else{
                self.postImageIV.image = UIImage(data: data!)
            }
        }
    }
    
    // loading image of user
    func setUserImage(url:String){
        // get a reference of the firebase storage
        let storageRef = Storage.storage().reference(forURL: "gs://myfirebaseiosapps.appspot.com")
        
        // get the postimage ref from firebase storage
        let postImageRef = storageRef.child(url)
        
        // get the image data from image ref
        // Data replaced by getData
        postImageRef.getData(maxSize: 8 * 1024 * 1024){
            (data, error) in
            // code here
            if let error = error{
                print("Can't load image")
            }else{
                self.personImageIV.image = UIImage(data: data!)
            }
        }
    }
    func loadUsers(userUID:String){
        ref = Database.database().reference()
        
        self.ref.child("Users").child(userUID).observe(.value, with: {
            (snapshot) in // snapshot is the data expected to get from firebase
            // code here
            // get all child obj so snapshot contain keys and values -> FIRDataSnapshot replaced with DataSnapshot
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let postKey = snap.key as? String{
                        if postKey == "fullName"{
                            let fullName = snap.value as? String
                            self.personNameLB.text = fullName
                        }
                        if postKey == "userImagePath"{
                            let userImagePath = snap.value as? String
                            self.setUserImage(url: userImagePath!)
                        }
                        
                    }
                }
                
            }
        })
    }
}
