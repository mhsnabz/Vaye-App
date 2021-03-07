//
//  File.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 8.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore

class MainPostNotificationService {
    static let shared = MainPostNotificationService()
    
    func setPostLike(postType : String , post : MainPostModel , currentUser : CurrentUser , text : String , type : String){
        if post.senderUid == currentUser.uid {
            return
        }else{
            if !post.silent.contains(post.senderUid) {
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                db.setData(self.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil, clupName: nil, vayeAppPostName: post.postType), merge: true)
            }
        }
        
    }
    func setNewPostMentionedNotification( postType : String , currentUser : CurrentUser ,text : String , type : String ,postId : String){
        
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        for item in text.findMentionText(){
            UserService.shared.getOtherUserByMention(username: item) { (user) in
                if let user = user {
           
                        if user.uid != currentUser.uid {
                            let db = Firestore.firestore().collection("user")
                                .document(user.uid).collection("notification").document(notificaitonId)
                            db.setData(self.getDictionary(postType: postType, type: MainPostNotification.new_mentioned_post.type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: postId, lessonName: nil, clupName: postType, vayeAppPostName: nil), merge: true)
                            if user.mention {
                                //FIXME:- send push notificaiton
                            }
                        }
                    
                }
                
            }
        }
        
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
