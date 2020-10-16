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
    
    func setNewBuySellPost(currentUser : CurrentUser , postId : String , msgText : String , datas :[String] , short_school : String , completion : @escaping(Bool)->Void){
        let silent : [String] = []
        let dic = [
        "postTime":FieldValue.serverTimestamp(),
        "senderName":currentUser.name as Any,
        "text":msgText,
        "likes":[],
        "favori":[],
        "senderUid":currentUser.uid as Any,
        "silent":silent as Any,
        "comment":0,
        "dislike":[],
        "data":datas,
        "postID":Int64(postId) as Any,
        "username" : currentUser.username as Any,
        "thumb_image": currentUser.thumb_image as Any
        ] as [String:Any]
        
        setPostForBuySell(currentUser: currentUser, dic: dic, short_school: short_school, postId: postId) {[weak self] (val) in
            guard let sself = self else { return }
            if val{
                sself.setPostForUser(currentUser: currentUser, postId: postId) { (_) in
                    print("completed")
                }
            }
        }
    }
    
    func setPostForBuySell(currentUser : CurrentUser , dic : [String : Any] , short_school : String , postId : String , completion : @escaping(Bool)->Void){
        let db = Firestore.firestore().collection(short_school).document("cell-buy")
            .collection("post").document(postId)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
        
    }
    
    func setPostForUser (currentUser : CurrentUser , postId : String , completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection("user").document(currentUser.uid)
            .collection("all-post").document(postId)
        db.setData(["postId" : postId], merge: true) { (err) in
            if err == nil {
                completion(true)
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
