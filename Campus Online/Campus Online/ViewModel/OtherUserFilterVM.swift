//
//  OtherUserFilterVM.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class OtherUserFilterVM {
    private let target : String
    private let currentUser : CurrentUser
    private let otherUser : OtherUser
    var options : [OtherProfileFilterViewOptions] {
        var result = [OtherProfileFilterViewOptions]()
        if target == TargetFilterView.otherUser.description {
        if currentUser.short_school == otherUser.short_school {
            if currentUser.bolum == otherUser.bolum {
                result.append(.bolum(()))
                result.append(.shortSchool(()))
                result.append(.onlineCampus(()))
            }else{
                result.append(.shortSchool(()))
                result.append(.onlineCampus(()))
            }
        }else{
            result.append(.onlineCampus(()))
        }
        }
    
        return result
    }
    
    init( target : String , otherUser : OtherUser , currentUser : CurrentUser) {
        
        self.target = target
        self.otherUser = otherUser
        self.currentUser = currentUser
        
    }
}
enum OtherProfileFilterViewOptions {
    case bolum(Void)
    case shortSchool(Void)
    case onlineCampus(Void)
    var descprition : String {
        switch self {
        case .bolum():
            return "bolum"
        case .shortSchool():
            return "school"
        case .onlineCampus():
            return "online_campus"
     
        }
    }
    
}
