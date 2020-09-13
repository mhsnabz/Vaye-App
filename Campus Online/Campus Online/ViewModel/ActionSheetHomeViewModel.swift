//
//  ActionSheetHomeViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ActionSheetHomeViewModel
{
    private let currentUser : CurrentUser
      private let target : String
    
    var imageOptions : [ActionSheetHomeOptions] {
         var result = [ActionSheetHomeOptions]()
        if target == TargetHome.ownerPost.description
        {
            result.append(.editPost(currentUser))
            result.append(.deletePost(currentUser))
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
    var description : String {
        switch self {
            
        case .editPost(_):
            return "Gönderiyi Düzenle"
        case .deletePost(_):
            return "Gönderiyi Sil"
        }}
    var image : UIImage {
          switch self {   
          case .editPost(_):
             return UIImage(named: "edit")!
          case .deletePost(_):
             return UIImage(named: "delete")!
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
