//
//  PostService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 10.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
class PostService{
    static let shared = PostService()
    func setNewLessonPost(currentUser : CurrentUser,postId : String ,users : [LessonFallowerUser] ,msgText : String, datas : [String] , lessonName : String , short_school : String , major : String , completion : @escaping(Bool) ->Void )
    {
        
        var dic = ["lessonName":lessonName,
        "postTime":FieldValue.serverTimestamp(),
        "senderName":currentUser.name as Any,
        "senderImage":currentUser.thumb_image as Any,
        "text":msgText,
        "likes":0,
        "comment":0,
        "lastComment":"empty", "last-comment-name": "empty"] as [String:Any]
        setPostForUser(userId: users, postId: postId) { (val) in
            if val {
                let db = Firestore.firestore().collection(short_school).document("lesson-post")
                    .collection("post").document(postId)
                if !datas.isEmpty {
                    dic["data"] = datas
                      
                }
               
                db.setData(dic, merge: true) { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
            }
        }
    }
    func setPostForUser (userId : [LessonFallowerUser] , postId : String , completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection("user")
        let dic = ["postId":postId] as [String:Any]
        for id in userId {
            guard let uid = id.uid else { return }
            db.document(uid).collection("lesson-post")
                .document(postId).setData(dic, merge: true) { (err) in
                    if err != nil {
                        print("setPostForUser err \(err as Any)")
                    }
            }
            completion(true)
        }
        
        
    }
    
}
