//
//  FollowNotificationService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 8.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class FollowNotificationService {
    static let shared =  FollowNotificationService()
    func followingNotification(postType : String ,currentUser : CurrentUser , otherUser : OtherUser , text : String , type : String ){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("notification").document(notificaitonId)
        db.setData(self.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: "", lessonName: "", clupName: "", vayeAppPostName: ""), merge: true)
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
