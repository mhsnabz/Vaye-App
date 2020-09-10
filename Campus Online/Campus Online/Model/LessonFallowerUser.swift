//
//  LessonFallowerUser.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class LessonFallowerUser {
    var username : String?
    var name : String?
    var number : String?
    var thumb_image : String?
    var email : String?
    var uid : String?
    init(username : String , dic: Dictionary<String,Any>){
        self.username = username
        if let name = dic["name"] as? String {
            self.name = name
        }
        if let uid = dic["uid"] as? String {
            self.uid = uid
        }
        if let number = dic["number"] as? String {
            self.number = number
        }
        if let thumb_image = dic["thumb_image"] as? String {
            self.thumb_image = thumb_image
        }
        if let email = dic["email"] as? String {
            self.email = email
        }
        
    }
}
