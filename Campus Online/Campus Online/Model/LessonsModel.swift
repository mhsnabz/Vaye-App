//
//  LessonsModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class LessonsModel {
    var teacherEmail : String!
    var teacherId : String!
    var teacherName : String!
    var lessonName : String!
    init( dic : Dictionary<String,Any>) {
       
        if let teacherEmail = dic["teacherEmail"] as? String {
            self.teacherEmail = teacherEmail
        }
        if let teacherId = dic["teacherId"] as? String {
                  self.teacherId = teacherId
              }
        if let teacherName = dic["teacherName"] as? String {
                  self.teacherName = teacherName
              }
        if let lessonName = dic["lessonName"] as? String {
                  self.lessonName = lessonName
              }
        
        
    }
}
