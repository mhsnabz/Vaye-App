//
//  NotificaitonModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import  FirebaseFirestore
class NotificationModel {
    
    var isRead : Bool!
    var lessonName : String!
    var not_id : String!
    var postId : String!
    var senderImage : String!
    var senderName : String!
    var senderUid : String!
    var time : Timestamp!
    var type : String!
    var text : String!
    var username : String!
    
    init(not_id : String , dic : Dictionary<String,Any>){
        self.not_id = not_id
        if let isRead = dic["isRead"] as? Bool {
            self.isRead = isRead
        }
        if let text = dic["text"] as? String{
            self.text = text
        }
        if let lessonName = dic["lessonName"] as? String{
            self.lessonName = lessonName
        }
        if let postId = dic["postId"] as? String{
            self.postId = postId
        }
        if let senderImage = dic["senderImage"] as? String{
            self.senderImage = senderImage
        }
        if let senderName = dic["senderName"] as? String{
            self.senderName = senderName
        }
        if let senderUid = dic["senderUid"] as? String{
            self.senderUid = senderUid
        }
        if let type = dic["type"] as? String{
            self.type = type
        }
        if let username = dic["username"] as? String{
            self.username = username
        }
        if let time = dic["time"] as? Timestamp{
            self.time = time
        }
        
    }
}
