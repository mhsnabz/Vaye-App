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
    func setNewLessonPost( link : String?,currentUser : CurrentUser,postId : String ,users : [LessonFallowerUser] ,msgText : String, datas : [String] , lessonName : String , short_school : String , major : String , completion : @escaping(Bool) ->Void )
    {
        var dic = ["lessonName":lessonName,
        "postTime":FieldValue.serverTimestamp(),
        "senderName":currentUser.name as Any,
        "senderImage":currentUser.thumb_image as Any,
        "text":msgText,
        "likes":0,
        "comment":0,
        "link":link ?? "",
      
        "lastComment":"empty", "last-comment-name": "empty","last-comment-image":"empty"] as [String:Any]
        if !datas.isEmpty {
            dic["data"] = datas
        }
        
        setPostForLesson(currentUser: currentUser, dic: dic, short_school: short_school, lessonName: lessonName, postId: postId) { (val) in
            if val {
                self.setPostForUser(userId: users, postId: postId) { (value) in
                    if value {
                        completion(true)
                    }else{
                        completion(false)
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
                    completion(true)
            }
            
        }
        
        
    }
    func setPostForLesson(currentUser : CurrentUser,dic : [String:Any] , short_school : String , lessonName : String ,postId : String, completion : @escaping(Bool) -> Void){
        let db = Firestore.firestore().collection(short_school).document("lesson-post")
            .collection("post").document(postId)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                let db = Firestore.firestore().collection(short_school).document("lesson").collection(currentUser.bolum)
                    .document(lessonName).collection("lesson-post").document(postId)
                let dic = ["postId":postId] as [String:Any]
                db.setData(dic, merge: true) { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
                
            }else{
                print("setPostForLesson err : \(err?.localizedDescription as Any)")
            }
        }
        
    }
    
}
