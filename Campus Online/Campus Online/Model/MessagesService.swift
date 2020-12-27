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
}
