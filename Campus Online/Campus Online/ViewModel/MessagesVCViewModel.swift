//
//  MessagesVCviewMode.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.01.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
struct MessagesVCViewModel {
    let target : String
    let currentUser : CurrentUser
    init(currentUser : CurrentUser , target : String) {
        self.currentUser = currentUser
        self.target = target
    }
    
    var imageOptions : [MessagesVCOptions]{
        var result = [MessagesVCOptions]()
        if target == MessagesVCTarget.request.description {
            result.append(.removeAllRequest(currentUser))
            result.append(.disableRequest(currentUser))
        }else if target == MessagesVCTarget.chat.description{

            result.append(.disableRequest(currentUser))
        }
        return result
    }
    
    
}
enum MessagesVCTarget {
    case request
    case chat
    var description : String {
        switch self{
        case .request:
            return "request"
        case .chat:
            return "chat"
        }
    }
}
enum MessagesVCOptions{

    case removeAllRequest(CurrentUser)
    case disableRequest(CurrentUser)
    
    var description : String{
        switch self{
     
        case .removeAllRequest(_):
            return "Bütün İstekleri Sil"
        case .disableRequest(_):
            return "Mesaj İsteklerini Kapat"
        }
    }
    var image : UIImage {
        switch self{
      
        case .removeAllRequest(_):
            return #imageLiteral(resourceName: "delete").withRenderingMode(.alwaysOriginal)
        case .disableRequest(_):
            return #imageLiteral(resourceName: "on").withRenderingMode(.alwaysOriginal )
        }
    }
}
