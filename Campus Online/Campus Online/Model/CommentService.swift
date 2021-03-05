//
//  CommentService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class CommentService {
   static let shared = CommentService()
    //İSTE/lesson-post/post/1600774976770/comment
    func setNewComment(currentUser : CurrentUser ,commentText : String, postId : String ,commentId : String ,completion : @escaping(Bool)->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId).collection("comment").document(commentId)
        
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
                self?.getTotolCommentCount(currentUser: currentUser, postId: postId) { (total) in
                    let commentCount = Firestore.firestore().collection(currentUser.short_school)
                        .document("lesson-post").collection("post").document(postId)
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
    
    func getTotolCommentCount(currentUser : CurrentUser, postId : String , completion : @escaping(Int) ->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId).collection("comment")
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
    
    func getComment(currentUser : CurrentUser , postId: String , completion: @escaping([CommentModel]) ->Void) {
        var comment = [CommentModel]()
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId).collection("comment")
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
    
    
    func setRepliedComment(currentUser : CurrentUser , targetCommentId : String , commentId : String,commentText : String, postId : String , completion : @escaping(Bool) ->Void)
    {
    
        ///İSTE/lesson-post/post/1600870068749/commet-replies/comment/commentId/Cy6C2SQs5RDcxa7lKBav
        
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId).collection("comment-replied")
            .document("comment").collection(targetCommentId).document(commentId)
        
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
                sself.setRepliedCommentId(targetCommentID: targetCommentId, commentId: commentId, currentUser: currentUser, postId: postId) { (_) in
                 completion(true)
                }
            }
        }
    }
    
    private func setRepliedCommentId(targetCommentID : String , commentId : String, currentUser : CurrentUser , postId : String ,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId).collection("comment").document(targetCommentID)
        db.updateData(["replies":FieldValue.arrayUnion([commentId as Any])]) { (err) in
            if err == nil {
                completion(true)
                
            }
        }
    }

    
    //MARK:- new instance
    
    
    
    func checkLike(commentModel : CommentModel ,  currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        guard let likes = commentModel.likes else { return }
        if likes.contains(currentUser.uid) {
            completion(false)
        }else{
            completion(true)
        }
    }

    
    func sendNewRepliedComment(postId : String , targetComment : String , commentText : String ,currentUser : CurrentUser,commentId : String ,completion : @escaping(Bool) ->Void){

        let db = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment-replied")
            .document("comment")
            .collection(targetComment)
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
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                ///comment/1614762780585/comment-replied/comment/1614797540332/1614929630215
                
               
                
                let db = Firestore.firestore().collection("comment")
                    .document(postId).collection("comment").document(targetComment)
                db.updateData(["replies":FieldValue.arrayUnion([commentId])],  completion: nil)
                completion(true)
                
            }
        }
    }
    
    func likeMainComment(commentModel : CommentModel!  , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("comment")
            .document(commentModel.postId!)
            .collection("comment")
            .document(commentModel.commentId!)
      
        let dic = ["likes":FieldValue.arrayUnion([currentUser.uid as Any])] as [String : Any]
        db.updateData(dic) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
    
    func removeMainLikeComment(commentModel : CommentModel , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("comment")
            .document(commentModel.postId!)
            .collection("comment")
            .document(commentModel.commentId!)
      
        let dic = ["likes":FieldValue.arrayRemove([currentUser.uid as Any])] as [String : Any]
        db.updateData(dic)
    }
    
    func likeRepliedComment(commentModel : CommentModel ,targetComment : String ,currentUser : CurrentUser ,completion : @escaping(Bool) ->Void){
        ///comment/1614762780585/comment-replied/comment/1614796174703/1614796206876
        let db = Firestore.firestore().collection("comment")
            .document(commentModel.postId!)
            .collection("comment-replied")
            .document("comment")
            .collection(targetComment)
            .document(commentModel.commentId!)
        let dic = ["likes":FieldValue.arrayUnion([currentUser.uid as Any])] as [String : Any]
        db.updateData(dic) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    
    func removeLikeRepliedComment(commentModel : CommentModel ,targetComment : String ,currentUser : CurrentUser){
        let db = Firestore.firestore().collection("comment")
            .document(commentModel.postId!)
            .collection("comment-replied")
            .document("comment")
            .collection(targetComment)
            .document(commentModel.commentId!)
        let dic = ["likes":FieldValue.arrayRemove([currentUser.uid as Any])] as [String : Any]
        db.updateData(dic)
    }
    
    
    func sendNewComment(postType : String,currentUser : CurrentUser , commentText : String , postId : String , commentId : String , completion:@escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("comment")
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
            guard let sself = self else { return }
            if err == nil {
                sself.getTotalCommentCount(postId: postId) { (count) in
                    sself.setTotolCommentCount(postType : postType,currentUser: currentUser, postId: postId, count: count)
                    completion(true)
                }
            }
        }
    }
    
    private func getTotalCommentCount(postId : String , completion : @escaping(Int) ->Void){

        let db = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment")
        
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion(0)
                }else{
                    completion(snap.documents.count)
                }
            }
        }
    }
    private func setTotolCommentCount( postType: String,currentUser : CurrentUser,postId : String , count : Int ){
        
        if postType == PostName.lessonPost.name {
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(postId)
            db.setData(["comment":count] as [String : Int], merge: true, completion: nil)
        }else if postType == PostName.MainPost.name{
            ///main-post/post/post/1613340868602
            let db = Firestore.firestore().collection(PostName.MainPost.name)
                .document("post")
                .collection("post")
                .document(postId)
            db.setData(["comment":count] as [String : Int], merge: true, completion: nil)
            
        }else if postType == PostName.NoticesPost.name{
            ///İSTE/notices/post/1613759937578
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document(PostName.NoticesPost.name)
                .collection("post")
                .document(postId)
            db.setData(["comment":count] as [String : Int], merge: true, completion: nil)
            
        }
        
       
    }
    
    
    
}
