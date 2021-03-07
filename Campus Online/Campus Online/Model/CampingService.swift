//
//  CampingService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore

class CampingService{
    public static var shared = CampingService()
    func setNewCamping(type:String,currentUser : CurrentUser,currentUserFollower : [String] ,location : GeoPoint?,locationName : String? ,postType: String, postId : String , msgText : String , datas :[String] , short_school : String , completion : @escaping(Bool)->Void){
        let dic = [
            "postTime":FieldValue.serverTimestamp(),
            "senderName":currentUser.name as Any,
            "text":msgText,
            "likes":[],
            "comment":0,
            "senderUid":currentUser.uid as Any,
            "dislike":[],
            "postId":postId,
            "post_ID":Int64(postId) as Any,
            "data":datas,"type":type,
            "locationName":locationName ?? "" as Any,
            "thumbData":[],
            "username": currentUser.username as Any,
            "thumb_image": currentUser.thumb_image as Any,
            "silent":[],
            "postType":postType,
            "geoPoint":location as Any ] as [String : Any]
        setPostForCurrentUser(postId: postId, currentUser: currentUser)
        add_post_for_universty(uni: currentUser.short_school, postId: postId)
        setPostForCamping(dic: dic, postId: postId) { [weak self ](val) in
            guard let sself = self else { return }
            if val{
                completion(true)
                sself.setPostForFollowers(postId : postId ,senderUid : currentUser.uid , followers : currentUserFollower){
                    (vals) in
                }
            }
        }
    }
    
    func setPostForCurrentUser(postId : String , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("main-post").document(postId)
        db.setData(["postId":postId], merge: true){ err in
            let db = Firestore.firestore().collection("user")
                .document(currentUser.uid)
                .collection("user-main-post").document(postId)
            db.setData(["postId":postId], merge: true)
        }
    }
    func add_post_for_universty(uni shortname : String, postId : String ){
    
        let db = Firestore.firestore().collection(shortname)
            .document("main-post")
            .collection("camping")
            .document(postId)
        db.setData(["postId":postId])
    }
    func setPostOnCampingCollection(postId : String , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document("camping").collection("post").document(postId)
        db.setData(["postId":postId], merge: true){
            (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    func setPostForCamping( dic : [String : Any] , postId : String , completion : @escaping(Bool)->Void){
 
        let db = Firestore.firestore().collection("main-post")
            .document("post").collection("post").document(postId)

        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
 
    /// add post on user followers
    /// - Parameters:
    ///   - postId: main post ıd
    ///   - followers: current user followers id
    ///   - completion: nil
    func setPostForFollowers(postId : String ,senderUid : String, followers : [String] , completion : @escaping(Bool) ->Void){
        for item in followers{
            let db = Firestore.firestore().collection("user")
                .document(item)
                .collection("main-post").document(postId)
            db.setData(["postId":postId,"senderUid":senderUid], merge: true)
        }
        completion(true)
    }
 
  

}
