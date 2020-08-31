//
//  ActionSheetViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
struct ActionSheetViewModel {
    private let currentUser : CurrentUser
    private let target : String
    var options : [ActionSheetOptions] {
        var result = [ActionSheetOptions]()
        if target == Target.lessonEdit.description {
            result.append(.removeLesson(currentUser))
            result.append(.lessonInfo(currentUser))
            result.append(.reportLesson(currentUser))
        }else if target == Target.profileEdit.description {
            result.append(.showPicture(currentUser))
            result.append(.removePicture(currentUser))
            result.append(.takePicture(currentUser))
            result.append(.choosePicture(currentUser))
        }
       
        return result
    }
    
    init(currentUser : CurrentUser , target : String) {
        self.currentUser = currentUser
        self.target = target.description
    }
    
    
    
}
enum ActionSheetOptions    {
    
    
    case removeLesson(CurrentUser)
    case lessonInfo(CurrentUser)
    case reportLesson(CurrentUser)
    case showPicture(CurrentUser)
    case removePicture(CurrentUser)
    case takePicture(CurrentUser)
    case choosePicture(CurrentUser)
    var description : String {
        switch self {
        case .lessonInfo(_): return "Ders Hakkında"
        case .removeLesson(_) :  return "Dersi Takip Etmeyi Bırak"
        case .reportLesson(_) : return "Problem Bildir"
        case .showPicture(_): return  "Profil Resmini Gör"
        case .removePicture(_): return  "Profil Resmini Sil"
        case.takePicture(_):
            return "Yeni Bir Resim Çek"
        case.choosePicture(_):
            return "Galeriden Resim Seç"
        }
    }
    var image : UIImage {
           switch self {
            
           case .removeLesson(_): return UIImage(named: "cancel")!
           case .lessonInfo(_):
            return UIImage(named: "info")!
           case .reportLesson(_):
            return UIImage(named: "bug")!
           case .showPicture(_):
            return UIImage(named: "full-screen")!
           case .removePicture(_):
            return UIImage(named: "delete")!
           case .takePicture(_):
            return UIImage(named: "camera")!
           case .choosePicture(_):
            return UIImage(named: "gallery")!
        }
       }
}
enum Target {
    case profileEdit
    case lessonEdit
    var description : String {
        switch self {
        case .profileEdit:
            return "EditProfile"
        case .lessonEdit:
            return "LessonEdit"
        }
    }
}
