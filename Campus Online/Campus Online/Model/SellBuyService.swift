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

    func setNewBuySellPost(currentUser : CurrentUser,currentUserFollower : [String] ,location : GeoPoint? ,postType: String, postId : String , msgText : String , datas :[String] ,value : String?, short_school : String , completion : @escaping(Bool)->Void){
        let dic = [
            "postTime":FieldValue.serverTimestamp(),
            "senderName":currentUser.name as Any,
            "text":msgText,
            "likes":[],
            "comment":0,
            "senderUid":currentUser.uid as Any,
            "dislike":[],
            "postId":postId,
            "postID":Int64(postId) as Any,
            "data":datas,
            "thumbData":[],
            "username": currentUser.username as Any,
            "thumb_image": currentUser.thumb_image as Any,
            "slient":[],
            "postType":postType,
            "value":value ?? "",
            "geoPoint":location ?? "" ] as [String : Any]
    
        setPostForCurrentUser(postId: postId, currentUser: currentUser)
        setPostForBuySell(currentUser: currentUser, dic: dic, short_school: short_school, postId: postId) {[weak self] (val) in
            guard let sself = self else { return }
            if val{
                completion(true)
                sself.setPostForFollowers(postId : postId  , followers : currentUserFollower){
                    (vals) in
                }
            }
        }

    }
    
    func setPostForBuySell(currentUser : CurrentUser , dic : [String : Any] , short_school : String , postId : String , completion : @escaping(Bool)->Void){
        let db = Firestore.firestore().collection(short_school).document("main-post")
            .collection("post").document(postId)
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                sself.setPostOnBuySellCollection(postId: postId, currentUser: currentUser) { (val) in
                    completion(val)
                }
            }
        }
        
    }
    func setPostOnBuySellCollection(postId : String , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("buy-sell").collection("post").document(postId)
        db.setData(["postId":postId], merge: true){
            (err) in
            if err == nil {
                completion(true)
            }
        }
    }
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
    
    func getTopicFollowers(currentUser : CurrentUser , completion : @escaping([String])->Void){
        ///İSTE/sell-buy/followers/2YZzIIAdcUfMFHnreosXZOTLZat1
        var user = [String]()
        let db = Firestore.firestore().collection(currentUser.short_school)
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
    var despription : String {
        switch self{
        case .buySell:
            return "buy-cell"
        case .foodMe:
            return "food-me"
        case .party:
            return "party"
        case .camping:
            return "camping"
        }
    }
}
