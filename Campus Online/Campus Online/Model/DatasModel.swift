//
//  DatasModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class DatasModel {

    var postDate : String!
    var currentUser : CurrentUser!
    var lessonName : String!
    var type : String!
    var data : Data!
    
    init(postDate : String , currentUser : CurrentUser , lessonName : String , type : String , data : Data){
        self.postDate = postDate
        self.currentUser = currentUser
        self.lessonName = lessonName
        self.type = type
        self.data = data
    }
    
}
