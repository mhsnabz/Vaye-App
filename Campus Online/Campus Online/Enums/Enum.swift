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
//    case school_notices
    case not
    case rate
    case set
    case logout
    var description: String{
        switch self {
        case .major:
           return ""
//        case.school_notices:
//          return  ""
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
//           case .school_notices : return UIImage(named: "notices")!.withRenderingMode(.alwaysOriginal)
           case .set : return UIImage(named: "set")!.withRenderingMode(.alwaysOriginal)
           case .not : return UIImage(named: "not-setting")!.withRenderingMode(.alwaysOriginal)
           case .rate:
            return UIImage(named: "rate-us")!.withRenderingMode( .alwaysOriginal)
            case .logout:
                return UIImage(named: "logout")!.withRenderingMode(.alwaysOriginal)
        }
       }
}

enum COMenuOption : Int ,CustomStringConvertible
{
   
    case fallowing
//    case party
    case al_sat
    case foodme
    case camp
    
   
  
    var description: String{
        switch self{
        
        case .fallowing:
            return "Takip Ettiklerin"
//        case.party:
//        return "Etkinlikler"
        case.al_sat:
        return "Al-Sat"
        case .foodme :
        return "FoodMe"
        case .camp:
            return "Kamp"
        
       
        }
    }
    var image : UIImage{
        switch self{
        case .fallowing:  return UIImage(named: "menu-home")!.withRenderingMode(.alwaysOriginal)
//        case .party: return #imageLiteral(resourceName: "party").withRenderingMode(.alwaysOriginal)
        case .al_sat: return UIImage(named: "menu-bag")!.withRenderingMode(.alwaysOriginal)
        case .foodme: return UIImage(named: "menu-food")!.withRenderingMode(.alwaysOriginal)
        case .camp: return UIImage(named: "menu-camp")!.withRenderingMode(.alwaysOriginal)
            
        }
    }
}

 enum DriveLinks {
     case googleDrive
     case dropbox
     case icloud
     case yandex
     case onedrive
    case mega
     var descrpiton : String {
         switch self {
             
         case .googleDrive:
             return "https://drive.google.com"
         case .dropbox:
              return "https://www.dropbox.com"
         case .icloud:
              return "https://www.icloud.com"
         case .yandex:
              return "https://disk.yandex.com"
         case .onedrive:
              return "https://onedrive.live.com"
         case .mega:
            return "https://mega.nz"
         }
     }
 }

enum DataTypes {
    case image
    case pdf
    case doc
    case pptx
    case thumb
    case auido
    var description : String {
        switch self {
        case .image:
            return "jpeg"
        case .pdf:
            return "pdf"
        case .doc:
            return "doc"
        case .pptx:
            return "pptx"
        case .thumb:
            return "jpeg"
        case.auido:
            return "m4a"
        }
    }
    var contentType : String {
        switch self {
        case .image:
            return "image/jpeg"
        case .pdf:
             return "application/pdf"
        case .doc:
             return "application/msword"
        case .pptx:
             return "application/vnd.ms-powerpoint"
        case .thumb:
            return "image/jpeg"
        case .auido:
            return "audio/m4a"
        }
    }
    var mimeType : String {
        switch self {
        case .image:
            return ".jpg"
        case .pdf:
            return ".pdf"
        case .doc:
            return ".doc"
        case .pptx:
            return ".ppt"
        case .thumb:
            return ".jpg"
        case .auido:
            return ".m4a"
        }
    }
}
enum socialMeadialink{
    case github,instagram,twitter,linkedIn
    var descprition : String{
        switch self{
        
        case .github:
            return "https://github.com/"
        case .instagram:
            return "https://www.instagram.com/"
        case .twitter:
            return "https://twitter.com/"
        case .linkedIn:
            return ""
        }
    }
}

enum NotificationPostType {
    case lessonPost
    case mainPost
    case notices
    case follow
    
    var name : String {
        switch self{
        case .lessonPost:
        return "lesson-post"
        case .mainPost:
            return "main-post"
        case .notices:
            return "notices-post"
        case .follow:
            return "follow"
        }
    }
}
enum PushNotificationTarget {
    case like
    case comment
    case follow
    case mention
    case newpost_lessonpost
    var type : String{
        switch self{
        case .like: return "like"
        case.comment: return "comment"
        case .follow : return "follow"
        case.mention : return "mention"
        case.newpost_lessonpost : return"newpost_lessonpost"
        }
    }
}



