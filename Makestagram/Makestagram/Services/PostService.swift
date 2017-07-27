//
//  PostService.swift
//  Makestagram
//
//  Created by Sakada Lim on 7/10/17.
//  Copyright © 2017 Sakada Lim. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    static func create(for image: UIImage){
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef){ (downloadURL) in
            guard let downloadURL = downloadURL else { return }
            
        let urlString = downloadURL.absoluteString
        let aspectHeight = image.aspectHeight
        create(forURLString: urlString, aspectHeight: aspectHeight)
        }
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        let newPostRef = DatabaseReference.toLocation(.postsChild(uid: currentUser.uid)).childByAutoId()
        let newPostKey = newPostRef.key
        
        UserService.followers(for: currentUser) { (followerUIDs) in
            
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            DatabaseReference.toLocation(.root).updateChildValues(updatedData)
            
            DatabaseReference.toLocation(.root).updateChildValues(updatedData, withCompletionBlock: { (error, ref) in
                let postCountRef = Database.database().reference().child("users").child(currentUser.uid).child("post_count")
                
                postCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    let currentCount = mutableData.value as? Int ?? 0
                    
                    mutableData.value = currentCount + 1
                    
                    return TransactionResult.success(withValue: mutableData)
                })
            })
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?)->Void){
        let ref = DatabaseReference.toLocation(.showPost(posterUID: posterUID, postKey: postKey))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            LikeService.isPostLiked(post) {(isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
}
