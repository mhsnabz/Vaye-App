//
//  CommentNotificationService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 5.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class CommentNotificationService{
    static let shared = CommentNotificationService()
    
    func likeLessonPostComment(post : LessonPostModel ,commentModel : CommentModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if commentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(commentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
            }
        }
    }
    
    func likeMainPostComment(post : MainPostModel ,commentModel : CommentModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if commentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(commentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil , clupName: nil , vayeAppPostName: post.lessonName), merge: true)
            }
        }
    }
    
    func likeNoticesComment(post : NoticesMainModel ,commentModel : CommentModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description

        if commentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(commentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
            }
        }
    }
    
    func newLessonPostCommentNotification (post : LessonPostModel , currentUser : CurrentUser , text : String , type : String) {
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if post.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
            }
        }
    }
   
    func newNoticesPostCommentNotification(post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if post.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
            }
        }
    }
    func sendNewLessonPostRepliedCommentNotification(commentModel : CommentModel ,post : LessonPostModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if commentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(commentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
            }
        }
    }
    
    func sendNewNoticesPostRepliedCommentNotification(commentModel : CommentModel ,post : NoticesMainModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if commentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(commentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil, clupName: post.clupName , vayeAppPostName: nil), merge: true)
            }
        }
    }
    func newLessonPostMentionedComment(username : String ,post : LessonPostModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {[weak self] (otherUser) in
            guard let sself = self else { return }
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
            return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(sself.getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                }
            }
    }
    }
    func newNoticesMentionedComment(username : String ,post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {[weak self] (otherUser) in
            guard let sself = self else { return }
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
            return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(sself.getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                }
            }
    }
    }
    func newNoticesPostMentionedComment(username : String ,post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {[weak self] (otherUser) in
            guard let sself = self else { return }
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
            return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(sself.getDictionary(type: type, text: text, currentUser: currentUser, not_id: notificaitonId, postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                }
            }
    }
    }
    
    
    func getDictionary(type : String , text : String , currentUser : CurrentUser
                       ,not_id : String , postId : String , lessonName : String? , clupName : String? , vayeAppPostName : String?) -> [String:Any] {
        
        let dic = [
            "type":type, "text":text ,
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
