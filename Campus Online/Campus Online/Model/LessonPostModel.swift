//
//  LessonPostModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
class LessonPostModel {
    var lessonName : String!
    var postTime : Timestamp!
    var senderName : String!
    var text : String!
    var likes : Int!
    var comment : Int!
    var senderUid : String!
    var dislike : Int!
    var link : String!
    var postId  :String!
    var postID : Int64!
    var data : [String]!
    var thumb_image : String!
    var username : String!
    init(postId  : String! , dic : [String : Any]) {
        self.postId = postId
        if let lessonName = dic["lessonName"] as? String {
            self.lessonName = lessonName
        }
        if let postID = dic["postID"] as? Int64 {
                   self.postID = postID
               }
        
        if let senderName = dic["senderName"] as? String {
            self.senderName = senderName
        }
        if let senderUid = dic["senderUid"] as? String {
                   self.senderUid = senderUid
               }
        if let text = dic["text"] as? String {
            self.text = text
        }
        if let link = dic["link"] as? String {
            self.link = link
        }
        if let likes = dic["likes"] as? Int {
            self.likes = likes
        }
        if let comment = dic["comment"] as? Int {
            self.comment = comment
        }
        if let dislike = dic["dislike"] as? Int {
            self.dislike = dislike
        }
        if let data = dic["data"] as? [String] {
            self.data = data
        }
        if let thumb_image = dic["thumb_image"] as? String {
                  self.thumb_image = thumb_image
              }
        if let username = dic["username"] as? String {
                  self.username = username
              }
        if let postTime = dic["postTime"] as? Timestamp {
            self.postTime = postTime
        }
    }
}
