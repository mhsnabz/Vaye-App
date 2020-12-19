//
//  MainPostASViewModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
struct MainPostASViewModel {
     let currentUser : CurrentUser
    var imageOptions : [MainPostSheetOptions] {
        var result = [MainPostSheetOptions]()
        result.append(.buyAndSellPost(currentUser))
        result.append(.foodMePost(currentUser))
        result.append(.campingPost(currentUser))
        return result
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
    }
}
enum MainPostSheetOptions{
    case buyAndSellPost(CurrentUser)
    case foodMePost(CurrentUser)
    case campingPost(CurrentUser)
    var descrition : String {
        switch self{
        
        case .foodMePost(_):
            return "Yemek"
        case .buyAndSellPost(_):
            return "Al-Sat"
        case .campingPost(_):
            return "Kamp"
        }
    }
    var image : UIImage {
        switch self {
        
        case .buyAndSellPost(_):
            return #imageLiteral(resourceName: "buy_sell").withRenderingMode(.alwaysOriginal)
        case .foodMePost(_):
            return #imageLiteral(resourceName: "foodme").withRenderingMode(.alwaysOriginal)
        case .campingPost(_):
            return #imageLiteral(resourceName: "camp").withRenderingMode(.alwaysOriginal)
        }
    }
}
