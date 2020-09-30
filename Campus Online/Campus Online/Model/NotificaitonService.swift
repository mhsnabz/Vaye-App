//
//  NotificaitonService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class NotificaitonService{
   static let shared = NotificaitonService()
    func send_home_like_notification(post : LessonPostModel , currentUser : CurrentUser, notificationDespriction : String){
        if post.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                let dic = ["type":notificationDespriction ,
                           "senderUid" : currentUser.uid as Any,
                           "time":FieldValue.serverTimestamp(),
                           "senderImage":currentUser.thumb_image as Any ,
                           "not_id":notificaitonId,
                           "isRead":false ,
                           "username":currentUser.username as Any,
                           "postId":post.postId as Any,
                           "senderName":currentUser.name as Any,
                           "lessonName":post.lessonName as Any] as [String : Any]
                db.setData(dic, merge: true)
                
            }
            }
    }
    func send_home_remove_like_notification(post : LessonPostModel , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("user")
            .document(post.senderUid).collection("notification").whereField("postId", isEqualTo: post.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: NotificaitonDescprition.like_home.desprition)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if !snap.isEmpty {
                    for item in snap.documents{
                        let db = Firestore.firestore().collection("user")
                            .document(post.senderUid).collection("notification").document(item.documentID)
                        db.delete()
                    }
                }
            }
        }
    }
    
}
enum NotificaitonDescprition {
    case like_home
    
    var desprition : String {
        switch self {
       
        case .like_home:
            return "Gönderini Beğendi"
        }
    }
}
enum NotificationType{
    case home_like
    var desprition : String {
        switch self{
        
        case .home_like:
            return "home_like"
        }
    }
}
