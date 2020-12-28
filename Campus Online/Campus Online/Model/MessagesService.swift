//
//  MessagesService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
class MessagesService {
    static public var shared = MessagesService()
    func getFriendList(currentUser : CurrentUser , completion:@escaping([OtherUser]) ->Void){
        var list = [OtherUser]()
        if currentUser.friendList.isEmpty {
            completion(list)
        }else{
            for item in currentUser.friendList {
                UserService.shared.getOtherUser(userId: item) { (user) in
                    list.append(user)
                }
            }
            completion(list)
        }
        
    }
    
    
    func getFriends(uid : String , completion:@escaping(OtherUser)->Void){
        let db = Firestore.firestore().collection("user")
            .document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil{
                guard let snap = docSnap else { return }
                completion(OtherUser.init(dic: snap.data()!))
            }
        }
    }
    
    
    func sendMessage(newMessage : Message , currentUser : CurrentUser , otherUser : OtherUser , time : Int64 ){
       var msg = ""
       
        switch newMessage.kind{
            
        case .text(let messageText):
            msg = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }


        let dic: [String: Any] = [
            "id": newMessage.messageId,
            "type": newMessage.kind.messageKindString,
            "content": msg,
            "date": newMessage.sentDate,
            "time":time,
            "senderUid" : currentUser.uid as Any,
            "is_read": false,
            "name": currentUser.name as Any
        ] as [String : Any]
        
        let dbSender = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid)
            .document(newMessage.messageId)
        dbSender.setData(dic, merge: true, completion: nil)
        
        
        let dbGetter = Firestore.firestore().collection("messages")
            .document(otherUser.uid)
            .collection(currentUser.uid)
            .document(newMessage.messageId)
        dbGetter.setData(dic, merge: true, completion: nil)
    }
    
    
}
