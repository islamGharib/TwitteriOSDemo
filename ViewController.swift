//
//  ViewController.swift
//  TwitteriOSDemo
//
//  Created by Islam Gharib on 10/30/18.
//  Copyright © 2018 Gharib. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // a unique id for every user register or login
    var UserUID:String?
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var userImageIV: UIImageView!
    var imagePicker:UIImagePickerController!
    
    // get a reference of the firebase database
    var ref = DatabaseReference.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // create instance of firbase database ->  don't forget to make the database rules of firebase true
        // FIRDatabase is replaced with Database
        self.ref = Database.database().reference()
        
        // save user login info to open the posting VC if a user has login before
        if let user = Auth.auth().currentUser{
            self.UserUID = user.uid
            goToPosting()
        }
    }
    
    @IBAction func pickImageBtn(_ sender: Any) {
        // TODO:- select image from your phone
        present(imagePicker, animated: true, completion: nil) // when selecting the image the next func will fired to display the image inside IV
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            userImageIV.image = image
        }
         imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!){
            (user,error) in
            // Here Code
            if let error = error{
                print(error)
            }else{
                print(" User uid \(user?.user.uid)")
                self.UserUID = (user?.user.uid)!
                // go to PostingVC after login
                self.goToPosting()
            }
            
        }
       
    }
        
    @IBAction func registerBtn(_ sender: Any) {
        // enable email authentication in firebase
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!){
            (user,error) in
            // Here Code
            if let error = error{
                print(error)
            }else{
                print(" User uid \(user?.user.uid)")
                self.UserUID = (user?.user.uid)!
                
                self.uploadUserImage()
                
            }
        }
    }
    
    // Upload image to firebase
    func uploadUserImage(){
        let image:UIImage = self.userImageIV.image!
        // get a reference of the firebase storage
        let storageRef = Storage.storage().reference(forURL: "gs://myfirebaseiosapps.appspot.com")
        
        // data uploaded
        var data = NSData()
        data = UIImageJPEGRepresentation(image, 0.8)! as NSData
        
        // making a unque path for image uploaded using UserUID and date of uploaded
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy HH:mm"
        let imageName = "\(self.UserUID!)_ \(dateFormat.string(from: NSDate() as Date))"
        let imagePath = "UsersImages/\(imageName).jpg"
        
        // specify the reference child , metadata content type and data the upload the image into the child
        let childUsersImages = storageRef.child(imagePath)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        // upload image
        childUsersImages.putData(data as Data, metadata: metaData)
        
        // save info to firebase database
        saveUserInfo(userImagePath: imagePath, UserName: fullNameTF.text!)
    }
    
    // save the user UID and user image to firebase database
    func saveUserInfo(userImagePath:String, UserName:String){
        let msg = ["fullName":UserName, "userImagePath":userImagePath]
        self.ref.child("Users").child(self.UserUID!).setValue(msg)
    }
    
    // go to PostingVC
    func goToPosting(){
        // used dispatchq func to invoke this func in paralell not only when pressing login but either if a usered is registered before in his phone
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showPosts", sender: self.UserUID)
        }
        dismiss(animated: true, completion: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPosts"{
            if let dist = segue.destination as? PostingVC{
                if let userUID = sender as? String{
                    dist.userUID = userUID
                }
            }
        }
    }
}


