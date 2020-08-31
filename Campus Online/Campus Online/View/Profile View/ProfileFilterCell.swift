//
//  ProfileFilterCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    
    let titleLlb : UILabel = {
    let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.text = "Filter Test"
        return lbl
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLlb.font = isSelected ? UIFont(name: Utilities.fontBold, size: 14) :
                UIFont(name: Utilities.fontBold, size: 12)
            titleLlb.textColor = isSelected ? .black : .lightGray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(titleLlb)
        titleLlb.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLlb.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLlb.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
