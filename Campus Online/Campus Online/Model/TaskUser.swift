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
    var number : String!
    var priority : String!
    var schoolName : String!
    var short_school : String!
    var uid : String!
  
    init(uid : String , dic : Dictionary<String,Any>) {
        self.uid = uid
        if let email = dic["email"] as? String {
            self.email = email
        }
        if let number = dic["number"] as? String {
            self.number = number
        }
        if let priority = dic["priority"] as? String {
            self.priority = priority
        }
        if let schoolName = dic["schoolName"] as? String {
            self.schoolName = schoolName
        }
        if let short_school = dic["short_school"] as? String {
            self.short_school = short_school
        }
    }
    
  
}
