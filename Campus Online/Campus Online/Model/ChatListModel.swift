//
//  ChatListModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class ChatListModel{
    var name : String?
    var thumbImage : String?
    var time : Timestamp?
    var badgeCount : Int?
    var uid : String!
    var isOnline : Bool!
    var lastMsg : String!
    var username : String!
    var type : String!
    init(uid : String ,dic : Dictionary<String,Any>) {
        self.uid = uid
        if let name = dic["name"] as? String {
            self.name = name
        }
        if let username = dic["username"] as? String {
            self.username = username
        }
        if let type = dic["type"] as? String {
            self.type = type
        }
        if let lastMsg = dic["lastMsg"] as? String {
            self.lastMsg = lastMsg
        }
        if let thumbImage = dic["thumbImage"] as? String{
            self.thumbImage = thumbImage
        }
        if let isOnline = dic["isOnline"] as? Bool{
            self.isOnline = isOnline
        }
        
        if let time = dic["time"] as? Timestamp {
            self.time = time
        }
        if let badgeCount = dic["badgeCount"] as? Int{
            self.badgeCount = badgeCount
        }
    }
}
