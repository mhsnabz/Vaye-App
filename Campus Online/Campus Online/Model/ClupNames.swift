//
//  ClupNames.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
class ClupNames {
    var id : String!
    
    var followers : [String]?
    init(id : String , dic : [String : Any]?) {
        self.id = id
        if let followers = dic?["followers"] as? [String] {
            self.followers = followers
        }
    }
}
