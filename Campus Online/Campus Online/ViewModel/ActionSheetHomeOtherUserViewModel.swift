//
//  ActionSheetHomeOtherUserViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ActionSheetHomeOtherUserViewModel{
    private let currentUser : CurrentUser
    private let target : String
    private let otherUserUid : String
    
    var imageOptions : [ActionSheetOtherUserOptions] {
            var result = [ActionSheetOtherUserOptions]()
        if target == TargetOtherUser.otherPost.description
           {
            result.append(.fallowUser(currentUser))
            result.append(.slientPost(currentUser))
            result.append(.slientLesson(currentUser))
            result.append(.slientUser(currentUser))
            result.append(.reportPost(currentUser))
            result.append(.reportUser(currentUser))
           }
           return result
       }
    
    init(currentUser : CurrentUser , target : String , otherUser : String) {
        self.currentUser = currentUser
        self.target = target.description
        self.otherUserUid = otherUser
    }
}
enum ActionSheetOtherUserOptions{
    
    case fallowUser(CurrentUser)
    case slientUser(CurrentUser)
    case slientLesson(CurrentUser)
    case slientPost(CurrentUser)
    case reportPost(CurrentUser)
    case reportUser(CurrentUser)
    
    
    var description : String {
        switch self {
            
        case .fallowUser(_):
            return "Bu Kullanıcı Takip Et"
        case .slientUser(_):
            return "Bu Kullanıcıyı Sessize Al"
        case .slientLesson(_):
            return "Bu Dersi Sessize Al"
        case .reportPost(_):
            return "Bu Gönderiyi Şikayet Et"
        case .reportUser(_):
            return "Bu Kullanıcıyı Sikayet Et"
            
        case .slientPost(_):
            return "Bu Gönderiyi Sessize Al"
        }}
    var image : UIImage {
        switch self {
            
        case .slientPost(_):
            return UIImage(named: "silent")!
        case .fallowUser(_):
            return UIImage(named: "silent")!
        case .slientUser(_):
            return UIImage(named: "silent")!
        case .slientLesson(_):
            return UIImage(named: "silent")!
        case .reportPost(_):
            return UIImage(named: "silent")!
        case .reportUser(_):
            return UIImage(named: "silent")!
        }
    }
}
enum TargetOtherUser {
    
    case otherPost
    
    var description : String {
        switch self {
        case .otherPost:
            return "other"
            
        }
    }
}
