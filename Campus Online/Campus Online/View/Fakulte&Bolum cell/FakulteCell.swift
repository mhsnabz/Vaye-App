//
//  FakulteCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class FakulteCell: UITableViewCell {
    
    let lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.numberOfLines = 0
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    let v : UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(lbl)
        
        lbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width - 20, heigth: 0)
        lbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(v)
        
        v.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
