//
//  NotificaitonLauncherViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ActionSheetNotification{
    private let currentUser : CurrentUser
    private let target : String
    var imageOptions : [NotificationOptions] {
        var result = [NotificationOptions]()
        if target == NotifictionTarget.notification.descriptions{
            result.append(.makeAllRead(currentUser))
            result.append(.deleteAll(currentUser))
            
        }
        return result
    }
    
    init(currentUser : CurrentUser , target : String) {
        self.currentUser = currentUser
        self.target = target.description

    }
}

enum NotificationOptions {
    case makeAllRead(CurrentUser)
    case deleteAll(CurrentUser)
    var descriptions : String {
        switch self{
        
        case .makeAllRead(_):
            return "Bütün Bildirimleri Okundu Olarak İşaretle"
        case .deleteAll(_):
            return "Bütün Bildirimleri Sil"
        }
    }
    var image : UIImage {
        switch self {
        
        case .makeAllRead(_):
            return #imageLiteral(resourceName: "readed").withRenderingMode(.alwaysOriginal)
        case .deleteAll(_):
            return #imageLiteral(resourceName: "delete").withRenderingMode(.alwaysOriginal)
        }
    }
}
enum NotifictionTarget {
    case notification
    
    var descriptions : String {
        switch self{
        
        case .notification:
            return "notificaiton"
        }
    }
    
}
