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
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.lessonPost.name, type: type, text: text, currentUser: currentUser,  not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: commentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.comment_like.descp, senderUid: currentUser.uid)
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
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.mainPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: nil , vayeAppPostName: post.lessonName), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: commentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MainPostNotification.comment_like.descp, senderUid: currentUser.uid)
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
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: commentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.comment_like.descp, senderUid: currentUser.uid)
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
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.lessonPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: post.senderUid, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_comment.descp, senderUid: currentUser.uid)
                
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
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: post.senderUid, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_comment.descp, senderUid: currentUser.uid)
            }
        }
    }
    func sendNewLessonPostRepliedCommentNotification(targetCommentModel : CommentModel ,post : LessonPostModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if targetCommentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(targetCommentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.lessonPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetCommentModel.commentId, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: targetCommentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_replied_comment.descp, senderUid: currentUser.uid)
            }
        }
    }
    
    func newMainPostCommentNotification(post : MainPostModel , currentUser : CurrentUser  , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if post.senderUid == currentUser.uid {
            return
        }
        else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.mainPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: nil , vayeAppPostName: post.postType), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: post.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MainPostNotification.new_comment.descp, senderUid: currentUser.uid)
            }
        }
    }
    
    func sendNewNoticesPostRepliedCommentNotification(targetCommentModel : CommentModel ,post : NoticesMainModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if targetCommentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(targetCommentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetCommentModel.commentId, postId: post.postId, lessonName: nil, clupName: post.clupName , vayeAppPostName: nil), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: targetCommentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_replied_comment.descp, senderUid: currentUser.uid)
            }
        }
    }
    
    func sendNewMainPostRepliedCommentNotification(targetCommentModel : CommentModel ,post : MainPostModel, currentUser : CurrentUser , text : String , type : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        if targetCommentModel.senderUid == currentUser.uid {
            return
        }else{
            if !currentUser.slientUser.contains(post.senderUid) {
                let db = Firestore.firestore().collection("user")
                    .document(targetCommentModel.senderUid!)
                    .collection("notification")
                    .document(notificaitonId)
                db.setData(Utilities.shared.getDictionary(postType: post.postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetCommentModel.commentId, postId: post.postId, lessonName: nil, clupName: nil , vayeAppPostName: post.postType), merge: true)
                PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: targetCommentModel.senderUid!, otherUser: nil, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MainPostNotification.new_replied_comment.descp, senderUid: currentUser.uid)
            }
        }
    }
    func newLessonPostMentionedComment(username : String ,post : LessonPostModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {(otherUser) in
           
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if otherUser.mention{
                if currentUser.short_school == otherUser.short_school {
                    if currentUser.bolum == otherUser.bolum {
                        if !currentUser.slientUser.contains(otherUser.uid) {
                            let db = Firestore.firestore().collection("user")
                                .document(otherUser.uid).collection("notification").document(notificaitonId)
                            db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.lessonPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                            PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_mentioned_comment.descp, senderUid: currentUser.uid)
                        }
                    }
                }
            }
        }
    }
    func newLessonPostMentionedRepliedComment(targetComment : CommentModel,username : String ,post : LessonPostModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {(otherUser) in
           
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if otherUser.mention{
                if currentUser.short_school == otherUser.short_school {
                    if currentUser.bolum == otherUser.bolum {
                        if !currentUser.slientUser.contains(otherUser.uid) {
                            let db = Firestore.firestore().collection("user")
                                .document(otherUser.uid).collection("notification").document(notificaitonId)
                            db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.lessonPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetComment.commentId!, postId: post.postId, lessonName: post.lessonName , clupName: nil , vayeAppPostName: nil), merge: true)
                            PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MajorPostNotification.new_replied_mentioned_comment.descp, senderUid: currentUser.uid)
                        }
                    }
                }
            }
        }
    }
    func newNoticesMentionedComment(username : String ,post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {(otherUser) in
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_mentioned_comment.descp, senderUid: currentUser.uid)
                }
            }
        }
    }
    func newNoticesMentionedRepliedComment(targetCommnet : CommentModel,username : String ,post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {(otherUser) in
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetCommnet.commentId, postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_replied_mentioned_comment.descp, senderUid: currentUser.uid)
                }
            }
        }
    }
    
    func newMainPostMentionedComment(username : String ,post : MainPostModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) { (otherUser) in
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(Utilities.shared.getDictionary(postType:NotificationPostType.mainPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: nil , vayeAppPostName: post.postType), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MainPostNotification.new_mentioned_comment.descp, senderUid: currentUser.uid)
                }
            }
        }
    }
    func newMainPostMentionedRepliedComment(targetComment : CommentModel,username : String ,post : MainPostModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) { (otherUser) in
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(Utilities.shared.getDictionary(postType:NotificationPostType.mainPost.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: targetComment.commentId!, postId: post.postId, lessonName: nil , clupName: nil , vayeAppPostName: post.postType), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: MainPostNotification.new_replied_mentioned_comment.descp, senderUid: currentUser.uid)
                    
                }
            }
        }
    }
    
    func newNoticesPostMentionedComment(username : String ,post : NoticesMainModel , currentUser : CurrentUser , text : String , type : String){
        UserService.shared.getUserBy_Mention(username: username) {(otherUser) in
            let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            if username == currentUser.username{
                return
            }else if currentUser.mention{
                if !currentUser.slientUser.contains(otherUser.uid) {
                    let db = Firestore.firestore().collection("user")
                        .document(otherUser.uid).collection("notification").document(notificaitonId)
                    db.setData(Utilities.shared.getDictionary(postType: NotificationPostType.notices.name, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: post.postId, lessonName: nil , clupName: post.clupName , vayeAppPostName: nil), merge: true)
                    PushNotificationService.shared.sendPushNotification(not_id: Int64(Date().timeIntervalSince1970 * 1000).description, getterUid: otherUser.uid, otherUser: otherUser, target: PushNotificationTarget.comment.type, senderName: currentUser.name, mainText: text, type: NoticesPostNotification.new_mentioned_comment.descp, senderUid: currentUser.uid)
                }
            }
        }
    }
    
    
    
    
    
    
}
