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
            
            let notificaitonId = Date().timeIntervalSince1970.description
            
            let db = Firestore.firestore().collection("user")
                .document(post.senderUid).collection("notification").document(notificaitonId)
            let dic = ["type":notificationDespriction ,
                       "senderUid" : currentUser.uid as Any,
                       "time":FieldValue.serverTimestamp(),
                       "senderImage":currentUser.thumb_image as Any ,
                       "not_id":notificaitonId,
                       "isRead":false ,
                       "postId":post.postId as Any,
                       "senderName":currentUser.name as Any,
                       "lessonName":post.lessonName as Any] as [String : Any]
            db.setData(dic, merge: true)
            
        }
    }
    //user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601492948.048019
  
    
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
