//
//  FriendListModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class FriendListModel {
    var name : String!
    var username : String!
    var short_school : String!
    var bolum : String!
    var uid : String!
    var thumb_image : String!
    var profileImage : String!
    init(dic : Dictionary<String,Any>) {
        if let name  = dic["name"] as? String{
            self.name = name
        }
        if let username  = dic["username"] as? String{
            self.username = username
        }
        if let bolum  = dic["bolum"] as? String{
            self.bolum = bolum
        }
        if let short_school  = dic["short_school"] as? String{
            self.short_school = short_school
        }
        if let uid  = dic["uid"] as? String{
            self.uid = uid
        }
        if let thumb_image  = dic["thumb_image"] as? String{
            self.thumb_image = thumb_image
        }
        if let profileImage  = dic["profileImage"] as? String{
            self.profileImage = profileImage
        }
    }
}
