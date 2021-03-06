//
//  TaskUser.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class TaskUser {
    var email : String!
    var name : String!
    var bolum_key : String!
    var number : String!
    var priority : String!
    var profileImage : String!
    var thumb_image : String!
    var schoolName : String!
    var short_school : String!
    var bolum : String!
    var fakulte : String!
    var uid : String!
    var username : String!
    var linkedin : String!
    var instagram : String!
    var twitter : String!
    var github : String!
    var slientUser : [String]!
    var unvan : String!
    var isValid : Bool?
    init(uid : String ,dic : Dictionary<String,Any>) {
        self.uid = uid
        if let unvan = dic["unvan"] as? String {
            self.unvan = unvan
        }
        if let isValid = dic["isValid"] as? Bool {
            self.isValid = isValid
        }
        if let bolum_key = dic["bolum_key"] as? String {
            self.bolum_key = bolum_key
        }
        if let email = dic["email"] as? String {
            self.email = email
        }
        if let slientUser = dic["slient"] as? [String] {
                   self.slientUser = slientUser
               }
        if let name = dic["name"] as? String {
            self.name = name
        }
        if let fakulte = dic["fakulte"] as? String {
            self.fakulte = fakulte
        }
        if let bolum = dic["bolum"] as? String {
                   self.bolum = bolum
               }
        if let number = dic["number"] as? String {
            self.number = number
        }
        if let priority = dic["priority"] as? String {
            self.priority = priority
        }
        if let profileImage = dic["profileImage"] as? String {
            self.profileImage = profileImage
        }
        if let thumb_image = dic["thumb_image"] as? String {
            self.thumb_image = thumb_image
        }
        if let schoolName = dic["schoolName"] as? String {
            self.schoolName = schoolName
        }
        if let short_school = dic["short_school"] as? String {
            self.short_school = short_school
        }
        if let uid = dic["uid"] as? String {
            self.uid = uid
        }
        if let username = dic["username"] as? String {
            self.username = username
        }
        if let instagram = dic["instagram"] as? String {
                   self.instagram = instagram
               }
        if let github = dic["github"] as? String {
                   self.github = github
               }
        if let linkedin = dic["linkedin"] as? String {
                   self.linkedin = linkedin
               }
        if let twitter = dic["twitter"] as? String {
                   self.twitter = twitter
               }
    }
    
  
}
