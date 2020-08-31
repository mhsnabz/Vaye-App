//
//  MenuFooter.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class SlideMenuFooter : UITableViewHeaderFooterView {
    
    
    static let reuseIdentifier: String = String(describing: self)
    
    
    lazy var footer : UIView = {
       let v = UIView()

        return v
    }()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
            
        addSubview(footer)
             footer.anchor(top: nil, left: leftAnchor , bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 8, marginBottom: 0, marginRigth: 88, width: 0, heigth: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
