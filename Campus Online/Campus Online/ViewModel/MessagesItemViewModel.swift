//
//  MessagesItemViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 29.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
struct MessagesItemViewModel {
    private let currentUser : CurrentUser
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
    }
    var imageOptions: [MesagesItemOption]{
        var result = [MesagesItemOption]()
        result.append(.addImage(currentUser))
        result.append(.addLocation(currentUser))
        result.append(.addDocument(currentUser))
       
        return result
    }
}
enum MesagesItemOption{
    case addImage(CurrentUser)
    case addLocation(CurrentUser)
    case addDocument(CurrentUser)
    var description : String {
        switch self{
        
        case .addImage(_):
            return "Resim Gönder"
        case .addLocation(_):
            return "Konum Paylaş"
        case .addDocument(_):
            return "Belge Gönder"
        }
    }
    var image : UIImage {
        switch self{
        
        case .addImage(_):
            return #imageLiteral(resourceName: "gallery").withRenderingMode(.alwaysOriginal)
        case .addLocation(_):
            return #imageLiteral(resourceName: "location-orange").withRenderingMode(.alwaysOriginal)
        case .addDocument(_):
            return #imageLiteral(resourceName: "license").withRenderingMode(.alwaysOriginal)
        }
    }
    
}
