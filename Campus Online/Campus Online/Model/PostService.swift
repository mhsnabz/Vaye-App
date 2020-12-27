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
    
 ///İSTE/lesson-post/post/1600774976770
    func updatePost(currentUser : CurrentUser , postId : String , msgText : String, completion : @escaping(Bool) -> Void ){
        
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId)
        let dic = [ "text":msgText ] as [String:Any]
        
        db.updateData(dic) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
    
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
        
     func setThumbDatas(currentUser : CurrentUser , postId : String ,completion : @escaping(Bool)->Void){
       ///user/2YZzIIAdcUfMFHnreosXZOTLZat1/saved-task/task
        let db = Firestore.firestore().collection("user").document(currentUser.uid).collection("saved-task")
            .document("task")
        db.getDocument { [weak self] (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(true)
                    return }
                if snap.exists {
                    let data = snap.get("data") as! [String]
                    self?.moveThumbDatas(currentUser: currentUser, array: data, postId: postId) { (_) in
                        db.setData(["data":[]], merge: true) { (err) in
                            if err == nil {
                                completion(true)
                            }
                        }
                    }
                }else{
                    completion(true)
                }
               
            }
    }
    
    }
     func moveThumbDatas(currentUser : CurrentUser ,array : [String], postId : String , completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection(currentUser.short_school).document("lesson-post")
            .collection("post").document(postId)
        db.setData(["thumbData":array] as [String : Any], merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    func loadMore(compoletion : @escaping(DocumentSnapshot) ->Void)  {
        
    }
    
    func setLike(post : LessonPostModel ,collectionView : UICollectionView, currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    
                    completion(true)
     
                    NotificaitonService.shared.send_post_like_comment_notification(post: post, currentUser: currentUser, text: Notification_description.like_home.desprition, type: NotificationType.home_like.desprition)
                }
            }
        }else{
            post.likes.remove(element: currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in

                NotificaitonService.shared.send_home_remove_like_notification(post: post, currentUser: currentUser)
                completion(true)
            }
        }
    }
    func setDislike(post : LessonPostModel ,collectionView : UICollectionView, currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school).document("lesson-post").collection("post").document(post.postId)
            db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                if err == nil {
                    db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                completion(true)
            }
        }
    }

    func setFav(post : LessonPostModel ,collectionView : UICollectionView, currentUser : CurrentUser , completion:@escaping(Bool) ->Void){
        if !post.favori.contains(currentUser.uid){
            post.favori.append(currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["favori":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
 
                //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                let dbc = Firestore.firestore().collection("user")
                    .document(currentUser.uid).collection("fav-post").document(post.postId)
                let dic = ["postId":post.postId as Any] as [String:Any]
                dbc.setData(dic, merge: true) { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
            }
            
        }
        else{
            post.favori.remove(element: currentUser.uid)
            collectionView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["favori":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                let dbc = Firestore.firestore().collection("user")
                    .document(currentUser.uid).collection("fav-post").document(post.postId)
                dbc.delete { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
                
            }
            
        }
    }
    
    
    //MARK::- teacher service
    
    func teacherSetNewPost( link : String?,currentUser : CurrentUser,postId : String ,users : [String] ,msgText : String, datas : [String] , lessonName : String , short_school : String , major : String , completion : @escaping(Bool) ->Void){
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
        setPostForSenderTeacher(currentUser: currentUser, postId: postId)
        setPostForLesson(currentUser: currentUser, dic: dic, short_school: currentUser.short_school, lessonName: lessonName, postId: postId) {[weak self] (val) in
            guard let sself = self else { return }
            if val {
                sself.teacherSetPostForUser(userId: users, postId: postId) { (value) in
                    if value {
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }
    
    func setPostForSenderTeacher(currentUser  : CurrentUser , postId :String ){
        let db = Firestore.firestore().collection("user").document(currentUser.uid)
            .collection("lesson-post").document(postId)
        db.setData(["postId":postId] as [String:Any], merge: true)
    }
    
    func teacherSetPostForUser (userId : [String] , postId : String , completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection("user")
        let dic = ["postId":postId] as [String:Any]
        for uid in userId {
            
            db.document(uid).collection("lesson-post")
                .document(postId).setData(dic, merge: true) { (err) in
                    if err != nil {
                        print("setPostForUser err \(err as Any)")
                    }
                    completion(true)
            }
            
        }
    }
    
    
}
