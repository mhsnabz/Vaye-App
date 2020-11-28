//
//  ProfileModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class ProfileModel {
    var currentUser : CurrentUser!
    var shortSchool : String!
    var major : String!
    var uid : String
    init(shortSchool : String , currentUser : CurrentUser , major : String , uid : String) {
        self.currentUser = currentUser
        self.shortSchool = shortSchool
        self.uid = uid
        self.major = major
    }
}
