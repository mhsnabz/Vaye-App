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
    func send_post_like_comment_notification(postType : String,post : LessonPostModel , currentUser : CurrentUser, text : String , type : String){
        if post.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                let dic = ["type":type ,
                           "text" : text,
                           "postType":postType,
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
    
    
    
    func send_replied_comment_bymention(username : String ,currentUser : CurrentUser, text : String , type : String , post : LessonPostModel){
        UserService.shared.getUserBy_Mention(username: username) { (otherUser) in
            if username == currentUser.username{
                return
            }else{
                if !post.silent.contains(post.senderUid){
                    if !currentUser.slientUser.contains(otherUser.uid){
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
        }  }
    func start_following_you(currentUser : CurrentUser , otherUser : OtherUser , text : String , type : String , completion:@escaping(Bool)->Void){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("notification").document(notificaitonId)
        let dic = ["type":type ,
                   "text" : text,"postType":NotificationPostType.follow.name,
                   "senderUid" : currentUser.uid as Any,
                   "time":FieldValue.serverTimestamp(),
                   "senderImage":currentUser.thumb_image as Any ,
                   "not_id":notificaitonId,
                   "isRead":false ,
                   "username":currentUser.username as Any,
                   "postId":"post.postId" as Any,
                   "senderName":currentUser.name as Any,
                   "lessonName":"post.lessonName" as Any] as [String : Any]
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
    func new_home_post_notification(currentUser : CurrentUser ,postId : String , getterUids : [NotificationGetter] , text : String ,type : String, lessonName : String,notificaitonId : String ,completion : @escaping(Bool) ->Void){
        let dic = ["type" : type ,
                   "text" : text ,
                   "senderUid" : currentUser.uid as Any,
                   "time":FieldValue.serverTimestamp(),
                   "senderImage":currentUser.thumb_image as Any ,
                   "not_id":notificaitonId,
                   "isRead":false ,
                   "username":currentUser.username as Any,
                   "postId": postId  as Any,
                   "senderName":currentUser.name as Any,
                   "lessonName":lessonName as Any] as [String : Any]
        
        for item in getterUids{
            print("item uid : \(item.uid)")
            if item.uid != currentUser.uid{
                let db = Firestore.firestore().collection("user")
                    .document(item.uid).collection("notification").document(notificaitonId)
                db.setData(dic, merge: true) { (err) in
                    if err == nil {
                        print("succes")
                    }else{
                        print("err \(err?.localizedDescription as Any)")
                    }
                }
            }
        }
      
       
    }
    private func getMention(text : String ,completion : @escaping([String]) ->Void){
        var userNames = [String]()
       
        let val = text.findMentionText()
        for i in val {
            userNames.append(i)
        }
        completion(userNames)
    }
    
    func set_new_buy_sell_notification(currentUser : CurrentUser ,postId : String , getterUids : [String] , text : String ,type : String, topic : String,notificaitonId : String ,completion : @escaping(Bool) ->Void){
        let dic = ["type" : type ,
                   "text" : text ,
                   "senderUid" : currentUser.uid as Any,
                   "time":FieldValue.serverTimestamp(),
                   "senderImage":currentUser.thumb_image as Any ,
                   "not_id":notificaitonId,
                   "isRead":false ,
                   "username":currentUser.username as Any,
                   "postId": postId  as Any,
                   "senderName":currentUser.name as Any,
                   "lessonName":topic as Any] as [String : Any]
        for item in getterUids{
            if item != currentUser.uid{
                let db = Firestore.firestore().collection("user")
                    .document(item).collection("notification").document(notificaitonId)
                db.setData(dic, merge: true) { (err) in
                    if err == nil {
                        print("succes")
                    }else{
                        print("err \(err?.localizedDescription as Any)")
                    }
                }
            }
        }
    }
    
    func send_mainpost_like_notification(post : MainPostModel , currentUser : CurrentUser, text : String , type : String){
        if post.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description

                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid).collection("notification").document(notificaitonId)
                let dic = ["type":type ,
                           "text" : text,"postType":post.postType as Any,
                           "senderUid" : currentUser.uid as Any,
                           "time":FieldValue.serverTimestamp(),
                           "senderImage":currentUser.thumb_image as Any ,
                           "not_id":notificaitonId,
                           "isRead":false ,
                           "username":currentUser.username as Any,
                           "postId":post.postId as Any,
                           "senderName":currentUser.name as Any,
                           "lessonName":post.lessonName as Any] as [String : Any]
                db.setData(dic, merge: true) }
            }
        
    }
//    func mainpost_remove_like_notification(post : MainPostModel , currentUser : CurrentUser){
//        let db = Firestore.firestore().collection("user")
//            .document(post.senderUid).collection("notification").whereField("postId", isEqualTo: post.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: NotificationType.like_sell_buy.desprition)
//        db.getDocuments { (querySnap, err) in
//            if err == nil {
//                guard let snap = querySnap else { return }
//                if !snap.isEmpty {
//                    for item in snap.documents{
//                        let db = Firestore.firestore().collection("user")
//                            .document(post.senderUid).collection("notification").document(item.documentID)
//                        db.delete()
//                    }
//                }
//            }
//        }
//    }
    
    func mainpost_replied_comment_like_notification(post : MainPostModel,comment : CommentModel , currentUser : CurrentUser, text : String , type : String){
        if comment.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(comment.senderUid!).collection("notification").document(notificaitonId)
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
    
    func mainpost_remove_replied_comment_like_notificaiton(post : MainPostModel ,comment : CommentModel, currentUser : CurrentUser, text : String , type : String){        
        let db = Firestore.firestore().collection("user")
            .document(comment.senderUid!).collection("notification").whereField("postId", isEqualTo: comment.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: type)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documents else { return }
                print(snap)
                for item in snap{
                    let dbc = Firestore.firestore().collection("user")
                        .document(comment.senderUid!).collection("notification").document(item.documentID)
                    dbc.delete()
                }
            }
        }
    }
    
    func notice_post_like_notification(postType:String,post : NoticesMainModel, currentUser : CurrentUser, text : String , type : String){
        if post.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(post.senderUid!).collection("notification").document(notificaitonId)
                let dic = ["type":type ,
                           "text" : text,
                           "postType" : postType,
                           "senderUid" : currentUser.uid as Any,
                           "time":FieldValue.serverTimestamp(),
                           "senderImage":currentUser.thumb_image as Any ,
                           "not_id":notificaitonId,
                           "isRead":false ,
                           "username":currentUser.username as Any,
                           "postId":post.postId as Any,
                           "senderName":currentUser.name as Any,
                           "lessonName":post.clupName as Any] as [String : Any]
                db.setData(dic, merge: true)
                }
        }
    }
    
    func notice_post_remove_like_notification(post : NoticesMainModel, currentUser : CurrentUser, text : String , type : String){
        let db = Firestore.firestore().collection("user")
            .document(post.senderUid!).collection("notification").whereField("postId", isEqualTo: post.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: type)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documents else { return }
                print(snap)
                for item in snap{
                    let dbc = Firestore.firestore().collection("user")
                        .document(post.senderUid!).collection("notification").document(item.documentID)
                    dbc.delete()
                }
            }
        }
    }
    
    func notice_comment_like_notification(post : NoticesMainModel,comment : CommentModel , currentUser : CurrentUser, text : String , type : String){
        if comment.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(comment.senderUid!).collection("notification").document(notificaitonId)
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
                           "lessonName":post.clupName as Any] as [String : Any]
                db.setData(dic, merge: true)
                }
        }
    }
    func notice_comment_remove_like_notification(post : NoticesMainModel ,comment : CommentModel, currentUser : CurrentUser, text : String , type : String){
        let db = Firestore.firestore().collection("user")
            .document(comment.senderUid!).collection("notification").whereField("postId", isEqualTo: comment.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: type)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documents else { return }
                print(snap)
                for item in snap{
                    let dbc = Firestore.firestore().collection("user")
                        .document(comment.senderUid!).collection("notification").document(item.documentID)
                    dbc.delete()
                }
            }
        }
    }
    
    func school_replied_comment_like_notification(post : NoticesMainModel,comment : CommentModel , currentUser : CurrentUser, text : String , type : String){
        if comment.senderUid == currentUser.uid{
            return
        }else{
            if !post.silent.contains(post.senderUid){
                let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
                
                let db = Firestore.firestore().collection("user")
                    .document(comment.senderUid!).collection("notification").document(notificaitonId)
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
                           "lessonName":post.clupName as Any] as [String : Any]
                db.setData(dic, merge: true)
                }
        }
    }
    
    func school_remove_replied_comment_like_notificaiton(post : NoticesMainModel ,comment : CommentModel, currentUser : CurrentUser, text : String , type : String){
        let db = Firestore.firestore().collection("user")
            .document(comment.senderUid!).collection("notification").whereField("postId", isEqualTo: comment.postId as Any).whereField("senderUid", isEqualTo: currentUser.uid as Any).whereField("type", isEqualTo: type)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documents else { return }
                print(snap)
                for item in snap{
                    let dbc = Firestore.firestore().collection("user")
                        .document(comment.senderUid!).collection("notification").document(item.documentID)
                    dbc.delete()
                }
            }
        }
    }
    
}
struct NotificationGetter {
    let uid : String
}

