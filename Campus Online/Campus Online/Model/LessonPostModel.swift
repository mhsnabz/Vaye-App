//
//  LessonPostModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import GoogleMobileAds
class LessonPostModel {
    var lessonName : String!
    var postTime : Timestamp?
    var senderName : String!
    var text : String!
    var likes : [String]!
    var comment : Int!
    var senderUid : String!
    var dislike : [String]!
    var link : String!
    var postId  :String!
    var postID : Int64!
    var data : [String]!
    var thumbData : [String]!
    var thumb_image : String!
    var username : String!
    var silent : [String]!
    var favori : [String]!
    var id : String!
    var empty : String!
    var nativeAd :  GADUnifiedNativeAd!
    init(nativeAd : GADUnifiedNativeAd , postTime : Timestamp) {
        self.nativeAd = nativeAd
        self.postTime = postTime
    }
    init(postId  : String? , dic : [String : Any]?) {
        self.postId = postId
        if let lessonName = dic?["lessonName"] as? String {
            self.lessonName = lessonName
        }
        if let postID = dic?["postID"] as? Int64 {
                   self.postID = postID
               }
        
        if let senderName = dic?["senderName"] as? String {
            self.senderName = senderName
        }
        if let senderUid = dic?["senderUid"] as? String {
                   self.senderUid = senderUid
               }
        if let text = dic?["text"] as? String {
            self.text = text
        }
        if let link = dic?["link"] as? String {
            self.link = link
        }
        if let likes = dic?["likes"] as? [String] {
            self.likes = likes
        }
        if let comment = dic?["comment"] as? Int {
            self.comment = comment
        }
        if let dislike = dic?["dislike"] as? [String] {
            self.dislike = dislike
        }
        if let favori = dic?["favori"] as? [String] {
            self.favori = favori
        }
        if let data = dic?["data"] as? [String] {
            self.data = data
        }
        if let thumbData = dic?["thumbData"] as? [String] {
            self.thumbData = thumbData
        }
        if let silent = dic?["silent"] as? [String] {
                   self.silent = silent
               }
        if let thumb_image = dic?["thumb_image"] as? String {
                  self.thumb_image = thumb_image
              }
        if let username = dic?["username"] as? String {
                  self.username = username
              }
        if let postTime = dic?["postTime"] as? Timestamp {
            self.postTime = postTime
        }
    }
    init(empty : String , postId : String) {
        self.postId = postId
        self.empty = empty
    }
}
