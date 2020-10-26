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


    
}
