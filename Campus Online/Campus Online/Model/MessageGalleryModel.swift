//
//  MessageGallerModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 29.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class MessageGalleryModel{
 
    var type : String!
    var data : Data!
    
    init(data : Data ,  type : String){
    
        self.type = type
        self.data = data
    }
}
