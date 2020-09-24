//
//  CommentModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
class CommentModel {
//           let dic = ["senderName" : currentUser.name as Any, "senderUid" : currentUser.uid as Any,
//    "username" : currentUser.username as Any,
//    "time":FieldValue.serverTimestamp() ,
//    "comment":commentText ,
//    "likes":[],"replies" : [] , "senderImage" : currentUser.thumb_image as Any] as [String : Any]
    
    var senderName : String?
    var uid : String?
    var username : String?
    var time : Timestamp?
    var comment : String?
    var likes : [String]?
    var replies : [String]?
    var senderImage : String?
    init(dic : [String : Any]) {
        if let senderName = dic["senderName"] as? String {
            self.senderName = senderName
        }
        if let uid = dic["uid"] as? String {
            self.uid = uid
        }
        if let username = dic["username"] as? String {
            self.username = username
        }
        if let senderImage = dic["senderImage"] as? String {
            self.senderImage = senderImage
        }
        if let likes = dic["likes"] as? [String] {
            self.likes = likes
        }
        if let replies = dic["replies"] as? [String] {
            self.replies = replies
        }
        if let comment = dic["comment"] as? String {
            self.comment = comment
        }
        if let time = dic["time"] as? Timestamp {
            self.time = time
        }
        
    }
    
}
