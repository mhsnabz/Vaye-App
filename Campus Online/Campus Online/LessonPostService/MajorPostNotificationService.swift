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
                db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: post.lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                
            }
            
            PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: post.senderUid, otherUser: nil, target: PushNotificationTarget.like.type, senderName: currentUser.name, mainText: post.text, type: MajorPostNotification.post_like.descp, senderUid: currentUser.uid)
        }
    }
    
    func setNewTeacherPostNotification(getterUid : [String] ,lessonName : String ,postType : String ,currentUser : CurrentUser, text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        for item in getterUid {
            if item != currentUser.uid {
                if !currentUser.slientUser.contains(item) {
                    let db = Firestore.firestore().collection("user")
                        .document(item).collection("notification").document(notificaitonId)
                                  
                    db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: item, otherUser: nil, target: PushNotificationTarget.newpost_lessonpost.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_post.descp, senderUid: currentUser.uid)
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
                                db.setData(Utilities.shared.getDictionary(postType: postType, type: MajorPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: Int64(Date().timeIntervalSince1970 * 1000 + 1).description, targetCommentId: "", postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)

                                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: item, otherUser: user, target: PushNotificationTarget.newpost_lessonpost.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_mentioned_post.descp, senderUid: currentUser.uid)
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
                                db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)
                                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: uid.documentID, otherUser: nil, target: PushNotificationTarget.newpost_lessonpost.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_post.descp, senderUid: currentUser.uid)
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
                                db.setData(Utilities.shared.getDictionary(postType: postType, type: MajorPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: Int64(Date().timeIntervalSince1970 * 1000 + 1).description, targetCommentId: "", postId: postId, lessonName: lessonName, clupName: nil, vayeAppPostName: nil), merge: true)

                                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: user.uid, otherUser: user, target: PushNotificationTarget.newpost_lessonpost.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_mentioned_post.descp, senderUid: currentUser.uid)
                            }
                           
                        }


                    }
                }
            }
        }
    }
    
    func setCommentLike(){
        
    }
    
    
   
}
