
//  AddPostTVC.swift
//  TwitteriOSDemo
//
//  Created by Islam Gharib on 11/1/18.
//  Copyright © 2018 Gharib. All rights reserved.
//

import UIKit
import  Firebase
class AddPostTVC: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var postTextTV: UITextView!
    
    var main:PostingVC?
    var imagePicker:UIImagePickerController! // to attach image in a post
    // get a copy reference of posts stored in firebase database
    var ref = DatabaseReference.init()
    var UserUID:String?
    var imagePath = "No image"
    @IBAction func postBtn(_ sender: Any) {
        ref = Database.database().reference()
        var postMsg = ["UserUID":UserUID!, "text":postTextTV.text, "imagePath":imagePath, "postDate":ServerValue.timestamp()] as [String : Any]
        ref.child("Posts").childByAutoId().setValue(postMsg)
    }
    
    @IBAction func attachImageBtn(_ sender: Any) {
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // TODO:- select image from your phone
        main!.present(imagePicker, animated: true, completion: nil) // when selecting the image the next func will fired to display the image inside IV
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            uploadUserImage(image: image)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    // Upload image to firebase
    func uploadUserImage(image:UIImage){
        // get a reference of the firebase storage
        let storageRef = Storage.storage().reference(forURL: "gs://myfirebaseiosapps.appspot.com")
        
        // data uploaded
        var data = NSData()
        data = UIImageJPEGRepresentation(image, 0.8)! as NSData
        
        // making a unque path for image uploaded using UserUID and date of uploaded
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy HH:mm"
        let imageName = "\(self.UserUID!)_ \(dateFormat.string(from: NSDate() as Date))"
        self.imagePath = "UsersPostsImages/\(imageName).jpg"
        
        // specify the reference child , metadata content type and data the upload the image into the child
        let childUsersImages = storageRef.child(self.imagePath)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        // upload image
        childUsersImages.putData(data as Data, metadata: metaData)
        
    }
}
