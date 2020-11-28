//
//  CurrentUserProfileFilterVM.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class UserProfileFilterVM
{
    
    private let target : String
    
    var options : [ProfileFilterViewOptions] {
        var result = [ProfileFilterViewOptions]()
        if target == TargetFilterView.currentUser.description {
            result.append(.bolum(()))
            result.append(.shortSchool(()))
            result.append(.onlineCampus(()))
            result.append(.fav(()))
        }else if target == TargetFilterView.otherUser.description {
            result.append(.bolum(()))
            result.append(.shortSchool(()))
            result.append(.onlineCampus(()))
        }else{
            result.append(.onlineCampus(()))
        }
        return result
    }
    
    init( target : String) {
        
        self.target = target
        
    }
}

