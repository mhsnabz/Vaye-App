//
//  SellBuyService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 16.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
class SellBuyService {
    static var shared = SellBuyService()

    func setNewBuySellPost(type : String,currentUser : CurrentUser,currentUserFollower : [String] ,location : GeoPoint?,locationName : String? ,postType: String, postId : String , msgText : String , datas :[String] ,value : String?, short_school : String , completion : @escaping(Bool)->Void){
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
            "data":datas,
            "locationName":locationName ?? "" as Any,
            "thumbData":[],
            "username": currentUser.username as Any,
            "thumb_image": currentUser.thumb_image as Any,
            "silent":[],
            "postType":postType,
            "value":value ?? "",type : type,
            "geoPoint":location as Any ] as [String : Any]
    
        setPostForCurrentUser(postId: postId, currentUser: currentUser)
        add_post_for_universty(uni: currentUser.short_school, postId: postId)
        setPostForBuySell( dic: dic, postId: postId) {[weak self] (val) in
            guard let sself = self else { return }
            if val{
                completion(true)
                sself.setPostForFollowers(postId : postId  , followers : currentUserFollower){
                    (vals) in
                }
            }
        }

    }
    
    func setPostForBuySell( dic : [String : Any] , postId : String , completion : @escaping(Bool)->Void){
 
        let db = Firestore.firestore().collection("main-post")
            .document("post").collection("post").document(postId)

        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
    
    func add_post_for_universty(uni shortname : String, postId : String ){
    
        let db = Firestore.firestore().collection(shortname)
            .document("main-post")
            .collection("sell-buy")
            .document(postId)
        db.setData(["postId":postId])
    }
    func setPostOnBuySellCollection(postId : String , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document("sell-buy").collection("post").document(postId)
        db.setData(["postId":postId], merge: true){
            (err) in
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
    func setPostForFollowers(postId : String , followers : [String] , completion : @escaping(Bool) ->Void){
        for item in followers{
            let db = Firestore.firestore().collection("user")
                .document(item)
                .collection("main-post").document(postId)
            db.setData(["postId":postId], merge: true)
        }
        completion(true)
    }
    func setPostForCurrentUser(postId : String , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("user-main-post").document(postId)
        db.setData(["postId":postId] as [String : Any], merge: true){ (err) in
            if err == nil {
                let db = Firestore.firestore().collection("user")
                    .document(currentUser.uid)
                    .collection("main-post").document(postId)
                db.setData(["postId":postId], merge: true)
            }
            
        }
    }
    
    
    
    func getTopicFollowers(completion : @escaping([String])->Void){
        ///İSTE/sell-buy/followers/2YZzIIAdcUfMFHnreosXZOTLZat1
        var user = [String]()
        let db = Firestore.firestore().collection("main-post")
            .document("sell-buy").collection("followers")
       
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if !snap.isEmpty{
                    for item in snap.documents{
                        user.append(item.documentID)
                        
                    }
                }else{
                    completion([])
                }
                completion(user)
            }
        }
    }
    
    
    func sendNotificaiton(currentUser : CurrentUser ,user : [String] ,text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
            NotificaitonService.shared.set_new_buy_sell_notification(currentUser: currentUser, postId: postId, getterUids: user, text: text, type: NotificationType.new_ad.desprition, topic: Notification_description.new_ad.desprition, notificaitonId: notificaitonId) { (_) in
                print("succes")
          
        }
    }
}
    

enum PostType {
    case buySell
    case foodMe
    case party
    case camping
    case notice
    var despription : String {
        switch self{
        case .buySell:
            return "sell-buy"
        case .foodMe:
            return "food-me"
        case .party:
            return "party"
        case .camping:
            return "camping"
        case .notice:
            return "notice"
        }
    }
}
