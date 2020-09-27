//
//  LessonInfoModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class LessonInfoModel {
    var lessonName : String?
    var teacherName : String?
    var teacherId : String?
    var teacherEmail : String?
    init(dic: Dictionary<String,Any>){
        if let lessonName = dic["lessonName"] as? String {
            self.lessonName = lessonName
        }
        if let teacherName = dic["teacherName"] as? String {
            self.teacherName = teacherName
        }
        if let teacherId = dic["teacherId"] as? String {
            self.teacherId = teacherId
        }
        if let teacherEmail = dic["teacherEmail"] as? String {
            self.teacherEmail = teacherEmail
        }
    }
    
    
}
