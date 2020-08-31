//
//  Enum.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//


import Foundation
import UIKit
enum MenuOption : Int ,CustomStringConvertible {
    case major
    case school_notices
    case not
    case rate
    case set
    case logout
    var description: String{
        switch self {
        case .major:
           return "Bilgisayar Mühendisliği"
        case.school_notices:
          return  "İSTE Duyuru"
        case .rate :
            return "Bizi Değerlendir"
        case .set:
            return "Ayarlar"
        case .not:
            return "Bildirim Ayarları"
        case .logout:
            return "Çıkış Yap"
    
        }
    }
    var image : UIImage {
           switch self {
           case .major : return UIImage(named: "home")!.withRenderingMode(.alwaysOriginal)
           case .school_notices : return UIImage(named: "notices")!.withRenderingMode(.alwaysOriginal)
           case .set : return UIImage(named: "set")!.withRenderingMode(.alwaysOriginal)
           case .not : return UIImage(named: "not-setting")!.withRenderingMode(.alwaysOriginal)
           case .rate:
            return UIImage(named: "rate-us")!.withRenderingMode( .alwaysOriginal)
            case .logout:
                return UIImage(named: "logout")!.withRenderingMode(.alwaysOriginal)
        }
       }
}
