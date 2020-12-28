//
//  MessagesModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import MessageKit
import CoreLocation

struct Message : MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender : SenderType {
    var senderId: String
    var displayName: String
    var profileImageUrl : String
    
}
struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "customc"
        }
    }
}
