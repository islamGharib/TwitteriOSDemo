
//  PostingVC.swift
//  TwitteriOSDemo
//
//  Created by Islam Gharib on 11/1/18.
//  Copyright © 2018 Gharib. All rights reserved.
//

import UIKit
import Firebase
class PostingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listPostsTV: UITableView!
    // get a ref copy from firebase database
    var ref = DatabaseReference.init()
    var listOfPosts = [Post]()
    var userUID:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        listPostsTV.dataSource = self
        listPostsTV.delegate = self
        ref = Database.database().reference()
        listOfPosts.append(Post(postText: "", userUID: "SFg@#", postDate: "", postImage: ""))
        print("User UID: \(userUID!)")
        
        // invoke loadPosts func
        loadPosts()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPosts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first invoke the postCell to in the tob
        let post = listOfPosts[indexPath.row]
        if post.userUID == "SFg@#"{
            let cell:AddPostTVC = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! AddPostTVC
            cell.UserUID = self.userUID
            cell.main = self
            return cell
        }else if post.postImage == "No image"{  // then display postWithoutImageCell
            let cellpostWithoutImage:PostWithoutImageTVC = tableView.dequeueReusableCell(withIdentifier: "postWithoutImageCell", for: indexPath) as! PostWithoutImageTVC
            cellpostWithoutImage.setPost(post: post)
            return cellpostWithoutImage
        }else{
            let cellPostWithImage:PostWithImageTVC = tableView.dequeueReusableCell(withIdentifier: "postWithImageCell", for: indexPath) as! PostWithImageTVC
            cellPostWithImage.setText(post: post)
            return cellPostWithImage
        }
        
        
    }
    
    // load posts from firebase database
    func loadPosts(){
        // get the data from firebase and order it according to datePost
        self.ref.child("Posts").queryOrdered(byChild: "postDate").observe(.value, with: {
            (snapshot) in // snapshot is the data expected to get from firebase
            // code here
            self.listOfPosts.removeAll() // remove all data into list array
            self.listOfPosts.append(Post(postText: "", userUID: "SFg@#", postDate: "", postImage: "")) // displaying the postCell at the top of View controller
            // get all child obj so snapshot contain keys and values -> FIRDataSnapshot replaced with DataSnapshot
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let postData = snap.value as? [String:AnyObject]{
                        var postText:String?
                        if let postTextIn = postData["text"] as? String{
                            postText = postTextIn
                        }
                        var userUID:String?
                        if let userUIDIn = postData["UserUID"] as? String{
                            userUID = userUIDIn
                        }
                        var postImage:String?
                        if let postImageIn = postData["imagePath"] as? String{
                            postImage = postImageIn
                        }

                        var postDate:CLong?
                        if let postDateIn = postData["postDate"] as? CLong{
                            postDate = postDateIn
                            
                        }
                        self.listOfPosts.append(Post(postText: postText!, userUID: userUID!, postDate: "\(postDate!)", postImage: postImage!))
                    }
                }
                self.listPostsTV.reloadData()
                
                
                // every new message placed at the end
                let indexPath = IndexPath(row: self.listOfPosts.count-1, section: 0)
                self.listPostsTV.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    
    // hight for row at func used to specify the cell certain height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // first invoke the postCell to in the tob
            let post = listOfPosts[indexPath.row]
            if post.userUID == "SFg@#"{
            
                return 191
            }else if post.postImage == "No image"{  // then display postWithoutImageCell
            
                return 152
            }else{
            
                return 282
        }
    
    }
}
