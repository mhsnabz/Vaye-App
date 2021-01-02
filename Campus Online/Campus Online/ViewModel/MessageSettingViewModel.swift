//
//  MessageSettingViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.01.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
struct MessageSettingViewModel {
    let currentUser : CurrentUser
    var target = ""
    
    var imageOptions : [MessageSettingOptions]{
        var result = [MessageSettingOptions]()
            if target == MessageSettinTarget.request.desdescription {
               
                result.append(.deleteMessages(currentUser))
                result.append(.slientChat(currentUser))
                result.append(.reportUser(currentUser))
            }else if target == MessageSettinTarget.chat.desdescription{
                result.append(.deleteMessages(currentUser))
                result.append(.deleteFriend(currentUser))
                result.append(.slientChat(currentUser))
                result.append(.reportUser(currentUser))
            }
        return result
        
    }
    
    init(currentUser : CurrentUser , target  : String) {
        self.currentUser = currentUser
        self.target = target
    }
}
enum MessageSettinTarget{
    case chat
    case request
    var desdescription : String {
        switch self{
        case .chat :
            return "chat"
        case .request:
            return "request"
        }
    }
}
enum MessageSettingOptions{
    case deleteMessages(CurrentUser)
    case deleteFriend(CurrentUser)
    case slientChat(CurrentUser)
    case reportUser(CurrentUser)
    var description : String {
        switch self{
        
        case .deleteMessages(_):
            return "Sohbeti Sil"
        case .deleteFriend(_):
            return "Arkadaşlarım Arasından Kaldır"
        case .slientChat(_):
            return "Sessize Al"
        case .reportUser(_):
            return "Kullanıcıyı Şikayet Et"
        }
    }
    var image : UIImage {
        switch self{
        
        case .deleteMessages(_):
            return #imageLiteral(resourceName: "delete").withRenderingMode(.alwaysOriginal)
        case .deleteFriend(_):
            return #imageLiteral(resourceName: "cancel-dark").withRenderingMode(.alwaysOriginal)
        case .slientChat(_):
            return #imageLiteral(resourceName: "silent").withRenderingMode(.alwaysOriginal)
        case .reportUser(_):
            return #imageLiteral(resourceName: "report-user").withRenderingMode(.alwaysOriginal)
        }
    }
}
