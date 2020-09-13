//
//  ActionSheetHomeViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ActionSheetHomeCurrentUserViewModel
{
    private let currentUser : CurrentUser
      private let target : String
    
    var imageOptions : [ActionSheetHomeOptions] {
         var result = [ActionSheetHomeOptions]()
        if target == TargetHome.ownerPost.description
        {
            result.append(.editPost(currentUser))
            result.append(.deletePost(currentUser))
            result.append(.slientPost(currentUser))
        }
        return result
    }
    
    init(currentUser : CurrentUser , target : String) {
           self.currentUser = currentUser
           self.target = target.description
       }
}
enum ActionSheetHomeOptions{
    case editPost(CurrentUser)
    case deletePost(CurrentUser)
    case slientPost(CurrentUser)
    var description : String {
        switch self {
            
        case .editPost(_):
            return "Gönderiyi Düzenle"
        case .deletePost(_):
            return "Gönderiyi Sil"
        case .slientPost(_):
            return "Gönderi Bildirimlerini Sessize Al"
        }}
    var image : UIImage {
          switch self {   
          case .editPost(_):
             return UIImage(named: "edit")!
          case .deletePost(_):
             return UIImage(named: "delete")!
          case .slientPost(_):
             return UIImage(named: "silent")!
        }
      }
}
enum TargetHome {
    
    case ownerPost

    var description : String {
        switch self {
        case .ownerPost:
            return "owner"
            
        }
    }
}
