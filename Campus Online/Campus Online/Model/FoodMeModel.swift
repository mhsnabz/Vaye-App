//
//  FoodMeModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 17.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class FoodMeModel {
    var postDate : String!
    var currentUser : CurrentUser!
    var type : String!
    var data : Data!
    init(postDate : String , currentUser : CurrentUser  , type : String , data : Data){
        self.postDate = postDate
        self.currentUser = currentUser
        self.type = type
        self.data = data
    }
}
