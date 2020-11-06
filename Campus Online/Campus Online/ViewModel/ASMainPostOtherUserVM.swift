//
//  ASMainPostOtherUser.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ASMainPostOtherUserVM{
    private let currentUser : CurrentUser
    private let target : String
    
    var imageOptions : [ASMainPostOtherUserOptions] {
            var result = [ASMainPostOtherUserOptions]()
        if target == TargetOtherUser.otherPost.description
           {
            result.append(.fallowUser(currentUser))
            result.append(.slientPost(currentUser))
            result.append(.reportPost(currentUser))
            result.append(.slientUser(currentUser))
            result.append(.reportUser(currentUser))
           }
           return result
       }
    init(currentUser : CurrentUser , target : String) {
        self.currentUser = currentUser
        self.target = target.description

    }
}
enum ASMainPostOtherUserOptions{
    case fallowUser(CurrentUser)
    case slientUser(CurrentUser)
    case slientPost(CurrentUser)
    case reportPost(CurrentUser)
    case reportUser(CurrentUser)
    var description : String {
        switch self {
            
        case .fallowUser(_):
            return "Bu Kullanıcı Takip Et"
        case .slientUser(_):
            return "Bu Kullanıcıyı Sessize Al"
     
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
            return UIImage(named: "loud-user")!
        case .reportPost(_):
            return UIImage(named: "alert")!
        case .reportUser(_):
            return UIImage(named: "report-user")!

//            return UIImage(named: "cancel")!
        }
    }
}
