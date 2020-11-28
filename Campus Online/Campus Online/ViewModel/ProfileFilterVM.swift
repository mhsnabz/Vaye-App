//
//  ProfileFilterVM.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class ProfileFilterVM{
    private let short_school : String
    private let major : String
    private let userUid : String
    private let currentUser : CurrentUser
    var options : [ProfileFilterOptions] {
        var result = [ProfileFilterOptions]()
        if currentUser.uid == userUid {
            result.append(.major(()))
            result.append(.shortSchool(()))
            result.append(.vayeApp(()))
            result.append(.fav(()))
        }else if currentUser.short_school == short_school {
            if currentUser.bolum == major {
                result.append(.major(()))
                result.append(.shortSchool(()))
                result.append(.vayeApp(()))
            }else{
                result.append(.shortSchool(()))
                result.append(.vayeApp(()))
            }
        }else{
            result.append(.vayeApp(()))
        }
        return result
        
    }
    
    
    init(short_school : String , major : String , userUid : String , currentUser : CurrentUser) {
        self.short_school = short_school
        self.major = major
        self.userUid = userUid
        self.currentUser = currentUser
    }
    
}
enum ProfileFilterOptions {
    case major(Void)
    case shortSchool(Void)
    case vayeApp(Void)
    case fav(Void)
    var description : String {
        switch self {
        
        case .major():
            return "major"
        case .shortSchool():
            return "shortSchool"
        case .vayeApp():
            return "vaye.app"
        case .fav():
            return "fav"
        }
    }
}
enum ProfileFilterViewOptions {
    case bolum(Void)
    case shortSchool(Void)
    case onlineCampus(Void)
    case vayeApp(Void)
    case fav(Void)
    var descprition : String {
        switch self {
        case .bolum():
            return "bolum"
        case .shortSchool():
            return "school"
        case .onlineCampus():
            return "online_campus"
        case .fav():
            return "fav"
        case .vayeApp():
            return "vaye.app"
        }
    }
    
}

enum TargetFilterView {
    case currentUser
    case otherUser
    case otherUserAnotherSchool

    var description : String {
        switch self {
        
        case .currentUser:
            return "currentUser"
        case .otherUser:
            return "otherUser"
        case .otherUserAnotherSchool:
            return "otherUserAnotherSchool"
        }
    }
    
}
