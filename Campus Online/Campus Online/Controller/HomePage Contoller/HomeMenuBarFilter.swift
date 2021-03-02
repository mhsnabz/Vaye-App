//
//  HomeMenuBarFilter.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 2.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class HomeMenuBarFilter:  UICollectionViewCell {
    let lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.textColor = .lightGray

        return lbl
    }()
    override var isSelected: Bool{
        didSet{
            if isSelected {
                lbl.font = UIFont(name: Utilities.fontBold, size: 13)
                lbl.textColor = .black
            }else{
                lbl.font = UIFont(name: Utilities.font, size: 11)
                lbl.textColor = .lightGray
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lbl)
     
        lbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        lbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
