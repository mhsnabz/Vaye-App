//
//  NoticesNotificationService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 7.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class NoticesNotificationService {
    static let shared = NoticesNotificationService()
    
    func setPostLike(postType : String , post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        if post.senderUid == currentUser.uid {
            return
        }else{
            if !post.silent.contains(post.senderUid) {
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil, clupName: post.clupName, vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: post.senderUid, otherUser: nil, target: PushNotificationTarget.like.type, senderName: currentUser.name, mainText: post.text, type: NoticesPostNotification.post_like.descp, senderUid: currentUser.uid)
            }
            
        }
        
    }
    ///İSTE/clup/name/ Tasarım Öğrenci Topluluğu
    //followers
    func setNewPostNotification(clupName : String , postType : String , currentUser : CurrentUser , text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("clup")
            .collection("name")
            .document(clupName)
        db.getDocument { (docSnap, err) in
            if err == nil{
                guard let snap = docSnap else { return }
                if snap.exists {
                    if let followersList = snap.get("followers") as? [String] {
                        for item in followersList{
                            if item != currentUser.uid {
                                if !currentUser.slientUser.contains(item) {
                                    let db = Firestore.firestore().collection("user")
                                        .document(item).collection("notification").document(notificaitonId)
                                    db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: postId, lessonName: nil, clupName: clupName, vayeAppPostName: nil), merge: true)
                                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: item, otherUser: nil, target: PushNotificationTarget.like.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.post_like.descp, senderUid: currentUser.uid)
                                }
                            }
                        }
                    }
                   
                }
            }
        }
        for item in text.findMentionText(){
            UserService.shared.getOtherUserByMention(username: item) { (user) in
                if let user = user {
                    if user.short_school == currentUser.short_school{
                        if user.uid != currentUser.uid {
                            let db = Firestore.firestore().collection("user")
                                .document(user.uid).collection("notification").document(Int64(Date().timeIntervalSince1970 * 1000 + 1).description)
                            db.setData(Utilities.shared.getDictionary(postType: postType, type: NoticesPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: Int64(Date().timeIntervalSince1970 * 1000 + 1).description, targetCommentId: "", postId: postId, lessonName: nil, clupName: clupName, vayeAppPostName: nil), merge: true)
                            PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: item, otherUser: user, target: PushNotificationTarget.mention.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_mentioned_post.descp, senderUid: currentUser.uid)
                        }
                    }
                }
                
            }
        }
    }
  
    
}