enum PostName {
    case lessonPost
    case MainPost
    case NoticesPost
    var name : String{
        switch self {
        case .lessonPost:
        return "lesson-post"
        case .MainPost:
        return "main-post"
        case .NoticesPost:
        return "notices"
        }
    }
}

enum FollowNotification{
    case follow_you
    var desp : String{
        switch self{
        case.follow_you:
            return "Size Takip Etmeye Başladı"
        }
    }
    var type : String{
        switch self{
        case.follow_you:
            return "follow_you"
        }
    }
}
enum MajorPostNotification{
    case post_like
    case comment_like
    case new_post
    case new_comment
    case replied_comment_like
    case new_mentioned_post
    case new_mentioned_comment
    case new_replied_comment
    case new_replied_mentioned_comment
    var descp : String{
        switch self{
        case .replied_comment_like:
            return "Yorumunuzu Beğendi"
        case .post_like:
            return "Gönderinizi Beğendi"
        case .comment_like:
            return "Yorumunuzu Beğendi"
        case .new_post:
            return "Yeni Bir Gönderi Paylaştı"
        case .new_comment:
            return "Gönderinize Yorum Yaptı"
        case .new_mentioned_post:
            return "Bir Gönderide Sizden Bahsetti"
        case .new_mentioned_comment:
            return "Bir Yorumda Sizden Bahsetti"
        case.new_replied_comment:
            return "Yorumunuza Cevap Verdi"
        case .new_replied_mentioned_comment:
            return "Bir Yorumda Sizden Bahsetti"
        }
    }
    var type : String{
        switch self{
        case .post_like:
            return "post_like"
        case .comment_like:
            return "comment_like"
        case .new_post:
            return "new_post"
        case .new_comment:
            return "new_comment"
        case .new_mentioned_post:
            return "new_mentioned_post"
        case .new_mentioned_comment:
            return "new_mentioned_comment"
        case.new_replied_comment:
            return "new_replied_comment"
        case .new_replied_mentioned_comment:
            return "new_replied_mentioned_comment"
        case .replied_comment_like:
            return "replied_comment_like"
        }
    }
}


