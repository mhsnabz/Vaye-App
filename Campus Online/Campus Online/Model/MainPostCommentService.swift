//
//  MainPostCommentService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//
import UIKit
import FirebaseFirestore
class MainPostCommentService {
    static var shared = MainPostCommentService()
    func setNewComment(currentUser : CurrentUser ,target : String,commentText : String, postId : String ,commentId : String ,completion : @escaping(Bool)->Void){
        
        //main-post/sell-buy/post/1603644806086/cmment/Sb4DXq5THBMOcE0J0K5c
        let db = Firestore.firestore().collection("main-post")
            .document(target)
            .collection("post")
            .document(postId)
            .collection("comment")
            .document(commentId)
        let dic = ["senderName" : currentUser.name as Any,
                   "senderUid" : currentUser.uid as Any,
                   "username" : currentUser.username as Any,
                   "time":FieldValue.serverTimestamp() ,
                   "comment":commentText ,
                   "commentId":commentId,
                   "postId":postId,
                   "likes":[],"replies" : [] ,
                   "senderImage" : currentUser.thumb_image as Any] as [String : Any]
        db.setData(dic, merge: true) {[weak self] (err) in
            if err == nil {
                guard let sself = self else { return }
                sself.getTotolCommentCount(target: target, postId: postId) { (total) in
                    let commentCount = Firestore.firestore().collection("main-post")
                        .document(target)
                        .collection("post")
                        .document(postId)
                    commentCount.setData(["comment":total] as [String : Any], merge: true) { (err) in
                        if err != nil {
                            print("comment err \(err?.localizedDescription as Any)")
                        }else{
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func getTotolCommentCount(target : String, postId : String , completion : @escaping(Int) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document(target)
            .collection("post")
            .document(postId)
            .collection("comment")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion(0)
                    return}
                if snap.isEmpty {
                    completion(0)
                }else{
                    completion(snap.documents.count)
                }
            }
        }
    }
    
    
    func getComment(target : String , postId: String , completion: @escaping([CommentModel]) ->Void) {
        var comment = [CommentModel]()
        let db = Firestore.firestore().collection("main-post")
            .document(target)
            .collection("post")
            .document(postId)
            .collection("comment")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion([])
                    return
                }
                if !snap.isEmpty {
                    for item in snap.documents {
                        comment.append(CommentModel.init(ID : item.documentID , dic: item.data()))
                    }
                    completion(comment)
                    
                }else{
                    completion([])
                }
            }
        }
    }
    
    
    
    
    func setRepliedComment(currentUser : CurrentUser ,target : String, targetCommentId : String , commentId : String,commentText : String, postId : String , completion : @escaping(Bool) ->Void)
    {
        
        //İSTE/lesson-post/post/1600870068749/comment-replied/comment/1601035854117/1601037120899
        
        let db = Firestore.firestore().collection("main-post")
            .document(target)
            .collection("post")
            .document(postId)
            .collection("comment-replied")
            .document("comment")
            .collection(targetCommentId).document(commentId)
        
        
        let dic = ["senderName" : currentUser.name as Any, "senderUid" : currentUser.uid as Any,
                   "username" : currentUser.username as Any,
                   "time":FieldValue.serverTimestamp() ,
                   "comment":commentText ,
                   "commentId":commentId,
                   "postId":postId,
                   "likes":[],"replies" : [] , "senderImage" : currentUser.thumb_image as Any] as [String : Any]
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                sself.setRepliedCommentId(target : target ,targetCommentID: targetCommentId, commentId: commentId, currentUser: currentUser, postId: postId) { (_) in
                    completion(true)
                }
            }
        }
    }
    private func setRepliedCommentId(target :String ,targetCommentID : String , commentId : String, currentUser : CurrentUser , postId : String ,completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection("main-post")
            .document(target)
            .collection("post")
            .document(postId)
            .collection("comment")
            .document(targetCommentID)
        
        db.updateData(["replies":FieldValue.arrayUnion([commentId as Any])]) { (err) in
            if err == nil {
                completion(true)
                
            }
        }
    }
    
    func editAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Düzenle") { (action, view, completion) in
            completion(true)
        }
        action.backgroundColor = .systemGreen
        
        action.image = UIImage(named: "duzenle")
        return action
    }
    
    
    func reportAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Şikayet Et") { (action, view, completion) in
            completion(true)
        }
        action.backgroundColor = .systemRed
        
        action.image = UIImage(named: "report-msg")
        return action
    }
    func setLike(comment : CommentModel,tableView : UITableView , currentUser : CurrentUser, post : MainPostModel,  completion : @escaping(Bool) ->Void){
        
        if !(comment.likes?.contains(currentUser.uid))!{
            comment.likes?.append(currentUser.uid)
            tableView.reloadData()
            ///main-post/sell-buy/post/1603580081581
            let db = Firestore.firestore().collection("main-post")
                .document(post.postType)
                .collection("post")
                .document(post.postId)
                .collection("comment").document(comment.commentId!)
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as Any])]) { (err) in
                
                if err != nil{
                    print("like err \(err?.localizedDescription as Any)")
                }else{
                    NotificaitonService.shared.mainpost_replied_comment_like_notification(post: post, comment: comment, currentUser: currentUser, text: Notification_description.comment_like.desprition, type: NotificationType.comment_like.desprition)
                }
            }
        }else{
            comment.likes?.remove(element: currentUser.uid)
            tableView.reloadData()
            let db = Firestore.firestore().collection("main-post")
                .document(post.postType)
                .collection("post")
                .document(post.postId)
                .collection("comment").document(comment.commentId!)
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as Any])]) {
                (err) in
                
                if err != nil{
                    
                    print("like err \(err?.localizedDescription as Any)")
                }else{
                    NotificaitonService.shared.mainpost_remove_replied_comment_like_notificaiton(post: post, comment: comment, currentUser: currentUser, text: Notification_description.comment_like.desprition, type: NotificationType.comment_like.desprition)
                }
            }}
    }
    
    func send_comment_notificaiton(post : MainPostModel , currentUser : CurrentUser, text : String , type : String){
        if post.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                let dic = ["type":type ,
                           "text" : text,
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
    /// Description Yapılan yoruma yanıt bildirimi
    /// - Parameters:
    ///   - post: mainPost
    ///   - currentUser: currentUser
    ///   - getterUid: getterUid
    ///   - comment: commentMode
    func set_main_post_replid_comment(post : MainPostModel , currentUser : CurrentUser , getterUid : String , text : String , type : String ){
        if currentUser.uid == getterUid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                let dic = ["type":type ,
                           "text" : text as Any,
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
    func send_comment_mention_user(username : String ,currentUser : CurrentUser, text : String , type : String , post : MainPostModel){
        UserService.shared.getUserBy_Mention(username: username) { (otherUser) in
            if username == currentUser.username{
                return
            }else{
                if !post.silent.contains(post.senderUid){
                    if !currentUser.slientUser.contains(otherUser.uid){
                        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                        
                        let db = Firestore.firestore().collection("user")
                            .document(otherUser.uid).collection("notification").document(notificaitonId)
                        let dic = ["type":type ,
                                   "text" : text,
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
        }  }
    
    
    func setRepliedComment(currentUser : CurrentUser ,post : MainPostModel , comment : CommentModel , targetCommentId : String , commentId : String,commentText : String, postId : String , completion : @escaping(Bool) ->Void)
    {
        
        //main-post/sell-buy/post/1603888561458/comment-replied/comment/1603986010312/1604077583715
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(post.postId)
            .collection("comment-replied")
            .document("comment").collection(targetCommentId).document(commentId)
        
        
        let dic = ["senderName" : currentUser.name as Any, "senderUid" : currentUser.uid as Any,
                   "username" : currentUser.username as Any,
                   "time":FieldValue.serverTimestamp() ,
                   "comment":commentText ,
                   "commentId":commentId,
                   "postId":postId,
                   "targetComment": comment.commentId as Any,
                   "likes":[],"replies" : [] , "senderImage" : currentUser.thumb_image as Any] as [String : Any]
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                sself.setRepliedCommentId(targetCommentID: targetCommentId, commentId: commentId, post : post, currentUser: currentUser, postId: postId) { (_) in
                    completion(true)
                }
            }
        }
    }
    
  
    
    private func setRepliedCommentId(targetCommentID : String , commentId : String, post : MainPostModel, currentUser : CurrentUser , postId : String ,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(post.postId).collection("comment").document(targetCommentID)
        
        db.updateData(["replies":FieldValue.arrayUnion([commentId as Any])]) { (err) in
            if err == nil {
                completion(true)
                
            }
        }
    }
    func setRepliedCommentLike(repliedComment : CommentModel,likedCommentId : String,currentUser : CurrentUser  , post : MainPostModel, completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(repliedComment.postId!)
            .collection("comment-replied")
            .document("comment")
            .collection(likedCommentId)
            .document(repliedComment.commentId!)
        if !(repliedComment.likes?.contains(currentUser.uid))!{
            
            repliedComment.likes?.append(currentUser.uid)
            
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as Any])]) { (err) in
                if err == nil {
                    completion(true)
                    NotificaitonService.shared.mainpost_replied_comment_like_notification(post: post, comment: repliedComment, currentUser: currentUser, text: Notification_description.comment_like.desprition, type: NotificationType.comment_like.desprition)
                }else{
                    print("err \(err?.localizedDescription as Any)")
                }
            }
        }else{
            repliedComment.likes?.remove(element: currentUser.uid)
            
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as Any])]) { (err) in
                if err == nil {
                    
                    completion(true)
                    NotificaitonService.shared.mainpost_remove_replied_comment_like_notificaiton(post: post, comment: repliedComment, currentUser: currentUser,text: Notification_description.comment_like.desprition, type: NotificationType.comment_like.desprition)
                }
                else{
                    print("err \(err?.localizedDescription as Any)")
                }
            }}
    }
    
    
    
    
}
