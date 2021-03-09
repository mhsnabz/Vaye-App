//
//  PushNotificationService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 5.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class PushNotificationService {
    static let shared = PushNotificationService()
    
    func sendPushNotification(not_id : String ,getterUid : String , otherUser : OtherUser?, target : String ,senderName : String , mainText : String , type : String , senderUid : String ){
        let db = Firestore.firestore().collection("notification")
            .document(not_id)
        let title = senderName
        let text = type + " :" + mainText
     
        if let user = otherUser{
            guard let tokenId = user.tokenID else { return }
            let dic = [ "title":title as String,
                        "text": text as String,
                        "tokenId":tokenId as String,
                        "senderUid":senderUid as String,
                        "not_id":not_id as String
            ] as [String : String]
            if target == PushNotificationTarget.like.type {
                if user.like {
                 
                    db.setData(dic, merge: true)
                }
            }else if target == PushNotificationTarget.comment.type{
                if user.comment {
                    db.setData(dic, merge: true)
                }
            }else if target == PushNotificationTarget.follow.type{
                if user.follow {
                    db.setData(dic, merge: true)

                }
            }else if target == PushNotificationTarget.mention.type{
                if user.mention {
                    db.setData(dic, merge: true)

                }
            }
        }else{
            UserService.shared.getOtherUser(userId: getterUid) { (user) in
                guard let tokenId = user.tokenID else { return }
                let dic = [ "title":title as String,
                            "text": text as String,
                            "tokenId":tokenId as String,
                            "senderUid":senderUid as String,
                            "not_id":not_id as String
                ] as [String : String]
                if target == PushNotificationTarget.like.type {
                    if user.like {
                        db.setData(dic, merge: true)
                    }
                }else if target == PushNotificationTarget.comment.type{
                    if user.comment {
                        db.setData(dic, merge: true)
                    }
                }else if target == PushNotificationTarget.follow.type{
                    if user.follow {
                        db.setData(dic, merge: true)

                    }
                }else if target == PushNotificationTarget.mention.type{
                    if user.mention {
                        db.setData(dic, merge: true)

                    }
                }
            }
        }
        
        
    }
    
    
}
