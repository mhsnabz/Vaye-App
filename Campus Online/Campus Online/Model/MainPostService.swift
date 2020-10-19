//
//  MainPostService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 18.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MainPostService {
    static var shared = MainPostService()
    func setLikePost(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                ///İSTE/main-post/post/1602875543801
                let db = Firestore.firestore().collection(user.short_school).document("main-post")
                    .collection("post").document(post.postId)
                db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            completion(true)
                            NotificaitonService.shared.send_mainpost_like_notification(post: post, currentUser: currentUser, text: Notification_description.like_sell_buy.desprition, type: NotificationType.like_sell_buy.desprition)
                        }
                }
            }
        }
    }
        else{
            post.likes.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school).document("main-post")
                    .collection("post").document(post.postId)
                db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {(err) in
                    completion(true)
                    NotificaitonService.shared.mainpost_remove_like_notification(post: post, currentUser: currentUser)
                }
            }
            
        }
    }
    
    func setDislike(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void)
    {
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school).document("main-post")
                    .collection("post").document(post.postId)
                db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                        
                        completion(true)
                        }
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school).document("main-post")
                    .collection("post").document(post.postId)
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
            }
        }
        }
    }
 
    
}