enum NoticesPostNotification{
    case post_like
    case comment_like
    case new_post
    case new_comment
    case replied_comment_like
    case new_mentioned_post
    case new_mentioned_comment
    case new_replied_comment
    case new_replied_mentioned_comment
    var descp : String{
        switch self{
        case .replied_comment_like:
            return "Yorumunuzu Beğendi"
        case .post_like:
            return "Gönderinizi Beğendi"
        case .comment_like:
            return "Yorumunuzu Beğendi"
        case .new_post:
            return "Yeni Bir Gönderi Paylaştı"
        case .new_comment:
            return "Gönderinize Yorum Yaptı"
        case .new_mentioned_post:
            return "Bir Gönderide Sizden Bahsetti"
        case .new_mentioned_comment:
            return "Bir Yorumda Sizden Bahsetti"
        case.new_replied_comment:
            return "Yorumunuza Cevap Verdi"
        case .new_replied_mentioned_comment:
            return "Bir Yorumda Sizden Bahsetti"
        }
    }
    var type : String{
        switch self{
        case .post_like:
            return "post_like"
        case .comment_like:
            return "comment_like"
        case .new_post:
            return "new_post"
        case .new_comment:
            return "new_comment"
        case .new_mentioned_post:
            return "new_mentioned_post"
        case .new_mentioned_comment:
            return "new_mentioned_comment"
        case.new_replied_comment:
            return "new_replied_comment"
        case .new_replied_mentioned_comment:
            return "new_replied_mentioned_comment"
        case .replied_comment_like:
            return "replied_comment_like"
        }
    }
}

enum MainPostNotification{
    case post_like
    case comment_like
    case new_post
    case new_comment
    case new_mentioned_post
    case new_mentioned_comment
    case new_replied_comment
    case new_replied_mentioned_comment
    case replied_comment_like
    var descp : String{
        switch self{
        case .replied_comment_like:
            return "Yorumunuzu Beğendi"
        case .post_like:
            return "Gönderinizi Beğendi"
        case .comment_like:
            return "Yorumunuzu Beğendi"
        case .new_post:
            return "Yeni Bir Gönderi Paylaştı"
        case .new_comment:
            return "Gönderinize Yorum Yaptı"
        case .new_mentioned_post:
            return "Bir Gönderide Sizden Bahsetti"
        case .new_mentioned_comment:
            return "Bir Yorumda Sizden Bahsetti"
        case.new_replied_comment:
            return "Yorumunuza Cevap Verdi"
        case .new_replied_mentioned_comment:
            return "Gönderinize Yorum Yaptı"
        }
    }
    var type : String{
        switch self{
        case .post_like:
            return "post_like"
        case .comment_like:
            return "comment_like"
        case .new_post:
            return "new_post"
        case .new_comment:
            return "new_comment"
        case .new_mentioned_post:
            return "new_mentioned_post"
        case .new_mentioned_comment:
            return "new_mentioned_comment"
        case.new_replied_comment:
            return "new_replied_comment"
        case .new_replied_mentioned_comment:
            return "new_replied_mentioned_comment"
        case .replied_comment_like:
            return "replied_comment_like"
        }
    }
}


