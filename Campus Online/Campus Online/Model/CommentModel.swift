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

    
    var senderName : String?
    var senderUid : String?
    var username : String?
    var time : Timestamp?
    var comment : String?
    var likes : [String]?
    var replies : [String]?
    var senderImage : String?
    var commentId : String?
    var postId : String?
    var targetComment : String?
    init(ID : String ,dic : [String : Any]) {
        
        self.commentId = ID
        if let senderName = dic["senderName"] as? String {
            self.senderName = senderName
        }
        if let targetComment = dic["targetComment"] as? String {
            self.targetComment = targetComment
        }
        if let postId = dic["postId"] as? String {
            self.postId = postId
        }
        
        if let senderUid = dic["senderUid"] as? String {
            self.senderUid = senderUid
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
