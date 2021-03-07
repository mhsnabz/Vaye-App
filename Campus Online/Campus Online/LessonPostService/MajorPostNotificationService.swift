//
//  MajorPostService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 7.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class MajorPostNotificationService {
    static let shared = MajorPostNotificationService()
    
    func setPotLike(postType : String , post: LessonPostModel , currentUser : CurrentUser , text : String ,type : String){
        if post.senderUid == currentUser.uid {
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                db.setData(self.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: post.lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                
            }
        }
    }
    
    func setNewTeacherPostNotification(getterUid : [String] ,lessonName : String ,postType : String ,currentUser : CurrentUser, text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        for item in getterUid {
            if item != currentUser.uid {
                if !currentUser.slientUser.contains(item) {
                    let db = Firestore.firestore().collection("user")
                        .document(item).collection("notification").document(notificaitonId)
                                  
                    db.setData(self.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                }
                
            }
        }
        for item in text.findMentionText(){
            print(item)
            UserService.shared.getOtherUserByMention(username: item) { (user) in
                guard let user = user else { return }
                if user.short_school == currentUser.short_school{
                    if user.bolum  == currentUser.bolum {
                        if user.uid != currentUser.uid {
                            if !currentUser.slientUser.contains(user.uid) {
                                let db = Firestore.firestore().collection("user")
                                    .document(user.uid).collection("notification").document(Int64(Date().timeIntervalSince1970 * 1000 + 1).description)
                                db.setData(self.getDictionary(postType: postType, type: MajorPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: Int64(Date().timeIntervalSince1970 * 1000 + 1).description, postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)

                                if user.mention {
                                    //FIXME:- send push notificaiton
                                }
                            }
                           
                        }


                    }
                }
            }
        }
    }
    
    func setNewPostNotification(lessonName : String ,postType : String ,currentUser : CurrentUser, text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson").collection(currentUser.bolum).document(lessonName).collection("notification_getter")
        db.getDocuments { (querySnp, err) in
            if err == nil {
                guard let snap = querySnp else { return }
                if !snap.isEmpty {
                    for uid in snap.documents {
                        if uid.documentID != currentUser.uid {
                            if !currentUser.slientUser.contains(uid.documentID) {
                                let db = Firestore.firestore().collection("user")
                                    .document(uid.documentID).collection("notification").document(notificaitonId)
                                db.setData(self.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                            }
                            
                        }
                    }
                
                }
            }
        }
        
        for item in text.findMentionText(){
            print(item)
            UserService.shared.getOtherUserByMention(username: item) { (user) in
                guard let user = user else { return }
                if user.short_school == currentUser.short_school{
                    if user.bolum  == currentUser.bolum {
                        if user.uid != currentUser.uid {
                            if !currentUser.slientUser.contains(user.uid) {
                                let db = Firestore.firestore().collection("user")
                                    .document(user.uid).collection("notification").document(Int64(Date().timeIntervalSince1970 * 1000 + 1).description)
                                db.setData(self.getDictionary(postType: postType, type: MajorPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: Int64(Date().timeIntervalSince1970 * 1000 + 1).description, postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)

                                if user.mention {
                                    //FIXME:- send push notificaiton
                                }
                            }
                           
                        }


                    }
                }
            }
        }
    }
    
    func setCommentLike(){
        
    }
    
    
    func getDictionary(postType : String,type : String , text : String , currentUser : CurrentUser,not_id : String , postId : String , lessonName : String? , clupName : String? , vayeAppPostName : String?) -> [String:Any] {
        
        let dic = [
            "type":type,
            "text":text ,
            "postType": postType,
            "senderUid":currentUser.uid as Any,
            "time":FieldValue.serverTimestamp(),
            "senderImage":currentUser.thumb_image ?? "",
            "not_id":not_id,
            "isRead":false,
            "postId":postId,
            "username":currentUser.username as Any,
            "senderName" : currentUser.name as Any,
            "lessonName":lessonName ?? vayeAppPostName ?? clupName as Any ] as [String : Any]
        
        return dic
        
    }
}
