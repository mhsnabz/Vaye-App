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
        let silent : [String] = []
        var dic = ["lessonName":lessonName,
        "postTime":FieldValue.serverTimestamp(),
        "senderName":currentUser.name as Any,
        "text":msgText,
        "likes":[],
        "favori":[],
        "senderUid":currentUser.uid as Any,
        "silent":silent as Any,
        "comment":0,
        "dislike":[],
        "data":datas,
        "postID":Int64(postId) as Any,
        "username" : currentUser.username as Any,
        "thumb_image": currentUser.thumb_image as Any,
        "link":link ?? ""] as [String:Any]
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
    
    func fetchLessonPost(currentUser : CurrentUser, completion : @escaping([LessonPostModel])->Void){
        var post = [LessonPostModel]()
        //  let db : Query!
        let  db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").limit(to: 5).order(by: "postId", descending: true)//.order(by: FieldPath.documentID()).limit(toLast: 5)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    
                    for postId in snap.documents {
                        let db = Firestore.firestore().collection(currentUser.short_school)
                            .document("lesson-post").collection("post").document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists
                                {
                                    post.append(LessonPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                    completion(post)
                                    
                                }else{
                                    
                                    let deleteDb = Firestore.firestore().collection("user")
                                        .document(currentUser.uid).collection("lesson-post").document(postId.documentID)
                                    deleteDb.delete()
                                    print("postId = \(postId) deleted")
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
        
      
    func loadMore(compoletion : @escaping(DocumentSnapshot) ->Void)  {
        
    }

    
}
