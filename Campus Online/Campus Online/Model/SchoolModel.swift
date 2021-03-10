//
//  SchoolModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 25.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
class SchoolModel {
    var name : String!
    var logo : UIImage!
    var shortName : String!
    init(dic : Dictionary<String,Any>) {
        if let name = dic["name"] as? String {
            self.name = name
        }
        if let logo = dic["logo"] as? UIImage {
            self.logo = logo
        }
        if let shortName = dic["shortName"] as? String {
            self.shortName = shortName
        }
    }
}
